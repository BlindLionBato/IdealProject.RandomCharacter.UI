{{- define "random-character-ui.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else if .Values.nameOverride }}
{{- .Release.Name }}-{{ .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- .Release.Name }}-{{ .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}