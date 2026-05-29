#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

generate_overlay() {
	local module overlay

	module="$1"
	namespace="$2"
	overlay="$3"

	overlay_path="$SCRIPT_DIR/$module/overlays/$overlay"

	mkdir -p "$overlay_path"

	cat <<EOF	> "$overlay_path/kustomization.yaml"
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namespace: $namespace

resources:
- ../../../base

labels:
  - pairs:
      app: $module
    includeSelectors: true

patches:
- target:
    kind: Deployment
    name: appname
  patch: |-
    - op: replace
      path: /metadata/name
      value: $module
- target:
    kind: Service
    name: appname
  patch: |-
    - op: replace
      path: /metadata/name
      value: $module
EOF
}

generate_module() {
	local module

	module="$1"

	rm -rf "${SCRIPT_DIR}/${module:?}"

	generate_overlay "$module" hdc-ankalan prod-hdc-active
	generate_overlay "$module" hdc-ankalan prod-hdc-passive
	generate_overlay "$module" mndc-ankalan prod-mndc-active
	generate_overlay "$module" mndc-ankalan prod-mndc-passive
}

generate_dr_module() {
	local module

	module="$1"

	rm -rf "${SCRIPT_DIR}/${module:?}"

	generate_overlay "$module" hdc-ankalan prod-hdc-monitoring
	generate_overlay "$module" hdc-ankalan prod-hdc-recovery
	generate_overlay "$module" hdc-ankalan prod-hdc-replay
	generate_overlay "$module" hdc-ankalan prod-hdc-passive
	generate_overlay "$module" mndc-ankalan prod-mndc-monitoring
	generate_overlay "$module" mndc-ankalan prod-mndc-recovery
	generate_overlay "$module" mndc-ankalan prod-mndc-replay
	generate_overlay "$module" mndc-ankalan prod-mndc-passive
}

generate_all_modules() {
	for module in "${modules[@]}"; do
		generate_module "$module"
	done
}

generate_all_dr_modules() {
	for module in "${dr_modules[@]}"; do
		generate_dr_module "$module"
	done
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

generate_all_modules
generate_all_dr_modules