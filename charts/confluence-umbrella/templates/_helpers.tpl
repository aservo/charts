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

{{/*
Get license-key. If none set, use default.
*/}}
{{- define "umbrella.licenseKey" -}}
{{- if .Values.umbrella.licenseKey }}
{{- .Values.umbrella.licenseKey }}
{{- else -}}
{{- "AAACiA0ODAoPeNp9VF1vmzAUfedXWNpbJGgg6tZGQlqauF2mhkSEbOrWaTLmJrgFG9kmHf9+DoQOuqSPvr4f555z7A9RCWhBKuRdo+FoPHTHo0t0t4iQN3SvrDXIPcj5zL/BC2yHD/MHe/rD29ij76Ohdc8ocAVRVUBAcvAjvI7mwZ1FpXhJnM6tPz1EHsdoBnvIRAHSooJvHUI124OvZQmmqKQszqAX1EDy35RkwBMilROUeQxyub0heSxECLnQMNkB18p3WzT4T8FkNSMa/JXruV/+Ne4DaoI9TLHBxCS8P+aJSdLD2GZvFEjle5fWDBSVrNBMcD8CpVHWDEZbIVGRlTvGUdIOVa9Tuz2PFd/M/aGLV9OVlcApOHFVEKWchGjimCwN0qEp0OemEu9JVpJ6dn3eSQCeisKMagnACavvcRDhcBXO19haEGYacWL6/8/fQaked69YeuxNJdRz61LPdT/awyvb+9TUtyRNs1IZxIFIQPlDazAYTEM8ifDMvnkwB19rSXjOePqZ6MysyQh3qMgtmgnjwx5Hca3OG7HuhXHLUSvbbXO66Js8hA/EFZKp/hKNPMoZnBp1nr8jvB5LdajPkODatMWG7ezspifXeuPB5oF1EdauPI9vy1QKVd9jhu5gGdm3y9BehcvZZhrNl4G9WeODDrWYkKC4QjoFdOxsWKNGOeNiKZ6AavQz1bp4HF9c7ITTW+Pi6GAbmopfDpoJxIVGCVNasrjUYDozhbRA1HhC5MbrzuntVxnhtZxLuSOcqcbek3Ze+/LNL7Xhz1y88J7ruzsrTVR6Stp3Pp3u1aqUNCUK3nq8S3+t/td5ODnnsVaMbv6tieEKTtml/lrPueUvBz0PSzAsAhQ6RaKTu/EXAEWe8s2VygT6BSnI0AIUefIYpLQa5h0VcBofQ//kkVdTg+A=X02u2" }}
{{- end -}}
{{- end -}}

{{/*
Get confluence contextPath
*/}}
{{- define "confluence.contextPath" -}}
{{- default .Values.confluence.confluence.service.contextPath "" }}
{{- end -}}

{{/*
Generate confluence baseurl
*/}}
{{- define "confluence.baseurl" -}}
{{- $contextPath := include "common.names.fullname" . }}
{{- if .Values.confluence.ingress.host -}}
{{- printf "https://%s%s" .Values.confluence.ingress.host $contextPath -}}
{{- else -}}
{{- printf "http://127.0.0.1:8090%s" $contextPath -}}
{{- end -}}
{{- end -}}

{{/*
Determine the hostname to use for PostgreSQL
*/}}
{{- define "umbrella.databaseHost" -}}
{{- if .Values.global.postgresql.postgresqlHostname -}}
    {{- .Values.global.postgresql.postgresqlHostname -}}
{{- else if .Values.postgresql.enabled -}}
    {{- printf "%s-%s" .Release.Name "postgresql" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Return PostgreSQL port
*/}}
{{- define "umbrella.databasePort" -}}
{{- if .Values.global.postgresql.servicePort -}}
    {{- .Values.global.postgresql.servicePort -}}
{{- else if .Values.postgresql.enabled -}}
    {{- template "postgresql.port" .Subcharts.postgresql -}}
{{- else }}
    {{- printf "5432" -}}
{{- end -}}
{{- end -}}

{{/*
Return PostgreSQL created database
*/}}
{{- define "umbrella.databaseName" -}}
{{- if .Values.global.postgresql.postgresqlDatabase -}}
    {{- .Values.global.postgresql.postgresqlDatabase -}}
{{- else if .Values.postgresql.enabled }}
    {{- template "postgresql.database" .Subcharts.postgresql -}}
{{- end -}}
{{- end -}}

{{/*
Return PostgreSQL username
*/}}
{{- define "umbrella.databaseUser" -}}
{{- if .Values.global.postgresql.postgresqlUsername -}}
    {{- .Values.global.postgresql.postgresqlUsername -}}
{{- else if .Values.postgresql.enabled }}
    {{- template "postgresql.username" .Subcharts.postgresql -}}
{{- end -}}
{{- end -}}

