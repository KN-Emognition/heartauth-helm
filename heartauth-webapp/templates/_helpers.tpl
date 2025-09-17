{{- define "iam.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "iam.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- include "iam.name" . -}}
{{- end -}}
{{- end -}}

{{- define "iam.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/name: {{ include "iam.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
app.kubernetes.io/managed-by: Helm
{{- end -}}

{{- define "iam.ns" -}}
{{- if .Values.namespaceOverride }}{{ .Values.namespaceOverride }}{{ else }}{{ .Release.Namespace }}{{ end -}}
{{- end -}}

{{- define "iam.webHost" -}}
{{ printf "%s.%s" .Values.global.subdomains.webclient .Values.global.domain }}
{{- end -}}

{{- define "iam.scheme" -}}
{{- if .Values.global.ingress.tls.enabled }}https{{ else }}http{{ end -}}
{{- end -}}