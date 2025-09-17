{{- define "hauth.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "hauth.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "hauth.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/name: {{ include "hauth.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
app.kubernetes.io/managed-by: Helm
{{- end -}}

{{- define "hauth.ns" -}}
{{- if .Values.namespaceOverride }}{{ .Values.namespaceOverride }}{{ else }}{{ .Release.Namespace }}{{ end -}}
{{- end -}}

{{- define "hauth.internalHost" -}}
{{ printf "%s.%s" .Values.global.subdomains.internal .Values.global.domain }}
{{- end -}}
{{- define "hauth.externalHost" -}}
{{ printf "%s.%s" .Values.global.subdomains.external .Values.global.domain }}
{{- end -}}


{{- define "heartauth-core.fullname" -}}
{{ include "hauth.fullname" . }}
{{- end -}}

{{- define "heartauth-core.name" -}}
{{ include "hauth.name" . }}
{{- end -}}

{{- define "heartauth-core.labels" -}}
{{ include "hauth.labels" . }}
{{- end -}}
