{{/*
Expand the name of the chart.
*/}}
{{- define "pmr-email-sender.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}
