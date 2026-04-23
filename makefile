RUNNER_REGISTRATION_TOKEN_FOR_GITLAB = glrt-H5uEV-vTpapO2xqPY0yFMG86MQp0OjEKdToxCw.01.121aoajwz
CLEAN_VOLUME ?= false
PATH_FOR_CERT_MINIKUBE="$$HOME/minikube_ca.crt"
PATH_FOR_RUNNER_TOKEN="$$HOME/runner_token.txt"
PATH_FOR_VAULT_TOKEN="$$HOME/vault_token.txt"


install:
	@echo "Удаляем старые серты с хоста..."
	rm -f "$(PATH_FOR_CERT_MINIKUBE)"
	rm -f "$(PATH_FOR_RUNNER_TOKEN)"
	rm -f "$(PATH_FOR_VAULT_TOKEN)"


	@echo "Поднимаем инфраструктуру..."
	minikube start --driver=docker --memory=2500 --cpus=2 --static-ip=192.168.200.200 --listen-address=0.0.0.0 --ports=8443:8443 --insecure-registry="gitlab:5005" --embed-certs && true
	docker-compose -f "$(PWD)/docker/docker-compose.yml" up --build -d && true


	@echo "Пробрасываем сертификат Minikube в Vault..."
	kubectl get secret $(kubectl get sa default -o jsonpath='{.secrets[0].name}') -o jsonpath='{.data.ca\.crt}' | base64 --decode > "$(PATH_FOR_CERT_MINIKUBE)" && true
	
	@if [ -f "$(PATH_FOR_CERT_MINIKUBE)" ]; then \
		echo "$(PATH_FOR_CERT_MINIKUBE) существует. Копируем..."; \
		docker cp "$(PATH_FOR_CERT_MINIKUBE)" vault-server:/vault/minikube_ca.crt; \
	else \
		echo "$(PATH_FOR_CERT_MINIKUBE) не найден. Прерываю..."; \
		exit 1; \
	fi


	@echo "Создаем токены доступа в Minikube для Gitlab-Runner/Vault..."
	$(MAKE) createAuthTokenRunnerForMinikube
	$(MAKE) createAuthTokenVaultForMinikube

	@if [ -f "$(PATH_FOR_RUNNER_TOKEN)" ]; then \
		echo "$(PATH_FOR_RUNNER_TOKEN) существует. Копируем..."; \
	else \
		echo "$(PATH_FOR_RUNNER_TOKEN) не найден. Прерываю..."; \
		exit 1; \
	fi

	@if [ -f "$(PATH_FOR_VAULT_TOKEN)" ]; then \
		echo "$(PATH_FOR_VAULT_TOKEN) существует. Копируем..."; \
	else \
		echo "$(PATH_FOR_VAULT_TOKEN) не найден. Прерываю..."; \
		exit 1; \
	fi


	@echo "Включаем необходимые плагины в Minikube..."
	minikube addons enable ingress && true


status:
	docker ps -a
	minikube status
	docker network inspect minikube


stop:
	docker-compose stop
	minikube stop


clean:
	@CONTAINERS=$$(docker ps -aq); \
	if [ -n "$$CONTAINERS" ]; then \
		docker rm -f $$CONTAINERS; \
	else \
		echo "Контейнеров для удаления не найдено."; \
	fi

	if [ "$(CLEAN_VOLUME)" == "true"]; then \
		@echo "--- ОЧИЩАЕМ VOLUMES ---"; \
		docker volume prune -f; \
	fi

	minikube delete
	# Удаляем всё, кроме папки cache
	rm -rf ~/.minikube/machines
	rm -rf ~/.minikube/profiles
	rm -rf ~/.minikube/config
	rm -rf ~/.minikube/certs


checkedIntegrationRunnerWithMinikube:
	docker exec -it gitlab-runner curl -k https://minikube:8443/livez
	docker exec -it gitlab-runner kubectl get nodes
	docker exec -it gitlab-runner kubectl auth can-i create deployments
	curl http://localhost:5005/v2/

createAuthTokenRunnerForMinikube:
	kubectl create serviceaccount gitlab-admin || true
	kubectl create clusterrolebinding gitlab-admin-binding --clusterrole=cluster-admin --serviceaccount=default:gitlab-admin || true
	kubectl create token gitlab-admin --duration=8760h > "$(PATH_FOR_RUNNER_TOKEN)"

createAuthTokenVaultForMinikube:
	kubectl create serviceaccount vault-auth
	kubectl create clusterrolebinding vault-auth-binding --clusterrole=system:auth-delegator --serviceaccount=default:vault-auth
	kubectl create token vault-auth --duration=8760h > "$(PATH_FOR_VAULT_TOKEN)"


chainedRunnerWithGitlab:
	docker exec -it gitlab-runner getent hosts gitlab
	docker exec -it gitlab-runner gitlab-runner register \
       --non-interactive \
       --url "http://gitlab" \
       --registration-token "$(RUNNER_REGISTRATION_TOKEN_FOR_GITLAB)" \
       --executor "docker" \
       --docker-image "alpine:latest" \
       --description "my-runner-ubuntu-2404" \
       --tag-list "docker,ubuntu" \
       --run-untagged="true" \
       --locked="false" \
       --docker-network-mode minikube \
       --access-level="not_protected"
