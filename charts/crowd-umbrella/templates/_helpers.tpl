{{/* vim: set filetype=mustache: */}}

{{/*
Expand the name of the chart.
*/}}
{{- define "umbrella.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "umbrella.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "umbrella.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
These labels will be applied to all resources in the chart
*/}}
{{- define "umbrella.labels" -}}
helm.sh/chart: {{ include "umbrella.chart" . }}
app.kubernetes.io/name: {{ include "umbrella.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "umbrella.serverId" -}}
{{- if .Values.umbrella.serverId -}}
{{- .Values.umbrella.serverId -}}
{{- else -}}
AB0C-1D2E-FGHI-JKL3
{{- end -}}
{{- end -}}

{{- define "crowd.volumes" -}}
{{ if not .Values.volumes.localHome.persistentVolumeClaim.create }}
{{ include "crowd.volumes.localHome" . }}
{{- end }}
{{ include "crowd.volumes.sharedHome" . }}
# -- Volume with additional configuration files
- name: {{ include "crowd.fullname" . }}-server-config
  configMap:
    name: {{ include "crowd.fullname" . }}-server-config
    items:
    - key: restore-db.sh
      path: restore-db.sh
      mode: 0755
    - key: crowd.cfg.xml
      path: crowd.cfg.xml
      mode: 0755
# -- Volume with additional encryption key
- name: crowd-key
  configMap:
    name: {{ include "crowd.fullname" . }}-server-config
    items:
    - key: javax.crypto.spec.SecretKeySpec
      path: javax.crypto.spec.SecretKeySpec
      mode: 0755
# -- Volume with additional dump file for SQL import to the database
- name: {{ include "crowd.fullname" . }}-dump-config
  configMap:
    name: {{ include "crowd.fullname" . }}-dump-config
    items:
    - key: db.dump
      path: db.dump
{{- with .Values.volumes.additional }}
{{- toYaml . | nindent 0 }}
{{- end }}
{{- end }}

{{- define "crowd.additionalInitContainers" -}}
# -- Additional initContainer to copy the Crowd configuration.
# Copies crowd.cfg.xml file to the proper location.
# Copies Crypto key generated by the initial DB setup.
# The key belongs to the database and must have his specific unique ending.
# Missing this key would cause errors by Crowd server
- name: copy-config
  image: busybox
  imagePullPolicy: IfNotPresent
  command:
    - /bin/sh
  args:
    - '-c'
    - >-
      set -x &&
      cp /tmp/crowd.cfg.xml /var/atlassian/application-data/crowd/shared/crowd.cfg.xml &&
      mkdir -p /var/atlassian/application-data/crowd/shared/keys/ &&
      cp /tmp/key/javax.crypto.spec.SecretKeySpec
      /var/atlassian/application-data/crowd/shared/keys/javax.crypto.spec.SecretKeySpec_1619611916201
  resources: {}
  volumeMounts:
    - name: {{ include "crowd.fullname" . }}-server-config
      mountPath: /tmp/crowd.cfg.xml
      subPath: crowd.cfg.xml
    - name: shared-home
      mountPath: /var/atlassian/application-data/crowd/shared/
    - name: crowd-key
      mountPath: /tmp/key
# -- Additional initContainer to load initial Crowd database.
# The initial Crowd setup was performed in order to connect to a ready Postgresql database.
# After the chart deployment a default Crowd user is able immediately to login without init routine
- name: init-db
  image: docker.io/bitnami/postgresql:11
  imagePullPolicy: IfNotPresent
  resources: {}
  volumeMounts:
    - name: {{ include "crowd.fullname" . }}-server-config
      mountPath: /tmp/restore-db.sh
      subPath: restore-db.sh
    - name: {{ include "crowd.fullname" . }}-dump-config
      mountPath: /tmp/db.dump
      subPath: db.dump
  env:
    - name: PGPASSWORD
      valueFrom:
        secretKeyRef:
          name: {{ include "crowd.fullname" . }}-secrets
          key: postgresql-password
  args: ['/tmp/restore-db.sh']
- name: plugins
  image: ghcr.io/aservo/mapi:latest
  imagePullPolicy: Always
  resources: {}
  volumeMounts:
    - name: shared-home
      mountPath: /mnt
  command:
    - /bin/sh
  args:
    - '-c'
    - >-
      set -x &&
      echo "Start installing plugins..." &&
      mkdir -p /mnt/plugins &&
      mkdir -p /mnt/additional-plugins &&
      ./cleanup.sh /mnt/plugins jar &&
      ./download.sh de.aservo:confapi-crowd-plugin:0.0.8:jar /mnt/additional-plugins &&
      ./download.sh de.aservo:timestamp-to-date-crowd-plugin:0.0.4:jar /mnt/additional-plugins &&
      echo "Finish installing plugins..."
{{- with .Values.additionalInitContainers }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{- define "crowd.additionalBundledPlugins" -}}
- name: shared-home
  mountPath: "/var/atlassian/application-data/crowd/shared/plugins/confapi-crowd-plugin.jar"
  subPath: additional-plugins/confapi-crowd-plugin.jar
- name: shared-home
  mountPath: "/var/atlassian/application-data/crowd/shared/plugins/timestamp-to-date-crowd-plugin.jar"
  subPath: additional-plugins/timestamp-to-date-crowd-plugin.jar
{{- range .Values.crowd.additionalBundledPlugins }}
- name: {{ .volumeName }}
  mountPath: "/var/atlassian/application-data/crowd/shared/plugins/{{ .fileName }}"
  {{- if .subDirectory }}
  subPath: {{ printf "%s/%s" .subDirectory .fileName | quote }}
  {{- else }}
  subPath: {{ .fileName | quote }}
  {{- end }}
{{- end }}
{{- end }}

{{/*
Get license-key. If none set, use default.
*/}}
{{- define "umbrella.licenseKey" -}}
{{- if .Values.umbrella.licenseKey }}
{{- .Values.umbrella.licenseKey }}
{{- else -}}
{{- "AAABgQ0ODAoPeNp1kstuwjAQRff5CktdB4XXAqQsIHELLS+RQCvUjWMGcBvsaJxA+fuaQNQkopJX19d3zsz4aaokCSAhzQ5pdvutVr/dJTQISctxelbEjpFSjYngIDXQrUiFki6dhXS5WI4Dau2EPsAFCkd4ScB9Nhq9wGef+HCCWCWAFo/VCbBi83Kp4pplxwhwvltpQO12La7krsF4Kk7gppiBtciQH5gGn6XgXgltc5odq5Q7Y0dwfbqmk/mCLosb+pMIvOTPFu1R0Vc5OgA0OGPfHb70Qvtjte7Yb5vNyB46zXfrSyCrwL+OlwNCZQqYoNC1Xq/UlU6NEGcg+QNf0bIXZ9qkzdQWtOvUBp+nDHPpv6Jlwgd74phxEcXVRXl3sRI0ZcJUkMzQ1obGUZ23tQCjVF7fb80YV/JbqrO05rhnUmiWEw3SmGktmPwDKu/AQ8h99fXeKpedxb8raz5ojiLJC4WgUxLfYMhOIUnibC8k2Rak+jax8vv7Hy1Lv3FyG1gwLAIUHEP4zbqEf1DeOWKb7SpxQ1MEd8ACFGxZV5doE27OtsuNDT50k2xIhAozX02im" }}
{{- end -}}
{{- end -}}

{{/*
Determine the hostname to use for PostgreSQL.
*/}}
{{- define "postgresql.hostname" -}}
{{- if .Values.postgresql.enabled -}}
{{- printf "%s-%s" .Release.Name "postgresql" | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- .Values.postgresql.postgresqlHostname -}}
{{- end -}}
{{- end -}}
