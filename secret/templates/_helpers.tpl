{{- define "secret-bundle.name" -}}
{{- default (printf "%s-secret" .Chart.Name) .Values.name -}}
{{- end -}}