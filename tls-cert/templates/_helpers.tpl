{{- define "tlscert.name" -}}
{{- .Chart.Name -}}
{{- end -}}

{{- define "tlscert.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- include "tlscert.name" . -}}
{{- end -}}
{{- end -}}

{{- define "tlscert.labels" -}}
app.kubernetes.io/name: {{ include "tlscert.name" . }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Values.commonLabels }}
{{- toYaml .Values.commonLabels | nindent 0 }}
{{- end }}
{{- end -}}

{{/* Build the dnsNames list:
     - optional root (base)
     - base + each subdomain
     - any extraDnsNames
*/}}
{{- define "tlscert.dnsNames" -}}
{{- $names := list -}}
{{- if .Values.domain.includeRoot -}}
{{- $names = append $names .Values.domain.base -}}
{{- end -}}
{{- range $sd := .Values.domain.subdomains }}
{{- $names = append $names (printf "%s.%s" $sd $.Values.domain.base) -}}
{{- end -}}
{{- range $x := .Values.extraDnsNames }}
{{- $names = append $names $x -}}
{{- end -}}
{{- join "\n" (uniq $names) -}}
{{- end -}}
