CERT_VERSION=v1.8.0
ISTIO_VERSION=1.14.1
SELDON_VERSION=1.14.0

.PHONY: init
init: helm_add_repo init_kind install_metrics install_cert_manager install_istio install_seldon

.PHONY: helm_add_repo
helm_add_repo:
	helm repo add jetstack https://charts.jetstack.io
	helm repo add seldonio https://storage.googleapis.com/seldon-charts
	helm repo update

.PHONY: init_kind
init_kind:
	kind create cluster --config ./config.yml

.PHONY:  install_metrics
install_metrics:
	kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

.PHONY: install_cert_manager
install_cert_manager:
	kubectl create namespace cert-manager
	helm upgrade --install \
	cert-manager jetstack/cert-manager \
	--namespace cert-manager \
	--version $(CERT_VERSION) \
	--set installCRDs=true

.PHONY: install_istio
install_istio:
	curl -L https://istio.io/downloadIstio | ISTIO_VERSION=$(ISTIO_VERSION) TARGET_ARCH=$(uname -a|awk '{print $15}') sh -
	cd istio-$(ISTIO_VERSION) &&\
	./bin/istioctl install --set profile=demo --set values.gateways.istio-ingressgateway.type=NodePort -y

.PHONY: install_istio_via_helm
install_istio_via_helm:
	kubectl create namespace istio-system
	helm install istio-base istio/base --version $(ISTIO_VERSION) -n istio-system
	helm install istiod istio/istiod --version $(ISTIO_VERSION) -n istio-system
	helm install gateway istio/gateway --version $(ISTIO_VERSION) -n istio-system

.PHONY: install_seldon
install_seldon:
	kubectl create namespace seldon-system
	helm upgrade --install seldon-core seldon-core-operator \
	--repo https://storage.googleapis.com/seldon-charts \
	--set ambassador.enabled=false \
	--set usageMetrics.enabled=true \
	--set certManager.enabled=true \
	--set istio.enabled=true \
	--version $(SELDON_VERSION) \
	--namespace seldon-system

.PHONY: iris
iris:
	kubectl create namespace seldon
	kubectl apply -f iris-deploy.yml

.PHONY: forward
forward: 
	nohup kubectl port-forward svc/iris-model-default-classifier 9000:9000 -n seldon >/dev/null 2>&1 &
.PHONY: test
test: forward
	@sleep 1
	curl -s POST http://localhost:9000/api/v1.0/predictions \
	    -H 'Content-Type: application/json' \
	    -d '{ "data": { "ndarray": [[1,2,3,4]] } }'|jq

.PHONY: clean
clean:
	kind delete cluster --name seldon
	rm -rf istio-$(ISTIO_VERSION)