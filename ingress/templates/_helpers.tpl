{{- define "ingtf.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "ingtf.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- include "ingtf.name" . -}}
{{- end -}}
{{- end -}}

{{- define "ingtf.labels" -}}
app.kubernetes.io/name: {{ include "ingtf.name" . }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Values.commonLabels }}
{{- toYaml .Values.commonLabels | nindent 0 }}
{{- end }}
{{- end -}}

{{/* Unique host list from routes */}}
{{- define "ingtf.hosts" -}}
{{- $hs := dict -}}
{{- range .Values.routes }}
  {{- $_ := set $hs .host true -}}
{{- end }}
{{- $list := list -}}
{{- range $k, $_ := $hs }}
  {{- $list = append $list $k -}}
{{- end }}
{{- join "\n" $list -}}
{{- end -}}
