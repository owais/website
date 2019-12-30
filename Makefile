.PHONY: run build publish


all: run

run:
	@hugo server -D

build:
	@hugo --gc
	@mkdir -p public/s/
	@cp -r static/* public/s/

publish: build
	make -C public publish
