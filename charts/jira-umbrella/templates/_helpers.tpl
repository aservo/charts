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
  Determine the hostname to use for PostgreSQL.
*/}}
{{- define "postgresql.hostname" -}}
{{- if .Values.postgresql.enabled -}}
{{- printf "%s-%s" .Release.Name "postgresql" | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- .Values.postgresql.postgresqlHostname -}}
{{- end -}}
{{- end -}}
