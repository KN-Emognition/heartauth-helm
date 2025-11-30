{{- define "kafka.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "kafka.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- include "kafka.name" . -}}
{{- end -}}
{{- end -}}

{{- define "kafka.labels" -}}
app.kubernetes.io/name: {{ include "kafka.name" . }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Values.commonLabels }}
{{- toYaml .Values.commonLabels | nindent 0 }}
{{- end }}
{{- end -}}

{{/* kafka.controllerQuorumVoters: builds "0@<pod-0>.<headless>:9093,1@<pod-1>.<headless>:9093,..." */}}
{{- define "kafka.controllerQuorumVoters" -}}
{{- $replicas := int (default 1 .Values.replicas) -}}
{{- $name     := include "kafka.fullname" . -}}
{{- $headless := default (printf "%s-headless" $name) .Values.service.headlessName -}}
{{- $port     := int (default 9093 .Values.service.controllerPort) -}}
{{- $entries  := list -}}
{{- range $i, $_ := until $replicas -}}
  {{- $entry := printf "%d@%s-%d.%s:%d" $i $name $i $headless $port -}}
  {{- $entries = append $entries $entry -}}
{{- end -}}
{{ join "," $entries }}
{{- end -}}
