{{- define "compareshop-auth-api.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "compareshop-auth-api.fullname" -}}
{{- printf "%s" (default .Release.Name .Values.fullnameOverride) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "compareshop-auth-api.labels" -}}
app.kubernetes.io/name: {{ include "compareshop-auth-api.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
{{- end -}}
