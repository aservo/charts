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
