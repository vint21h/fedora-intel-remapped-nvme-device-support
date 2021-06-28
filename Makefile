# fedora-intel-remapped-nvme-device-support
# Makefile

.ONESHELL:
PHONY: shellcheck build-kernel build-image help


shellcheck:
	find -type f -regex ".*\.\w*sh" | xargs shellcheck;\


build-kernel:
	./build-kernel.sh;\


build-image:
	./build-image.sh;\


help:
	@echo "    help:"
	@echo "        Show this help."
	@echo "    shellcheck:"
	@echo "        Run ShellCheck on scripts."
	@echo "    build-kernel:"
	@echo "        Build kernel RPM/SRPM packages."
	@echo "    build-image:"
	@echo "        Build installation media."
