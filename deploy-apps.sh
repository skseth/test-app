#!/bin/bash

kubectl_apply() {
	local module overlay

	module="$1"
	namespace="$2"
	overlay="$3"

	kubectl apply -f - <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ankalan
  namespace: argocd
spec:
  project: test
  source:
    repoURL: https://github.com/skseth/test-app.git
    targetRevision: HEAD
    path: $module/overlays/$overlay
  destination:
    server: https://kubernetes.default.svc
    namespace: $namespace
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF
}

modules=(
ankalan
ankalan-dr
cs-api
age-prediction-model
name-matcher-api
smart-qc
dis
print-service
ems
eos
registrar-service
exception-handler-service
mfc
)

apply_all_modules() {
	for module in "${modules[@]}"; do
		kubectl_apply "$module" hdc-ankalan prod-hdc-active
		kubectl_apply "$module" mndc-ankalan prod-mndc-passive
	done
}

