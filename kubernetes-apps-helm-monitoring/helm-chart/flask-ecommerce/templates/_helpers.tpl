{{/*
Expand the name of the chart.
*/}}
{{- define "flask-ecommerce.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "flask-ecommerce.fullname" -}}
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
{{- define "flask-ecommerce.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "flask-ecommerce.labels" -}}
helm.sh/chart: {{ include "flask-ecommerce.chart" . }}
{{ include "flask-ecommerce.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "flask-ecommerce.selectorLabels" -}}
app.kubernetes.io/name: {{ include "flask-ecommerce.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "flask-ecommerce.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "flask-ecommerce.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Database URL
*/}}
{{- define "flask-ecommerce.databaseUrl" -}}
{{- if .Values.postgresql.enabled }}
{{- printf "postgresql://%s:%s@%s-postgresql:5432/%s" .Values.postgresql.auth.username .Values.postgresql.auth.password .Release.Name .Values.postgresql.auth.database }}
{{- else if and .Values.externalDatabase .Values.externalDatabase.url }}
{{- .Values.externalDatabase.url }}
{{- else }}
{{- "sqlite:///app.db" }}
{{- end }}
{{- end }}

{{/*
Redis URL
*/}}
{{- define "flask-ecommerce.redisUrl" -}}
{{- if .Values.redis.enabled }}
{{- printf "redis://:%s@%s-redis-master:6379/0" .Values.redis.auth.password .Release.Name }}
{{- else if and .Values.externalRedis .Values.externalRedis.url }}
{{- .Values.externalRedis.url }}
{{- else }}
{{- "redis://localhost:6379/0" }}
{{- end }}
{{- end }}
