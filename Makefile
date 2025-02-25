.PHONY: test generate-install install-by-script install docker docker-build docker-shell docker-test all clean linux-brew

# Default target
all: test

# None
clean:
	# TODO

# Test target that runs chezmoi doctor and builds docker-compose
test:
	chezmoi doctor
	chezmoi execute-template --init < './.chezmoi.toml.tmpl'
	chezmoi execute-template '{{ .osid }}'
	# TODO: Add docker build

# Install chezmoi by downloading script
install-by-script:
	# TODO

# Install chezmoi the recommended way
install: 
	sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply GatlenCulp

# Generate install.sh script
generate-install:
	chezmoi generate install.sh > install.sh
	chmod a+x install.sh
	echo install.sh >> .chezmoiignore
	git add install.sh .chezmoiignore
	git commit -m "chore(install): Update install.sh"

# Generate and run docker image for testing
docker-build:
	docker build --platform linux/amd64 -t chezmoi-test-ubuntu -f ./docker/chezmoi-ubuntu.Dockerfile .

# Run an interactive shell in the container
docker-shell: docker-build
	docker run -it chezmoi-test-ubuntu /bin/bash

# Run the chezmoi test
docker-test: docker-build
	docker run -it chezmoi-test-ubuntu sh -c 'sh -c "$$(curl -fsLS get.chezmoi.io)" -- init --apply GatlenCulp && eza || exit 1'

# Build and run interactive shell (default)
docker: docker-shell

docker-osx:
	docker build --platform linux/amd64 -t chezmoi-test-osx -f ./docker/chezmoi-osx.Dockerfile .
	docker run -it --entrypoint=/bin/sh chezmoi-test-osx -c 'sh -c "$$(curl -fsLS get.chezmoi.io)" -- init --apply GatlenCulp && eza || exit 1'

linux-brew:
	# Install Linuxbrew
	RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

	# Add Linuxbrew to PATH
	ENV PATH="/home/linuxbrew/.linuxbrew/bin:${PATH}"
	ENV HOMEBREW_NO_AUTO_UPDATE=1