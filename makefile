RUNNER_REGISTRATION_TOKEN_FOR_GITLAB = glrt-4zhalLNl2EjojspVcLa7A286MQp0OjEKdToxCw.01.120v8rop8
CLEAN_VOLUME ?= false


install:
	minikube start --driver=docker --memory=2500 --cpus=2 --static-ip=192.168.200.200 --listen-address=0.0.0.0 --ports=8443:8443 --insecure-registry="gitlab:5005" && true
	docker-compose -f "$(PWD)/docker/docker-compose.yml" up --build -d && true



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
	docker network rm minikube


checkedIntegrationRunnerWithMinikube:
	docker exec -it gitlab-runner curl -k https://minikube:8443/livez
	docker exec -it gitlab-runner kubectl get nodes
	docker exec -it gitlab-runner kubectl auth can-i create deployments
	curl http://localhost:5005/v2/

createAuthTokenRunnerForMinikube:
	kubectl create serviceaccount gitlab-admin || true
	kubectl create clusterrolebinding gitlab-admin-binding --clusterrole=cluster-admin --serviceaccount=default:gitlab-admin || true
	kubectl create token gitlab-admin --duration=8760h


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
