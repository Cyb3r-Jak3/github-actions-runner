FROM ghcr.io/actions/actions-runner:2.326.0@sha256:9c3383600872325f21951a0a1a8ae640361ff5e1abdf1f2900de8ba1cfd915e9

ARG TARGETARCH

USER root:root

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends --no-install-suggests \
    git \
    curl \
    jq \
    unzip \
    zip \
    python3 \
    python3-pip \
    ssh \
    tzdata \
    wget


WORKDIR /tmp
# renovate: datasource=github-tags depName=aws/aws-cli
ARG AWS_CLI_VERSION=2.27.49
RUN ARCH=$([ "$TARGETARCH" = "arm64" ] && echo "aarch64" || echo "x86_64") && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-${ARCH}-${AWS_CLI_VERSION}.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm awscliv2.zip && \
    rm -rf aws

# renovate: datasource=github-tags depName=mikefarah/yq
ARG YQ_VERSION=4.45.4
RUN wget https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_${TARGETARCH} -O /usr/local/bin/yq &&\
    chmod +x /usr/local/bin/yq

# renovate: datasource=github-tags depName=terraform-docs/terraform-docs
ARG TERRAFORM_DOCS_VERSION=0.20.0
RUN curl -sSLo ./terraform-docs.tar.gz https://terraform-docs.io/dl/v${TERRAFORM_DOCS_VERSION}/terraform-docs-v${TERRAFORM_DOCS_VERSION}-$(uname)-amd64.tar.gz && \
    tar -xzf terraform-docs.tar.gz && \
    chmod +x terraform-docs && \
    mv terraform-docs /usr/local/bin/terraform-docs && \
    rm terraform-docs.tar.gz

RUN mkdir -m 777 /root/.ssh; \
  touch -m 777 /root/.ssh/known_hosts; \
  ssh-keyscan github.com > /root/.ssh/known_hosts

ENV DOCKER_PLUGINS_DIR="/usr/local/lib/docker/cli-plugins"

# Install docker buildx
# renovate: datasource=github-tags depName=docker/buildx
ENV DOCKER_BUILDX_VERSION="0.25.0"
RUN mkdir -p "$DOCKER_PLUGINS_DIR" && \
  curl -L "https://github.com/docker/buildx/releases/download/v${DOCKER_BUILDX_VERSION}/buildx-v${DOCKER_BUILDX_VERSION}.linux-${TARGETARCH}" -o "$DOCKER_PLUGINS_DIR/docker-buildx" && \
  chmod +x "$DOCKER_PLUGINS_DIR/docker-buildx"

# Install docker compose
# renovate: datasource=github-tags depName=docker/compose
ENV DOCKER_COMPOSE_VERSION="2.38.1"
RUN ARCH=$([ "$TARGETARCH" = "arm64" ] && echo "aarch64" || echo "x86_64") && \ 
  mkdir -p "$DOCKER_PLUGINS_DIR" && \
  curl -SL "https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-linux-${ARCH}" -o "$DOCKER_PLUGINS_DIR/docker-compose" && \
  chmod +x "$DOCKER_PLUGINS_DIR/docker-compose" && \
  ln -s "$DOCKER_PLUGINS_DIR/docker-compose" "/usr/local/bin/docker-compose"

# renovate: datasource=github-releases depName=tofuutils/tofuenv
ARG TOFUENV_VERSION=1.0.7
RUN curl -sL "https://github.com/tofuutils/tofuenv/archive/v${TOFUENV_VERSION}.tar.gz" | tar -xz && \
    ln -s /tmp/tofuenv-${TOFUENV_VERSION}/bin/* /usr/local/bin/ && \
    chown -R runner /tmp/tofuenv-${TOFUENV_VERSION} && \
    chmod -R +rw /tmp/tofuenv-${TOFUENV_VERSION}

# Install Node.js
RUN curl -sL https://deb.nodesource.com/setup_20.x -o /tmp/nodesource_setup.sh && \
    bash /tmp/nodesource_setup.sh && \
    apt-get install -y nodejs && \
    rm /tmp/nodesource_setup.sh

# renovate: datasource=github-releases depName=helm/helm
ENV HELM_VERSION=3.18.4
RUN curl -L "https://get.helm.sh/helm-v${HELM_VERSION}-linux-${TARGETARCH}.tar.gz" -o /tmp/helm.tar.gz && \
  mkdir -p /tmp/helm && \
  tar -zxvf /tmp/helm.tar.gz -C /tmp/helm && \
  cp "/tmp/helm/linux-${TARGETARCH}/helm" /usr/local/bin/helm && \
  chmod +x /usr/local/bin/helm

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

# Sanity to ensure programs are installed correctly
RUN tofuenv list-remote && \
    terraform-docs --version && \
    yq --version && \
    aws --version && \
    docker buildx version && \
    docker compose version && \
    node -v  && \
    helm version