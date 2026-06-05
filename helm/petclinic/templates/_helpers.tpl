{{/*
Generate a fullname for a component: <release>-<component>
*/}}
{{- define "petclinic.fullname" -}}
{{- printf "%s-%s" .Release.Name .component | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels for a component.
Usage: include "petclinic.labels" (dict "Release" .Release "Chart" .Chart "component" "config-server")
*/}}
{{- define "petclinic.labels" -}}
app.kubernetes.io/name: {{ .component }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" }}
{{- end -}}

{{/*
Selector labels for a component.
Usage: include "petclinic.selectorLabels" (dict "Release" .Release "component" "config-server")
*/}}
{{- define "petclinic.selectorLabels" -}}
app.kubernetes.io/name: {{ .component }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Resolve image reference for a service.
Usage: include "petclinic.image" (dict "service" .Values.configServer "global" .Values.global "defaultName" "spring-petclinic-config-server")
*/}}
{{- define "petclinic.image" -}}
{{- $registry := .global.imageRegistry -}}
{{- $tag := .global.imageTag -}}
{{- $repo := printf "%s/%s" $registry .defaultName -}}
{{- if .service.image.repository -}}
  {{- $repo = .service.image.repository -}}
{{- end -}}
{{- if .service.image.tag -}}
  {{- $tag = .service.image.tag -}}
{{- end -}}
{{- printf "%s:%s" $repo $tag -}}
{{- end -}}

{{/*
Init container that waits for config-server to be healthy.
Usage: include "petclinic.initContainers.waitForConfigServer" .
*/}}
{{- define "petclinic.initContainers.waitForConfigServer" -}}
- name: wait-for-config-server
  image: busybox:1.36
  command:
    - sh
    - -c
    - 'until wget -qO- http://{{ .Release.Name }}-config-server:8888/actuator/health | grep UP; do sleep 2; done'
{{- end -}}

{{/*
Init container that waits for discovery-server to be healthy.
Usage: include "petclinic.initContainers.waitForDiscoveryServer" .
*/}}
{{- define "petclinic.initContainers.waitForDiscoveryServer" -}}
- name: wait-for-discovery-server
  image: busybox:1.36
  command:
    - sh
    - -c
    - 'until wget -qO- http://{{ .Release.Name }}-discovery-server:8761/actuator/health | grep UP; do sleep 2; done'
{{- end -}}

{{/*
Both init containers for downstream services (config + discovery).
Usage: include "petclinic.initContainers.waitForDependencies" .
*/}}
{{- define "petclinic.initContainers.waitForDependencies" -}}
{{ include "petclinic.initContainers.waitForConfigServer" . }}
{{ include "petclinic.initContainers.waitForDiscoveryServer" . }}
{{- end -}}
