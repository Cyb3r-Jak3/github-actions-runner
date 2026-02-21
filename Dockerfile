FROM ghcr.io/actions/actions-runner:2.331.0@sha256:dced476aa42703ebd9aafc295ce52f160989c4528e831fc3be2aef83a1b3f6da

ARG TARGETARCH

USER root:root

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends --no-install-suggests \
    git \
    curl \
    dirmngr\ 
    jq \
    gpg \
    unzip \
    zip \
    python3 \
    python3-pip \
    ssh \
    tar \
    tzdata \
    xz-utils \
    wget


WORKDIR /tmp
# renovate: datasource=github-tags depName=aws/aws-cli
ARG AWS_CLI_VERSION=2.33.27
RUN ARCH=$([ "$TARGETARCH" = "arm64" ] && echo "aarch64" || echo "x86_64") && \
  curl -sSL "https://awscli.amazonaws.com/awscli-exe-linux-${ARCH}-${AWS_CLI_VERSION}.zip" -o "awscliv2.zip" && \
  unzip -qq awscliv2.zip && \
  ./aws/install && \
  rm awscliv2.zip && \
  rm -rf aws

# renovate: datasource=github-releases depName=mikefarah/yq
ARG YQ_VERSION=4.52.4
RUN curl -sSL https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_${TARGETARCH} -o /usr/local/bin/yq &&\
  chmod +x /usr/local/bin/yq

# renovate: datasource=github-releases depName=terraform-docs/terraform-docs
ARG TERRAFORM_DOCS_VERSION=0.21.0
RUN curl -sSL -o ./terraform-docs.tar.gz https://terraform-docs.io/dl/v${TERRAFORM_DOCS_VERSION}/terraform-docs-v${TERRAFORM_DOCS_VERSION}-$(uname)-amd64.tar.gz && \
  tar -xzf terraform-docs.tar.gz && \
  chmod +x terraform-docs && \
  mv terraform-docs /usr/local/bin/terraform-docs && \
  rm terraform-docs.tar.gz

RUN mkdir -m 777 /root/.ssh; \
  touch -m 777 /root/.ssh/known_hosts; \
  ssh-keyscan github.com > /root/.ssh/known_hosts

ENV DOCKER_PLUGINS_DIR="/usr/local/lib/docker/cli-plugins"

# Install docker buildx
# renovate: datasource=github-releases depName=docker/buildx
ENV DOCKER_BUILDX_VERSION="0.31.1"
RUN mkdir -p "$DOCKER_PLUGINS_DIR" && \
  curl -sSL "https://github.com/docker/buildx/releases/download/v${DOCKER_BUILDX_VERSION}/buildx-v${DOCKER_BUILDX_VERSION}.linux-${TARGETARCH}" -o "$DOCKER_PLUGINS_DIR/docker-buildx" && \
  chmod +x "$DOCKER_PLUGINS_DIR/docker-buildx"

# Install docker compose
# renovate: datasource=github-releases depName=docker/compose
ENV DOCKER_COMPOSE_VERSION="5.0.2"
RUN ARCH=$([ "$TARGETARCH" = "arm64" ] && echo "aarch64" || echo "x86_64") && \ 
  mkdir -p "$DOCKER_PLUGINS_DIR" && \
  curl -sSL "https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-linux-${ARCH}" -o "$DOCKER_PLUGINS_DIR/docker-compose" && \
  chmod +x "$DOCKER_PLUGINS_DIR/docker-compose" && \
  ln -s "$DOCKER_PLUGINS_DIR/docker-compose" "/usr/local/bin/docker-compose"

# renovate: datasource=github-releases depName=tofuutils/tenv
ARG TENV_VERSION=4.9.3
RUN ARCH=$([ "$TARGETARCH" = "arm64" ] && echo "arm64" || echo "x86_64") && \
  curl -sSL "https://github.com/tofuutils/tenv/releases/download/v${TENV_VERSION}/tenv_v${TENV_VERSION}_Linux_${ARCH}.tar.gz" -o /tmp/tenv.tar.gz && \
  tar -xzf /tmp/tenv.tar.gz -C /tmp && \
  mv /tmp/tenv /usr/local/bin/tenv && \
  chmod +x /usr/local/bin/tenv && \
  rm /tmp/tenv.tar.gz && \
  tenv completion bash > ~/.tenv.completion.bash && \
  echo "source \$HOME/.tenv.completion.bash" >> ~/.bashrc
ENV TENV_AUTO_INSTALL=true

# Install Node.js
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  curl -sSL https://deb.nodesource.com/setup_lts.x -o /tmp/nodesource_setup.sh && \
  bash /tmp/nodesource_setup.sh && \
  apt-get install -y nodejs && \
  rm /tmp/nodesource_setup.sh

# renovate: datasource=github-releases depName=helm/helm
ENV HELM_VERSION=4.1.1
RUN curl -sSL "https://get.helm.sh/helm-v${HELM_VERSION}-linux-${TARGETARCH}.tar.gz" -o /tmp/helm.tar.gz && \
  mkdir -p /tmp/helm && \
  tar -zxvf /tmp/helm.tar.gz -C /tmp/helm && \
  cp "/tmp/helm/linux-${TARGETARCH}/helm" /usr/local/bin/helm && \
  chmod +x /usr/local/bin/helm

# renovate: depName=1password-cli
ENV OP_CLI_VERSION=2.32.1
RUN curl -sSL https://downloads.1password.com/linux/keys/1password.asc | gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" | tee /etc/apt/sources.list.d/1password.list && \
    apt-get update && \
    apt-get install -y 1password-cli=${OP_CLI_VERSION}*

# renovate: datasource=github-releases depName=anchore/syft
ENV SYFT_VERSION=1.42.1
RUN curl -sSL "https://github.com/anchore/syft/releases/download/v${SYFT_VERSION}/syft_${SYFT_VERSION}_linux_${TARGETARCH}.tar.gz" -o syft.tar.gz && \
  tar -xzf syft.tar.gz syft && \
  mv syft /usr/local/bin/syft && \
  rm syft.tar.gz && \
  chmod +x /usr/local/bin/syft

# renovate: datasource=github-releases depName=cyb3r-jak3/cloudflare-utils
ENV CLOUDFLARE_UTILS_VERSION=1.6.1
RUN curl -sSL "https://github.com/Cyb3r-Jak3/cloudflare-utils/releases/download/v${CLOUDFLARE_UTILS_VERSION}/cloudflare-utils_linux_${TARGETARCH}" -o /usr/local/bin/cloudflare-utils && \
  chmod +x /usr/local/bin/cloudflare-utils

# renovate: datasource=github-releases depName=sigstore/cosign
ENV COSIGN_VERSION=3.0.5
RUN curl -sSL "https://github.com/sigstore/cosign/releases/download/v${COSIGN_VERSION}/cosign-linux-${TARGETARCH}" -o /usr/local/bin/cosign && \
  chmod +x /usr/local/bin/cosign

WORKDIR /

COPY ./pre-hook.sh /etc/arc/hooks/pre-hook.sh

ENV ACTIONS_RUNNER_HOOK_JOB_STARTED=/etc/arc/hooks/pre-hook.sh

RUN chgrp -R runner /home/runner && \
  chown -R runner /home/runner && \
  mkdir -p /runner && \
  chgrp -R runner /runner && \
  chown -R runner /runner && \
  chmod a+w -R /usr/bin

USER runner:runner
