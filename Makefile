.PHONY: help build test refresh run

OWNER:=mohitsharma44
UCSL_STACK:=ucsl-image
VERSION:=latest
IMG_NAME:=ucsl
PORT:=8989
GIT_MASTER_HEAD_SHA:=$(shell git rev-parse --short=12 --verify HEAD)

RETRIES:=10

help:
	@printf "\033[0;33mDefault image: mohitsharma44/ucsl-image:\033[0;31m$(VERSION) \033[0m"
	@echo
	@echo "====================="
	@grep -E '^[a-zA-Z0-9_%/-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
	@echo "====================="
	@echo "\033[0;33mReplace % by the image name.\033[0m"
	@echo

build/%: DARGS?=
build/%: ## build the latest image for the ucsl stack
	docker build $(DARGS) --rm --force-rm -t $(OWNER)/$(notdir $@):$(VERSION) ./image

run/%: ## run the docker image pulled from dockerhub
	docker run -d --name $(IMG_NAME) -p $(PORT):8888 $(OWNER)/$(notdir $@)

refresh/%: ## pull the latest image from Docker Hub for a stack
           # skip if error: a stack might not be on dockerhub yet
	-docker pull $(OWNER)/$(notdir $@):$(VERSION)

test/%: ## run the stack and check if the jupyter notebook is alive
	@-docker rm -f $(IMG_NAME)
	@docker run -d --name $(IMG_NAME) -p $(PORT):8888 $(OWNER)/$(notdir $@)
	@echo "Checking for UCSL Server"
	@for i in $$(seq 0 10); do \
		sleep $$i; \
                printf ". "; \
		docker exec $(IMG_NAME) bash -c 'wget --quiet http://localhost:8888 -O- | grep -i jupyter' &> /dev/null; \
		if [ $$? -eq 0 ]; then \
                echo; \
                echo "Server is Up and Running"; \
                exit 0; \
                fi; \
	done; \
        echo "\033[0;31mServer is Not Running\033[0m"; \
        exit 1

## If simply run `make`, return help
.DEFAULT_GOAL := help

build:$(UCSL_STACK:%=build/%)
refresh:$(UCSL_STACK:%=refresh/%)
test:$(UCSL_STACK:%=test/%)
run:$(UCSL_STACK:%=run/%)
