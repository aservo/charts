
{{/*
Expand the name of the chart.
*/}}
{{- define "ldap-crowd-adapter.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate to 20 characters because this is used to set the node identifier in WildFly which is limited to
23 characters. This allows for a replica suffix for up to 99 replicas.
*/}}
{{- define "ldap-crowd-adapter.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 20 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 20 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 20 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "ldap-crowd-adapter.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "ldap-crowd-adapter.labels" -}}
helm.sh/chart: {{ include "ldap-crowd-adapter.chart" . }}
{{ include "ldap-crowd-adapter.selectorLabels" . }}
app.kubernetes.io/version: {{ .Values.image.tag | default .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "ldap-crowd-adapter.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ldap-crowd-adapter.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "ldap-crowd-adapter.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "ldap-crowd-adapter.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Get the container port
*/}}
{{- define "ldap-crowd-adapter.containerPort" -}}
{{- if .Values.ssl.enabled }}
{{- .Values.containerSecurePort }}
{{- else }}
{{- .Values.containerDefaultPort }}
{{- end }}
{{- end }}

{{/*
Get the service port
*/}}
{{- define "ldap-crowd-adapter.servicePort" -}}
{{- if .Values.ssl.enabled }}
{{- .Values.service.ldapsPort }}
{{- else }}
{{- .Values.service.ldapPort }}
{{- end }}
{{- end }}
