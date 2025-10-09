FROM ghcr.io/actions/actions-runner:2.328.0@sha256:db0dcae6d28559e54277755a33aba7d0665f255b3bd2a66cdc5e132712f155e0

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
ARG AWS_CLI_VERSION=2.31.11
RUN ARCH=$([ "$TARGETARCH" = "arm64" ] && echo "aarch64" || echo "x86_64") && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-${ARCH}-${AWS_CLI_VERSION}.zip" -o "awscliv2.zip" && \
    unzip -qq awscliv2.zip && \
    ./aws/install && \
    rm awscliv2.zip && \
    rm -rf aws

# renovate: datasource=github-tags depName=mikefarah/yq
ARG YQ_VERSION=4.47.2
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
ENV DOCKER_BUILDX_VERSION="0.29.1"
RUN mkdir -p "$DOCKER_PLUGINS_DIR" && \
  curl -L "https://github.com/docker/buildx/releases/download/v${DOCKER_BUILDX_VERSION}/buildx-v${DOCKER_BUILDX_VERSION}.linux-${TARGETARCH}" -o "$DOCKER_PLUGINS_DIR/docker-buildx" && \
  chmod +x "$DOCKER_PLUGINS_DIR/docker-buildx"

# Install docker compose
# renovate: datasource=github-tags depName=docker/compose
ENV DOCKER_COMPOSE_VERSION="2.40.0"
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
RUN curl -sL https://deb.nodesource.com/setup_lts.x -o /tmp/nodesource_setup.sh && \
    bash /tmp/nodesource_setup.sh && \
    apt-get install -y nodejs && \
    rm /tmp/nodesource_setup.sh

# renovate: datasource=github-releases depName=helm/helm
ENV HELM_VERSION=3.19.0
RUN curl -L "https://get.helm.sh/helm-v${HELM_VERSION}-linux-${TARGETARCH}.tar.gz" -o /tmp/helm.tar.gz && \
  mkdir -p /tmp/helm && \
  tar -zxvf /tmp/helm.tar.gz -C /tmp/helm && \
  cp "/tmp/helm/linux-${TARGETARCH}/helm" /usr/local/bin/helm && \
  chmod +x /usr/local/bin/helm

ENV OP_CLI_VERSION=v2.31.1
RUN wget "https://cache.agilebits.com/dist/1P/op2/pkg/${OP_CLI_VERSION}/op_linux_${TARGETARCH}_${OP_CLI_VERSION}.zip" -O op.zip && \
  unzip -qq op.zip && \
  gpg --keyserver keyserver.ubuntu.com --receive-keys 3FEF9748469ADBE15DA7CA80AC2D62742012EA22 && \
  gpg --verify op.sig op && \
  mv op /usr/local/bin/ && \
  rm -r op.zip && \
  groupadd -f onepassword-cli && \
  chgrp onepassword-cli /usr/local/bin/op && \
  chmod g+s /usr/local/bin/op

# renovate: datasource=github-releases depName=anchore/syft
ENV SYFT_VERSION=1.33.0
RUN wget "https://github.com/anchore/syft/releases/download/v${SYFT_VERSION}/syft_${SYFT_VERSION}_linux_${TARGETARCH}.tar.gz" -O syft.tar.gz && \
  tar -xzf syft.tar.gz syft && \
  mv syft /usr/local/bin/syft && \
  rm syft.tar.gz && \
  chmod +x /usr/local/bin/syft

# renovate: datasource=github-releases depName=cyb3r-jak3/cloudflare-utils
ENV CLOUDFLARE_UTILS_VERSION=1.6.0
RUN curl -L "https://github.com/Cyb3r-Jak3/cloudflare-utils/releases/download/v${CLOUDFLARE_UTILS_VERSION}/cloudflare-utils_${CLOUDFLARE_UTILS_VERSION}_linux_${TARGETARCH}.tar.xz" -o /tmp/cloudflare-utils.tar.xz && \
  mkdir -p /tmp/cloudflare-utils && \
  tar -xvf /tmp/cloudflare-utils.tar.xz -C /tmp/cloudflare-utils && \
  cp "/tmp/cloudflare-utils/cloudflare-utils" /usr/local/bin/cloudflare-utils && \
  chmod +x /usr/local/bin/cloudflare-utils

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
