{{/*
Common labels for all resources
*/}}
{{- define "microservice.commonLabels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: service
{{- end }}

{{/*
Selector labels for deployments and services
*/}}
{{- define "microservice.selectorLabels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Container spec template
*/}}
{{- define "microservice.container" -}}
- name: {{ .Chart.Name }}
  image: "{{ .Values.global.image.registry }}/{{ .Values.image.repository }}:{{ .Values.image.tag }}"
  imagePullPolicy: {{ .Values.image.pullPolicy }}
  {{- if .Values.securityContext }}
  securityContext:
    {{- toYaml .Values.securityContext | nindent 4 }}
  {{- end }}
  ports:
    - containerPort: {{ .Values.service.port }}
  env:
    {{- range $key, $value := .Values.env }}
    - name: {{ $key }}
      value: {{ $value | quote }}
    {{- end }}
  resources:
    {{- toYaml .Values.resources | nindent 4 }}
  {{- if .Values.livenessProbe }}
  livenessProbe:
    {{- toYaml .Values.livenessProbe | nindent 4 }}
  {{- end }}
  {{- if .Values.readinessProbe }}
  readinessProbe:
    {{- toYaml .Values.readinessProbe | nindent 4 }}
  {{- end }}
{{- end }}

{{/*
Pod spec template
*/}}
{{- define "microservice.podSpec" -}}
{{- if .Values.affinity }}
affinity:
  {{- toYaml .Values.affinity | nindent 2 }}
{{- end }}
{{- if .Values.podSecurityContext }}
securityContext:
  {{- toYaml .Values.podSecurityContext | nindent 2 }}
{{- end }}
tolerations:
  {{- if .Values.tolerations }}
  {{- toYaml .Values.tolerations | nindent 2 }}
  {{- else if .Values.global.tolerations }}
  {{- toYaml .Values.global.tolerations | nindent 2 }}
  {{- end }}
containers:
  {{- include "microservice.container" . | nindent 2 }}
{{- end }}
