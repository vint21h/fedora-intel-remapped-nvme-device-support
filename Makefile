# fedora-intel-remapped-nvme-device-support
# Makefile

.ONESHELL:
PHONY: shellcheck help


shellcheck:
	find -type f -regex ".*\.\w*sh" | xargs shellcheck;\


help:
	@echo "    help:"
	@echo "        Show this help."
	@echo "    shellcheck:"
	@echo "        Run ShellCheck on scripts."
