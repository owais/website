.PHONY: run build publish


all: run

run:
	@hugo server -D

build:
	@hugo

publish: build
	make -C public publish
