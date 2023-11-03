.PHONY: install run build publish


all: run

install:
	@go install github.com/gohugoio/hugo@v0.97.3

run:
	@hugo server -D

build:
	@hugo --gc
	@mkdir -p public/s/
	@cp -r static/* public/s/
