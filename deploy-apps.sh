#!/bin/bash

kubectl_apply() {
	local module namespace overlay prefix

	module="$1"
	namespace="$2"
	overlay="$3"
	prefix="$4"


	kubectl apply -f - <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: $prefix-$module
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

dr_modules=(
	ankalan-dr
)

modules=(
ankalan
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
		kubectl_apply "$module" hdc-ankalan prod-hdc-active hdc
		kubectl_apply "$module" mndc-ankalan prod-mndc-passive mndc
	done
}

apply_all_dr_modules() {
	for module in "${modules[@]}"; do
		kubectl_apply "$module" hdc-ankalan prod-hdc-monitoring hdc
		kubectl_apply "$module" mndc-ankalan prod-mndc-active mndc
	done
}

apply_all_modules
