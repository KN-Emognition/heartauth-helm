# Remote setup

```sh
sudo apt-get -y install ufw
sudo ufw allow 22/tcp          # SSH
sudo ufw allow 80,443/tcp      # Ingress (Traefik handles this)
sudo ufw allow 6443/tcp        # Kubernetes API server
sudo ufw --force enable

curl -sfL https://get.k3s.io | sh -
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash


mkdir -p ~/.kube



sudo mkdir -p /etc/rancher/k3s
sudo tee /etc/rancher/k3s/config.yaml >/dev/null <<'YAML'
write-kubeconfig-mode: "0644"
tls-san:
  - hauth.test.poziomk3.pl      # your API hostname
  - 51.91.11.92                 # optional: your public IP
# optional but nice for external discovery:
node-external-ip: 51.91.11.92
YAML


echo 'export KUBECONFIG=$HOME/.kube/config' >> ~/.bashrc
source ~/.bashrc

kubectl get nodes
kubectl get pods -A
```

```sh

SERVER="https://hauth.test.poziomk3.pl:6443"
CA_DATA=$(kubectl config view --raw -o jsonpath='{.clusters[0].cluster.certificate-authority-data}')
TOKEN=$(kubectl -n cicd get secret github-deployer-token -o jsonpath='{.data.token}' | base64 -d)

cat > kubeconfig-github-deployer <<EOF
apiVersion: v1
kind: Config
clusters:
- cluster:
    server: ${SERVER}
    certificate-authority-data: ${CA_DATA}
  name: k3s
contexts:
- context:
    cluster: k3s
    user: github-deployer
  name: k3s
current-context: k3s
users:
- name: github-deployer
  user:
    token: ${TOKEN}
EOF

base64 -w0 kubeconfig-github-deployer > kubeconfig.b64


```

# Certificate

```sh
#!/usr/bin/env bash
set -euo pipefail

EMAIL="karolzajac.0407@gmail.com"
NAMESPACE="hauth-test"
TLS_SECRET_NAME="hauth-tls"

# add as many as you want (LE allows up to 100 names per cert)
DOMAINS=( "hauth-internal.test.poziomk3.pl" "hauth-external.test.poziomk3.pl" "hauth.test.poziomk3.pl" )

echo "[1/4] Ensure ports 80/443 are open (for ACME http-01 + HTTPS)"
if command -v ufw >/dev/null 2>&1; then
  sudo ufw allow 80/tcp || true
  sudo ufw allow 443/tcp || true
  sudo ufw --force enable || true
fi

echo "[2/4] Install Helm if missing"
if ! command -v helm >/dev/null 2>&1; then
  curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

echo "[3/4] Install cert-manager (with CRDs)"
helm repo add jetstack https://charts.jetstack.io >/dev/null
helm repo update >/dev/null
helm upgrade --install cert-manager jetstack/cert-manager \
  --namespace cert-manager --create-namespace \
  --set installCRDs=true

echo "[3.1] Wait for cert-manager to be ready"
kubectl -n cert-manager rollout status deploy/cert-manager --timeout=120s
kubectl -n cert-manager rollout status deploy/cert-manager-webhook --timeout=120s
kubectl -n cert-manager rollout status deploy/cert-manager-cainjector --timeout=120s

echo "[4/4] Create Let’s Encrypt ClusterIssuer (Traefik http-01)"
cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt
spec:
  acme:
    email: ${EMAIL}
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-account-key
    solvers:
      - http01:
          ingress:
            class: traefik
EOF

echo "[4.1] Request SAN certificate for: ${DOMAINS[*]}"
cat <<EOF | kubectl -n "${NAMESPACE}" apply -f -
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: ${TLS_SECRET_NAME}
spec:
  secretName: ${TLS_SECRET_NAME}
  dnsNames:
$(for d in "${DOMAINS[@]}"; do echo "  - ${d}"; done)
  issuerRef:
    name: letsencrypt
    kind: ClusterIssuer
EOF

echo "Done ✅  Requested cert '${TLS_SECRET_NAME}' in ns '${NAMESPACE}' for: ${DOMAINS[*]}"

```
