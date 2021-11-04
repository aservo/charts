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
{{- "AAACFg0ODAoPeNqNVE1v4jAUvOdXWNobkk1It7QgRdqWuF2qkqAQKu3XwSQPcBvsyHbSZX/9mjQIujRoDzk4fm88b2bsT3eKowlTyB2gXn/o9YcXLrqfJMhze9fOM1eMFEpmZWrIboE1qIqnkIF+ISw1vALfqBKclQIQa1kUoMijLRAaaMYNl8KnYULjaTyeUScsNwtQ0XJuYbSPe85ICmNhQrYBn//hQlYcqi/M5ExrzgRJ5eYDEqlUQE6wpqVK10xDwAz4lv4l7nnY9ZyGTrItoD4noE/0MZrSeL9Dfxdcbeu26aD/dU+KThjPW1nNrBCgxoF/S68o/hx893A/erjC9xeDD3WTS/PKLO1j0SwOOaAeS9vO+bwl7X3vz9qjPINFYVY3XnGxIllKpMi3/mJb2EJnVi50qnhR29hmcxvH9hS0GHqszPkpT6zvdDphlOC7KMbTOArmo2QchXg+o3bDHymw1mZosUVmDajhhahIZQYKNSqgH2tjip/DbnclyTuru/lbB4a3jl8EBRIJaVDGtVF8URqwyFwjI1FaaiM3lhZxbHyEAcFEepIwS2sU05uEBvj2245jW8oasjZmc/Ei5Ks4F60TWWY09O2HL13XidSKCa5ZbcbDOL5BGVSQS+ukRs2EaCkVMqCNzYJTy2aL/71OTe2T7dtBeU4Ah5D8D3A9QdvbcfyfViwv2SF8Z0Zvz+Jf+pe60jAtAhQ+GzCJU7MYFmyr9bWcIcaHyABZBwIVAIwwUZOl/qRdA4snVtYzwcCSZ1O/X02p5" }}
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

{{- define "jira.additionalInitContainers" -}}
# -- Additional initContainer to copy the Jira configuration.
# Copies dbconfig.xml file to the proper location
- name: copy-config
  image: busybox
  imagePullPolicy: IfNotPresent
  command:
    - /bin/sh
  args:
    - '-c'
    - >-
      set -x &&
      mkdir -p /opt/atlassian/jira/conf/ &&
      cp /tmp/server.xml /opt/atlassian/jira/conf/server.xml &&
      cp /tmp/dbconfig.xml /var/atlassian/application-data/jira/dbconfig.xml &&
      cp /tmp/dbconfig.xml /var/atlassian/application-data/shared-home/dbconfig.xml &&
      mkdir -p /opt/atlassian/jira/atlassian-jira/WEB-INF/classes/ &&
      cp /tmp/seraph-config.xml /opt/atlassian/jira/atlassian-jira/WEB-INF/classes/seraph-config.xml &&
      chown 2001:2001 /var/atlassian/application-data/jira/dbconfig.xml &&
      chown 2001:2001 /var/atlassian/application-data/shared-home/dbconfig.xml &&
      chown 2001:2001 /opt/atlassian/jira/conf/server.xml &&
      chown 2001:2001 /opt/atlassian/jira/atlassian-jira/WEB-INF/classes/seraph-config.xml
  resources: {}
  volumeMounts:
    - name: server-config
      mountPath: /tmp/dbconfig.xml
      subPath: dbconfig.xml
    - name: server-config
      mountPath: /tmp/server.xml
      subPath: server.xml
    - name: server-config
      mountPath: /tmp/seraph-config.xml
      subPath: seraph-config.xml
    - name: local-home
      mountPath: /var/atlassian/application-data/jira
    - name: shared-home
      mountPath: /var/atlassian/application-data/shared-home

# -- Additional initContainer to load initial Jira database.
# The initial Jira setup was performed in order to connect to a ready Postgresql database
# After the chart deployment the default user is able immediately to login without init routine
- name: init-db
  image: docker.io/bitnami/postgresql:11
  imagePullPolicy: IfNotPresent
  resources: {}
  volumeMounts:
    - name: server-config
      mountPath: /tmp/restore-db.sh
      subPath: restore-db.sh
    - name: dump-config
      mountPath: /tmp/db.dump
      subPath: db.dump
  env:
    - name: PGPASSWORD
      valueFrom:
        secretKeyRef:
          name: {{ include "jira.fullname" . }}-secrets
          key: postgresql-password
  args: ['/tmp/restore-db.sh']
{{- with .Values.additionalInitContainers }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{- define "jira.volumes" -}}
{{ if not .Values.volumes.localHome.persistentVolumeClaim.create }}
{{ include "jira.volumes.localHome" . }}
{{- end }}
{{ include "jira.volumes.sharedHome" . }}
# -- Volume with additional configuration files
- name: server-config
  configMap:
    name: {{ include "jira.fullname" . }}-server-config
    items:
    - key: restore-db.sh
      path: restore-db.sh
      mode: 0755
    - key: dbconfig.xml
      path: dbconfig.xml
      mode: 0755
    - key: server.xml
      path: server.xml
      mode: 0755
    - key: seraph-config.xml
      path: seraph-config.xml
      mode: 0755
# -- Volume with additional dump file for SQL import to the database
- name: dump-config
  configMap:
    name: {{ include "jira.fullname" . }}-dump-config
    items:
    - key: db.dump
      path: db.dump
{{- with .Values.volumes.additional }}
{{- toYaml . | nindent 0 }}
{{- end }}
{{- end }}