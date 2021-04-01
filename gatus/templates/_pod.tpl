{{- define "gatus.pod" -}}
{{- if .Values.hostNetwork.enabled }}
hostNetwork: true
{{- end }}
{{- if .Values.image.pullSecrets }}
imagePullSecrets:
  {{- range .Values.image.pullSecrets }}
  - name: {{ . }}
  {{- end }}
{{- end }}
securityContext:
  {{- toYaml .Values.podSecurityContext | nindent 8 }}
containers:
  - name: {{ .Chart.Name }}
    securityContext:
      {{- toYaml .Values.securityContext | nindent 12 }}
    image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
    imagePullPolicy: {{ .Values.image.pullPolicy }}
    ports:
      - name: http
        containerPort: 8080
        protocol: TCP
    {{- if .Values.env }}
    env:
    {{- range $key, $value := .Values.env }}
        - name: "{{ $key }}"
          value: "{{ $value }}"
    {{- end }}
    {{- end }}
    envFrom:
      - configMapRef:
          name: {{ include "gatus.fullname" . }}
      {{- if .Values.secrets }}
      - secretRef:
          name: {{ include "gatus.fullname" . }}
      {{- end }}
    {{- if .Values.readinessProbe.enabled }}
    readinessProbe:
      httpGet:
        path: /health
        port: http
    {{- end }}
    {{- if .Values.livenessProbe.enabled }}
    livenessProbe:
      httpGet:
        path: /health
        port: http
    {{- end }}
    resources:
{{ toYaml .Values.resources | trim | indent 6 }}
    volumeMounts:
      - name: {{ template "gatus.fullname" . }}-config
        mountPath: /config
volumes:
  - name: {{ template "gatus.fullname" . }}-config
    configMap:
      name: {{ template "gatus.fullname" . }}
{{- with .Values.nodeSelector }}
nodeSelector:
{{ toYaml . | indent 8 }}
{{- end }}
{{- end }}
