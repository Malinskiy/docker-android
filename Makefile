OWNER=malinskiy
IMAGE_NAME=docker-android-example
VCS_REF=`git rev-parse --short HEAD`
IMAGE_VERSION=1.0.$(TRAVIS_BUILD_NUMBER)
QNAME=$(OWNER)/$(IMAGE_NAME)
GIT_TAG=$(QNAME):$(VCS_REF)
BUILD_TAG=$(QNAME):$(IMAGE_VERSION)
LATEST_TAG=$(QNAME):latest
ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

build:
	docker build \
		--build-arg VCS_REF=$(VCS_REF) \
		--build-arg IMAGE_VERSION=$(IMAGE_VERSION) \
		-t $(GIT_TAG) .

lint:
	docker run -it --rm -v "$(ROOT_DIR)/Dockerfile:/Dockerfile:ro" redcoolbeans/dockerlint

tag:
	docker tag $(GIT_TAG) $(BUILD_TAG)
	docker tag $(GIT_TAG) $(LATEST_TAG)

login:
	@docker login -u "$(DOCKER_USER)" -p "$(DOCKER_PASS)"

push:
	docker push $(GIT_TAG)
	docker push $(BUILD_TAG)
	docker push $(LATEST_TAG)
