# Remote setup

```sh
sudo apt-get -y install ufw
sudo ufw allow 22/tcp          # SSH
sudo ufw allow 80,443/tcp      # Ingress (Traefik handles this)
sudo ufw allow 6443/tcp        # Kubernetes API server
sudo ufw --force enable

curl -sfL https://get.k3s.io | sh -


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
