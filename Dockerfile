FROM ghcr.io/actions/actions-runner:2.325.0@sha256:deb54a88ead0a86beedec6ac949e8b28f77478835b9c6434ccc237390a6e3e4f

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
ARG AWS_CLI_VERSION=2.27.43
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWS_CLI_VERSION}.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm awscliv2.zip && \
    rm -rf aws

RUN curl -sL https://deb.nodesource.com/setup_20.x -o /tmp/nodesource_setup.sh && \
    bash /tmp/nodesource_setup.sh && \
    apt-get install -y nodejs && \
    rm /tmp/nodesource_setup.sh

RUN chgrp -R runner /home/runner && \
    chown -R runner:runner /home/runner && \
    mkdir -p /runner && \
    chown -R runner:runner /runner && \
    chmod a+w /usr/bin

COPY ./pre-hook.sh /etc/arc/hooks/pre-hook.sh

ENV ACTIONS_RUNNER_HOOK_JOB_STARTED=/etc/arc/hooks/pre-hook.sh

WORKDIR /

USER runner:runner

# renovate: datasource=github-tags depName=nvm-sh/nvm
ARG NVM_VERSION=0.40.3
RUN wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh | bash && \
    . ~/.nvm/nvm.sh && \
    nvm install 20 && \
    nvm use 20 && \
    nvm alias default node && \
    nvm cache clear && \
    node -v

RUN git clone --depth=1 https://github.com/tofuutils/tofuenv.git ~/.tofuenv