# Config
RELEASE    := hauth
CHART_PATH := ./heartauth-core
NAMESPACE  := hauth-test
VALUES     := values.yaml
RENDERED   := rendered/core.yaml

# Render manifests to file (no cluster changes)
template:
	helm template $(RELEASE) $(CHART_PATH) \
		-n $(NAMESPACE) -f $(VALUES) > $(RENDERED)

# Dry-run upgrade (renders + validates against cluster)
dry-run:
	helm upgrade --install $(RELEASE) $(CHART_PATH) \
		-n $(NAMESPACE) --create-namespace -f $(VALUES) \
		--debug --dry-run

# Deploy/upgrade to cluster
deploy:
	helm upgrade --install $(RELEASE) $(CHART_PATH) \
		-n $(NAMESPACE) --create-namespace -f $(VALUES)

# Remove release (careful!)
uninstall:
	helm uninstall $(RELEASE) -n $(NAMESPACE)

.PHONY: template dry-run deploy uninstall
