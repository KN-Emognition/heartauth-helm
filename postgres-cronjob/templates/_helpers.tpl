{{- define "postgres-cronjob.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "postgres-cronjob.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- include "postgres-cronjob.name" . -}}
{{- end -}}
{{- end -}}

{{- define "postgres-cronjob.labels" -}}
app.kubernetes.io/name: {{ include "postgres-cronjob.name" . }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Values.commonLabels }}
{{- toYaml .Values.commonLabels | nindent 0 }}
{{- end }}
{{- end -}}

{{- define "postgres-cronjob.sqlConfigMapName" -}}
{{- if .Values.sqlConfigMap.name -}}
{{- .Values.sqlConfigMap.name -}}
{{- else -}}
{{- include "postgres-cronjob.fullname" . }}-sql
{{- end -}}
{{- end -}}

{{- define "postgres-cronjob.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- if .Values.serviceAccount.name -}}
{{ .Values.serviceAccount.name }}
{{- else -}}
{{ include "postgres-cronjob.fullname" . }}
{{- end -}}
{{- else -}}
{{- if .Values.serviceAccount.name -}}
{{ .Values.serviceAccount.name }}
{{- else -}}
default
{{- end -}}
{{- end -}}
{{- end -}}
