.ONESHELL:
PHONY: build-kernel build-image install help

build-kernel:
	./build-kernel.sh;\

build-image:
	./build-image.sh;\

install:
	pipenv install;\
	pipenv install --dev;\

check:
	pre-commit run --all-files;\

help:
	@echo "    help:"
	@echo "        Show this help."
	@echo "    build-kernel:"
	@echo "        Build kernel RPM/SRPM packages."
	@echo "    build-image:"
	@echo "        Build installation media."
	@echo "    install:"
	@echo "        Install requirements."
	@echo "    check:"
	@echo "        Perform some code checks."
