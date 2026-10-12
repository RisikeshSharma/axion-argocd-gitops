{{/*
Expand the name of the chart.
*/}}
{{- define "axion.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "axion.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "axion.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "axion.labels" -}}
helm.sh/chart: {{ include "axion.chart" . }}
{{ include "axion.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "axion.selectorLabels" -}}
app.kubernetes.io/name: {{ include "axion.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
PostgreSQL Service Name
*/}}
{{- define "axion.postgresServiceName" -}}
{{- default "postgres-service" .Values.postgres.service.name }}
{{- end }}

{{/*
Ingestion Service Name
*/}}
{{- define "axion.ingestionServiceName" -}}
{{- default "ingestion-service" .Values.ingestion.service.name }}
{{- end }}

{{/*
Telemetry Query Service Name
*/}}
{{- define "axion.telemetryQueryServiceName" -}}
{{- default "telemetry-query-service" .Values.telemetryQuery.service.name }}
{{- end }}

{{/*
UI Service Name
*/}}
{{- define "axion.uiServiceName" -}}
{{- default "axion-ui-service" .Values.ui.service.name }}
{{- end }}

{{/*
Construct PostgreSQL Database URL
Format: postgresql://<user>:<password>@<host>:<port>/<db>
*/}}
{{- define "axion.databaseUrl" -}}
{{- if .Values.postgres.externalDatabase.enabled }}
{{- .Values.postgres.externalDatabase.url }}
{{- else }}
{{- printf "postgresql://%s:%s@%s:%d/%s" .Values.postgres.auth.username (.Values.postgres.auth.password | urlquery) (include "axion.postgresServiceName" .) (int .Values.postgres.service.port) .Values.postgres.auth.database }}
{{- end }}
{{- end }}
