.ONESHELL:
default: help
PHONY: install help

install:
	pipenv install;\
	pipenv install --dev;\

check:
	pre-commit run --all-files;\

help:
	@echo "    help:"
	@echo "        Show this help."
	@echo "    install:"
	@echo "        Install requirements."
	@echo "    check:"
	@echo "        Perform some code checks."
