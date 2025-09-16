SERVICES := keycloak-iam auth-webclient postgres redis 

CHART_auth-webclient     := oci://ghcr.io/icoretech/charts/nextjs
VALUES_auth-webclient    := services/auth-webclient/values.yaml
NAMESPACE_auth-webclient := default

# groundhog2k chart is classic (non-OCI) -> needs repo add/update
CHART_postgres     := groundhog2k/postgres
VALUES_postgres    := services/postgres/values.yaml
NAMESPACE_postgres := default

# OCI charts (no repo add needed)
CHART_redis        := oci://registry-1.docker.io/cloudpirates/redis
VALUES_redis       := services/redis/values.yaml
NAMESPACE_redis    := default

CHART_keycloak-iam     := barravar/keycloak
VALUES_keycloak-iam    := services/keycloak-iam/values.yaml
NAMESPACE_keycloak-iam := default

HELM_DEPLOY_FLAGS ?= --atomic --wait --timeout 10m
HELM_TPL_FLAGS    ?=

.PHONY: repos template deploy $(SERVICES) template-% deploy-%

repos:
	@helm repo add barravar https://barravar.github.io/helm-charts
	@helm repo add groundhog2k https://groundhog2k.github.io/helm-charts/ >/dev/null 2>&1 || true
	@helm repo update >/dev/null

template: repos $(addprefix template-,$(SERVICES))
deploy:   repos $(addprefix deploy-,$(SERVICES))

template-%:
	@svc="$*"; ns="$(NAMESPACE_$*)"; chart="$(CHART_$*)"; values="$(VALUES_$*)"; \
	echo "==> templating $$svc (ns=$$ns)"; \
	case "$$chart" in groundhog2k/*) helm repo update >/dev/null ;; esac; \
	mkdir -p rendered; \
	helm template "$$svc" "$$chart" -n "$$ns" -f "$$values" $(HELM_TPL_FLAGS) > "rendered/$$svc.yaml"

deploy-%:
	@svc="$*"; ns="$(NAMESPACE_$*)"; chart="$(CHART_$*)"; values="$(VALUES_$*)"; \
	echo "==> deploying $$svc (ns=$$ns)"; \
	case "$$chart" in groundhog2k/*) helm repo update >/dev/null ;; esac; \
	helm upgrade --install "$$svc" "$$chart" -n "$$ns" --create-namespace -f "$$values" $(HELM_DEPLOY_FLAGS)
