#PAT - Personal Access Token для доступа к Api Gitlab (должен иметь права read_repository/api)
GITLAB_PAT?=root

CLEAN_VOLUME ?= false
PATH_FOR_CERT_MINIKUBE="$$HOME/minikube_ca.crt"
PATH_FOR_RUNNER_TOKEN="$$HOME/runner_token.txt"
PATH_FOR_VAULT_TOKEN="$$HOME/vault_token.txt"

ROOT_VAULT_TOKEN?=root

#ID проекта (где репозитории лежат) в Gitlab - смотрим по пути Settings -> General
PROJECT_ID=2


install:
	@echo "Удаляем старые серты с хоста..."
	rm -f "$(PATH_FOR_CERT_MINIKUBE)"

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

	$(MAKE) createTokensAuto

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



createTokensAuto:

	rm -f "$(PATH_FOR_RUNNER_TOKEN)"
	rm -f "$(PATH_FOR_VAULT_TOKEN)"

	@echo "Создаем токены доступа в Minikube для Gitlab-Runner/Vault..."
	$(MAKE) createAuthTokenRunnerForMinikube
	$(MAKE) createAuthTokenVaultForMinikube

	@if [ -f "$(PATH_FOR_RUNNER_TOKEN)" ]; then \
		echo "$(PATH_FOR_RUNNER_TOKEN) существует. Копируем..."; \
		RUNNER_TOKEN_VALUE=$$(cat $(PATH_FOR_RUNNER_TOKEN) | tr -d '\n\r'); \
		echo "Пытаемся обновить KUBE_TOKEN..."; \
		STATUS=$$(curl --request PUT -s -o /dev/null -w "%{http_code}" \
			--header "PRIVATE-TOKEN: $(GITLAB_PAT)" \
			--header "Content-Type: application/json" \
			--data "{\"value\": \"$$RUNNER_TOKEN_VALUE\", \"masked\": false}" \
			"http://localhost:8080/api/v4/projects/$(PROJECT_ID)/variables/KUBE_TOKEN"); \
		echo "Статус вызова: (код $$STATUS)."; \
		if [ "$$STATUS" != "200" ]; then \
			echo "Переменная не найдена. Создаем через POST..."; \
			STATUS=$$(curl --request POST -s -o /dev/null \
				--header "PRIVATE-TOKEN: $(GITLAB_PAT)" \
				--header "Content-Type: application/json" \
				--data "{\"key\": \"KUBE_TOKEN\", \"value\": \"$$RUNNER_TOKEN_VALUE\", \"masked\": false}" \
				"http://localhost:8080/api/v4/projects/$(PROJECT_ID)/variables"); \
			echo "Статус вызова: (код $$STATUS)."; \
	    else \
			echo "Обновлено успешно."; \
		fi; \
	else \
		echo "$(PATH_FOR_RUNNER_TOKEN) не найден. Прерываю..."; \
		exit 1; \
	fi


	@if [ -f "$(PATH_FOR_VAULT_TOKEN)" ]; then \
		echo "$(PATH_FOR_VAULT_TOKEN) существует. Копируем..."; \
		VAULT_TOKEN_VALUE=$$(cat $(PATH_FOR_VAULT_TOKEN) | tr -d '\n\r'); \
		docker exec -e VAULT_TOKEN=$${ROOT_VAULT_TOKEN} vault-server sh -c " \
			vault write auth/kubernetes/config \
				token_reviewer_jwt="$$VAULT_TOKEN_VALUE" \
    			kubernetes_host="https://minikube:8443" \
    			kubernetes_ca_cert=@/vault/minikube_ca.crt \
    			disable_local_ca_jwt=true \
		" \
	else \
		echo "$(PATH_FOR_VAULT_TOKEN) не найден. Прерываю..."; \
		exit 1; \
	fi

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
	kubectl create serviceaccount vault-auth || true
	kubectl create clusterrolebinding vault-auth-binding --clusterrole=system:auth-delegator --serviceaccount=default:vault-auth || true
	kubectl create token vault-auth --duration=8760h > "$(PATH_FOR_VAULT_TOKEN)"


chainedRunnerWithGitlab:
	docker exec -it gitlab-runner getent hosts gitlab
	docker exec -it gitlab-runner gitlab-runner register \
       --non-interactive \
       --url "http://gitlab" \
       --registration-token "$(GITLAB_PAT)" \
       --executor "docker" \
       --docker-image "alpine:latest" \
       --description "my-runner-ubuntu-2404" \
       --tag-list "docker,ubuntu" \
       --run-untagged="true" \
       --locked="false" \
       --docker-network-mode minikube \
       --access-level="not_protected"


