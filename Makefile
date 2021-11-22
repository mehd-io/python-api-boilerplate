PY_MODULE=python_api_boilerplate
PROJECT_NAME=python-api-boilerplate
# Google
REGION=europe-west1
GOOGLE_PROJECT=gcr.io/$(GCP_PROJECT)
PORT=3001
DOCKER_LAYER?=dev
DOCKER_REGISTRY=$(GOOGLE_PROJECT)/$(PROJECT_NAME)
DOCKER_LAYER_VERSION=$(shell ./docker/version.sh ${DOCKER_LAYER})
BASE_LAYER_VERSION=$(shell ./docker/version.sh base)

DOCKER_VOLUMES_MOUNT?= -v $(shell pwd):$(DOCKER_WORKDIR) 
DOCKERIZED=docker run -p $(PORT):$(PORT) $(DOCKER_VOLUMES_MOUNT) $(DOCKER_REGISTRY):$(DOCKER_LAYER_VERSION) 
DOCKER_WORKDIR=/app
MAKEFLAGS += $(if $(value VERBOSE),,--no-print-directory)

#---TEST---
test:
	$(DOCKERIZED) make _test

_test:
	make test-isort && \
	make test-black && \
	make test-unit

test-unit:
	pytest tests -vvv $(PY_MODULE) 

test-black:
	black $(PY_MODULE) --check

test-isort:
	isort -c $(PY_MODULE)

#--DEV--
format:
	$(DOCKERIZED) make _format

_format:
	make black && \
	make isort

black: 
	black $(PY_MODULE) tests

isort:
	isort .  

#--Docker Helpers

push-img:
	docker push $(DOCKER_REGISTRY):$(DOCKER_LAYER_VERSION)

pull-img:
	docker pull $(DOCKER_REGISTRY):$(DOCKER_LAYER_VERSION)

_build-img:
	docker build \
	-t $(DOCKER_REGISTRY):$(DOCKER_LAYER_VERSION) \
	-t $(PROJECT_NAME).local:$(DOCKER_LAYER_VERSION) \
	--build-arg BASE_LAYER_VERSION=$(BASE_LAYER_VERSION) \
	--build-arg DOCKER_REGISTRY=$(DOCKER_REGISTRY) \
	-f docker/$(DOCKER_LAYER).Dockerfile ./

get-img:
	@echo 🐳 $@
	@if [ "$$DOCKER_LAYER" != "base" ]; then\
		echo 🔨 Pulling/Building base image first...; \
		$(MAKE)pull-img DOCKER_LAYER=base || $(MAKE) _build-img DOCKER_LAYER=base;\
	 fi;\
	 $(MAKE) pull-img || $(MAKE) _build-img 
	@if [ "$$PUSH_IMAGE" = "true" ]; then\
		echo ✨ Pushing the images to docker registry...; \
		$(MAKE) push-img DOCKER_LAYER=base; \
		$(MAKE) push-img ; \
	 fi;\

#-- Gcloud helpers
gcloud-docker-auth:
	[ -f "${GOOGLE_APPLICATION_CREDENTIALS}" ] && cat ${GOOGLE_APPLICATION_CREDENTIALS} | docker login -u _json_key --password-stdin https://gcr.io || make gcloud-docker-auth-cli

gcloud-docker-auth-cli:
	gcloud auth configure-docker

get-app-image-registry:
	@echo $(DOCKER_REGISTRY):$(shell ./docker/version.sh app)

#--Cloud Run
deploy:
	@$(DOCKERIZED) gcloud run deploy $(PROJECT_NAME) --image $(DOCKER_REGISTRY):$(DOCKER_LAYER_VERSION) \
					--platform managed \
					--project $(GCP_PROJECT) \
					--memory "1Gi" \
					--region $(REGION) 

destroy:
	@$(DOCKERIZED) gcloud run services delete $(PROJECT_NAME) \
				--region $(REGION) \
				--platform managed 

#--APP--
run-app:
	$(DOCKERIZED) uvicorn --host 0.0.0.0 --port ${PORT} $(PY_MODULE).api:app