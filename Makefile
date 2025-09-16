# ========= CONFIGURE YOUR 5 SERVICES HERE =========
SERVICES := auth-webclient

# For each service, set its chart URL (OCI) and values file path
CHART_auth-webclient   := oci://ghcr.io/icoretech/charts/nextjs
VALUES_auth-webclient  := services/auth-webclient/values.yaml
NAMESPACE_auth-webclient:= default

CHART_api    := oci://ghcr.io/OWNER/charts/api
VALUES_api   := values/api.yaml
NAMESPACE_api:= default

CHART_worker := oci://ghcr.io/OWNER/charts/worker
VALUES_worker:= values/worker.yaml
NAMESPACE_worker:= default

CHART_svc4   := oci://ghcr.io/OWNER/charts/svc4
VALUES_svc4  := values/svc4.yaml
NAMESPACE_svc4:= default

CHART_svc5   := oci://ghcr.io/OWNER/charts/svc5
VALUES_svc5  := values/svc5.yaml
NAMESPACE_svc5:= default
# ==================================================

# Helm flags you might want to tweak once (applied to every service)
HELM_DEPLOY_FLAGS ?= --atomic --wait --timeout 10m
HELM_TPL_FLAGS    ?=

.PHONY: template deploy $(SERVICES) template-% deploy-%

# Render all services to ./rendered/<svc>.yaml
template: $(addprefix template-,$(SERVICES))

template-%:
	@svc="$*"; \
	ns="$(NAMESPACE_$*)"; \
	chart="$(CHART_$*)"; \
	values="$(VALUES_$*)"; \
	echo "==> templating $$svc (ns=$$ns)"; \
	mkdir -p rendered; \
	helm template "$$svc" "$$chart" -n "$$ns" -f "$$values" $(HELM_TPL_FLAGS) > "rendered/$$svc.yaml"

# Upgrade/Install all services
deploy: $(addprefix deploy-,$(SERVICES))

deploy-%:
	@svc="$*"; \
	ns="$(NAMESPACE_$*)"; \
	chart="$(CHART_$*)"; \
	values="$(VALUES_$*)"; \
	echo "==> deploying $$svc (ns=$$ns)"; \
	helm upgrade --install "$$svc" "$$chart" -n "$$ns" --create-namespace -f "$$values" $(HELM_DEPLOY_FLAGS)
