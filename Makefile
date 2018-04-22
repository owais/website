.PHONY: run build publish


all: run

run:
	@hugo server -D

build:
	@hugo --gc

publish: build
	make -C public publish