{{/*
Return PostgreSQL password
*/}}
{{- define "umbrella.databasePassword" -}}
{{- if .Values.global.postgresql.postgresqlPassword -}}
    {{- .Values.global.postgresql.postgresqlPassword -}}
{{- else if .Values.postgresql.enabled }}
    {{- template "postgresql.password" .Subcharts.postgresql -}}
{{- end -}}
{{- end -}}

{{- define "confluence.databaseEnvVars" -}}
- name: ATL_DB_TYPE
  value: postgresql
- name: ATL_JDBC_URL
  valueFrom:
    secretKeyRef:
      name: {{ include "confluence.fullname" . }}-secrets
      key: postgresql-url
- name: ATL_JDBC_USER
  valueFrom:
    secretKeyRef:
      name: {{ include "confluence.fullname" . }}-secrets
      key: postgresql-username
- name: ATL_JDBC_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "confluence.fullname" . }}-secrets
      key: postgresql-password
{{ end }}

{{- define "synchrony.databaseEnvVars" -}}
- name: SYNCHRONY_DATABASE_URL
  valueFrom:
    secretKeyRef:
      name: {{ include "confluence.fullname" . }}-secrets
      key: postgresql-url
- name: SYNCHRONY_DATABASE_USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ include "confluence.fullname" . }}-secrets
      key: postgresql-username
- name: SYNCHRONY_DATABASE_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "confluence.fullname" . }}-secrets
      key: postgresql-password
{{ end }}

{{- define "confluence.additionalEnvironmentVariables" -}}
{{ if not .Values.confluence.license.secretName }}
- name: ATL_LICENSE_KEY
  valueFrom:
    secretKeyRef:
      name: {{ include "confluence.fullname" . }}-secrets
      key: license-key
{{ end }}
{{- with .Values.confluence.additionalEnvironmentVariables }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{- define "confluence.additionalInitContainers" -}}
# -- Additional initContainer to copy the Confluence configuration.
# Copies confluence.cfg.xml file to the proper location
- name: copy-config
  image: busybox
  imagePullPolicy: IfNotPresent
  command:
    - /bin/sh
  args:
    - '-c'
    - >-
      set -x
      ; cp /tmp/confluence.cfg.xml /var/atlassian/application-data/confluence/confluence.cfg.xml
  resources: {}
  volumeMounts:
    - name: server-config
      mountPath: /tmp/confluence.cfg.xml
      subPath: confluence.cfg.xml
    - name: local-home
      mountPath: /var/atlassian/application-data/confluence
# -- Additional initContainer to load initial Confluence database.
# The initial Confluence setup was performed in order to connect to a ready Postgresql database
# After the chart deployment the default user is able immediately to login without init routine
- name: init-db
  image: docker.io/bitnami/postgresql:11
  imagePullPolicy: IfNotPresent
  resources: {}
  volumeMounts:
    - name: dump-config
      mountPath: /tmp/restore-db.sh
      subPath: restore-db.sh
    - name: dump-config
      mountPath: /tmp/db.dump
      subPath: db.dump
    - name: dump-config-2
      mountPath: /tmp/db.dump2
      subPath: db.dump2
  env:
    - name: PGPASSWORD
      valueFrom:
        secretKeyRef:
          name: {{ include "confluence.fullname" . }}-secrets
          key: postgresql-password
  args: ['/tmp/restore-db.sh']
{{- with .Values.additionalInitContainers }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{- define "confluence.volumes" -}}
{{ if not .Values.volumes.localHome.persistentVolumeClaim.create }}
{{ include "confluence.volumes.localHome" . }}
{{- end }}
{{ include "confluence.volumes.sharedHome" . }}
# -- Volume with additional configuration files
- name: server-config
  configMap:
    name: {{ include "confluence.fullname" . }}-server-config
    items:
    - key: confluence.cfg.xml
      path: confluence.cfg.xml
      mode: 0755
# -- Volume with additional dump file for SQL import to the database
- name: dump-config
  configMap:
    name: {{ include "confluence.fullname" . }}-dump-config
    items:
    - key: restore-db.sh
      path: restore-db.sh
      mode: 0755
    - key: db.dump
      path: db.dump
# -- Volume with additional dump file for SQL import to the database part2.
# Need to split into pieces since configmap must have at most 1048576 bytes
- name: dump-config-2
  configMap:
    name: {{ include "confluence.fullname" . }}-dump-config-2
    items:
    - key: db.dump2
      path: db.dump2
{{- with .Values.volumes.additional }}
{{- toYaml . | nindent 0 }}
{{- end }}
{{- end }}