{{/*
Common deployment template for microservices
*/}}
{{- define "microservice.deployment" -}}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-{{ .Chart.Name }}
  labels:
    {{- include "microservice.commonLabels" . | nindent 4 }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      {{- include "microservice.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "microservice.commonLabels" . | nindent 8 }}
    spec:
      {{- include "microservice.podSpec" . | nindent 6 }}
{{- end }}
