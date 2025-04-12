FROM ghcr.io/actions/actions-runner:2.323.0

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
    python3-pip \
    ssh \
    tzdata

ARG AWS_CLI_VERSION=2.26.0
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWS_CLI_VERSION}.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm awscliv2.zip && \
    rm -rf aws

## Install OpenTofu


RUN curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh &&\
    chmod +x install-opentofu.sh && \
    ./install-opentofu.sh --install-method standalone && \
    rm -f install-opentofu.sh


USER runner:runner
