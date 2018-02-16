PUSH_REGISTRY?=$$(grep "DEFAULT_PUSH_REGISTRY" constants.sh | cut -d'=' -f 2)
PULL_REGISTRY?=$$(grep "DEFAULT_PULL_REGISTRY" constants.sh | cut -d'=' -f 2)
ORGANIZATION?=$$(grep "DEFAULT_ORGANIZATION" constants.sh | cut -d'=' -f 2)
DOCKERFILE?=Dockerfile
DEFAULT_TAG?=latest

.PHONY: all docker-build docker-tag docker-push docker-run-infra-tests get-image-tag get-formatted-build-arg get-push-registry get-short-commit-hash

all:
	npm install --production

docker-build:
	docker build --no-cache -t $(PUSH_REGISTRY)/$(ORGANIZATION)/$(REPOSITORY):$(TAG) $(BUILD_ARGS) -f $(DOCKERFILE) .

docker-tag:
	docker tag $(PUSH_REGISTRY)/$(ORGANIZATION)/$(REPOSITORY):$(S_TAG) $(PUSH_REGISTRY)/$(ORGANIZATION)/$(REPOSITORY):$(T_TAG)

docker-push:
	docker push $(PUSH_REGISTRY)/$(ORGANIZATION)/$(REPOSITORY):$(TAG)

docker-run-infra-tests:
	docker run -ti $(PUSH_REGISTRY)/$(ORGANIZATION)/$(REPOSITORY):$(TAG) cico_tests/run_infra_tests.sh $(PARAMS)

get-image-tag:
    ifdef APP_VERSION
        ifdef NODE_VERSION
            ifdef NPM_VERSION
			@echo ${APP_VERSION}_node_$(NODE_VERSION)_npm_$(NPM_VERSION)
            else
			@echo $(DEFAULT_TAG)
            endif
        else
		@echo $(DEFAULT_TAG)
        endif
    else
        ifdef NODE_VERSION
            ifdef NPM_VERSION
			@echo $(NODE_VERSION)_npm_$(NPM_VERSION)
            else
			@echo $(DEFAULT_TAG)
            endif
        else
		@echo $(DEFAULT_TAG)
        endif
    endif

get-formatted-build-arg:
	@echo --build-arg $(BUILD_ARG_NAME)=$(BUILD_ARG_VALUE)

get-push-registry:
	@echo $(PUSH_REGISTRY)

get-short-commit-hash:
	@echo $(shell git rev-parse --short=7 HEAD)
