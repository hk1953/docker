.PHONY: build test refresh

OWNER:=mohitsharma44

UCSL_STACK:=ucsl-image

GIT_MASTER_HEAD_SHA:=$(shell git rev-parse --short=12 --verify HEAD)

RETRIES:=10

_build/%: DARGS?=
_build/%: ## build the latest image for the ucsl stack
	docker build $(DARGS) --rm --force-rm -t $(OWNER)/$(notdir $@):latest ./$(notdir $@)

_refresh/%: ## pull the latest image from Docker Hub for a stack
           # skip if error: a stack might not be on dockerhub yet
	-docker pull $(OWNER)/$(notdir $@):latest

_test/%: ## run a stack container, check for jupyter server liveliness
	@-docker rm -f iut
	@docker run -d --name iut $(OWNER)/$(notdir $@)
	@echo "Testing if UCSL server is Up"
	@for i in $$(seq 0 9); do \
		sleep $$i; \
                echo "."; \
		docker exec iut bash -c 'wget http://localhost:8888 -O- | grep -i jupyter' &> /dev/null; \
		if [[ $$? == 0 ]]; then \
                echo "Server is Up and Running"; \
                exit 0; \
                fi; \
	done; \
        echo "Server is Not Running"; \
        exit 1

build:$(UCSL_STACK:%=_build/%)
refresh:$(UCSL_STACK:%=_refresh/%)
test:$(UCSL_STACK:%=_test/%)