NAME = gupalo/php

.PHONY: all build release

all: build

build:
	docker build -t $(NAME) --rm --pull .

release:
	docker push $(NAME):latest
