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
Determine the hostname to use for PostgreSQL.
*/}}
{{- define "postgresql.hostname" -}}
{{- if .Values.postgresql.enabled -}}
{{- printf "%s-%s" .Release.Name "postgresql" | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- .Values.postgresql.postgresqlHostname -}}
{{- end -}}
{{- end -}}