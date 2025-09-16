SERVICES := auth-webclient postgres redis keycloak-iam

CHART_auth-webclient   := oci://ghcr.io/icoretech/charts/nextjs
VALUES_auth-webclient  := services/auth-webclient/values.yaml
NAMESPACE_auth-webclient:= default

CHART_postgres    := oci://registry-1.docker.io/bitnamicharts/postgresql
VALUES_postgres   := services/postgres/values.yaml
NAMESPACE_postgres:= default

CHART_redis := oci://registry-1.docker.io/bitnamicharts/redis
VALUES_redis:= services/redis/values.yaml
NAMESPACE_redis:= default

CHART_keycloak-iam   := oci://registry-1.docker.io/bitnamicharts/keycloak
VALUES_keycloak-iam  := services/keycloak-iam/values.yaml
NAMESPACE_keycloak-iam:= default

CHART_svc5   := oci://ghcr.io/OWNER/charts/svc5
VALUES_svc5  := values/svc5.yaml
NAMESPACE_svc5:= default

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
	helm upgrade --install "$$svc" "$$chart" -n "$$ns" --create-namespace -f "$$values" $(HELM_DEPLOY_FLAGS)  --timeout 12m0s
