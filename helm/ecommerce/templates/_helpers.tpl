{{- define "ecommerce.name" -}}
{{ .Chart.Name }}
{{- end }}

{{- define "ecommerce.fullname" -}}
{{ printf "%s-%s" .Release.Name .Chart.Name }}
{{- end }}

{{- define "ecommerce.labels" -}}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}
