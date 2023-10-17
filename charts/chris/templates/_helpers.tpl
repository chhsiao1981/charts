{{/*
TODO
Add validators to make sure that we aren't switching between having innetwork pfcon and not
*/}}

{{/*
Expand the name of the chart.
*/}}
{{- define "chris.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "chris.fullname" -}}
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
{{- define "chris.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "chris.labels" -}}
helm.sh/chart: {{ include "chris.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: chris
{{- end }}

{{- define "cube.labels" -}}
{{ include "chris.labels" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/component: backend
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "chris.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "chris.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
CUBE file storage
--------------------------------------------------------------------------------
In the default configuration, pfcon is configured as "innetwork" and CUBE uses
the volume managed by the pfcon subchart for file storage.
If pfcon is not enabled or not configured as "innetwork" then CUBE needs to create
its own PVC.
*/}}
{{- define "cube.shouldCreateVolume" -}}
{{- if (and .Values.pfcon.enabled .Values.pfcon.pfcon.config.innetwork) -}}
{{- /* no (empty value) */ -}}
{{- else -}}
yes
{{- end }}
{{- end }}

{{- define "cube.filesVolume" -}}
{{- if (include "cube.shouldCreateVolume" .) -}}
{{- /* will be created by ./storage.yml */ -}}
{{ .Release.Name }}-cube-files
{{- else -}}
{{- /* defined in ../../pfcon/templates/storage.yml */ -}}
{{ .Release.Name }}-storebase
{{- end }}
{{- end }}

{{/*
CUBE container common properties
--------------------------------------------------------------------------------
*/}}

{{- define "cube.container" -}}
image: "{{ .Values.cube.image.repository }}:{{ .Values.cube.image.tag | default .Chart.AppVersion }}"
imagePullPolicy: {{ .Values.cube.image.pullPolicy }}
volumeMounts:
  - mountPath: /data
    name: file-storage
envFrom:
  - configMapRef:
      name: {{ .Release.Name }}-cube-config
  - configMapRef:
      name: {{ .Release.Name }}-db-config
  - secretRef:
      name: {{ .Release.Name }}-cube-secrets

env:
  - name: POSTGRES_PASSWORD
    valueFrom:
      secretKeyRef:
        name: {{ .Release.Name }}-postgresql
        key: password
{{/* N.B.: env comes last in this helper, so that more values can be appended to it */}}
{{- end }}


{{- define "cube.pod" -}}
volumes:
  - name: file-storage
    persistentVolumeClaim:
      claimName: {{ include "cube.filesVolume" . }}
{{- if .Values.global.podSecurityContext }}
securityContext:
  {{- toYaml .Values.global.podSecurityContext | nindent 2 }}
{{- end }}
{{- end }}

{{- define "cube.podAffinityWorkaround" -}}
{{ if .Values.cube.enablePodAffinityWorkaround }}
affinity:
  podAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
    - labelSelector:
        matchExpressions:
        - key: app.kubernetes.io/instance
          operator: In
          values:
          - {{ .Release.Name }}-heart
      topologyKey: kubernetes.io/hostname
{{- end }}
{{- end }}

# Since the server deployment is the one which defines the database migrations, everything else
# should start after the server. It's ok for ancillary services to be started late.
{{- define "cube.waitServerReady" -}}
- name: wait-for-server
  image: busybox
  command: ["/bin/sh", "-c"]
  args: ["until wget --spider 'http://{{ .Release.Name }}-heart:8000/api/v1/users/'; do sleep 5; done"]
{{- end }}
