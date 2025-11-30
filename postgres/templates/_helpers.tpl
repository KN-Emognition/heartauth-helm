{{- define "postgres.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "postgres.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- include "postgres.name" . -}}
{{- end -}}
{{- end -}}

{{- define "postgres.labels" -}}
app.kubernetes.io/name: {{ include "postgres.name" . }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Values.commonLabels }}
{{- toYaml .Values.commonLabels | nindent 0 }}
{{- end }}
{{- end -}}


{{- define "postgres.sql_squote" -}}
{{- (replace "'" "''" .) -}}
{{- end -}}

{{- define "postgres.defaultInitSql" -}}
DO
$$BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = '{{ .Values.db.user }}') THEN
    EXECUTE format('CREATE ROLE %I LOGIN PASSWORD %L', '{{ .Values.db.user }}', '{{ include "postgres.sql_squote" .Values.db.password }}');
  END IF;
END$$;

DO
$$BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = '{{ .Values.db.name }}') THEN
    EXECUTE format('CREATE DATABASE %I OWNER %I', '{{ .Values.db.name }}', '{{ .Values.db.user }}');
  END IF;
END$$;

ALTER DATABASE "{{ .Values.db.name }}" OWNER TO "{{ .Values.db.user }}";
GRANT CREATE ON DATABASE "{{ .Values.db.name }}" TO "{{ .Values.db.user }}";
{{- end -}}
