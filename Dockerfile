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
    tzdata \
    wget

# renovate: datasource=github-tags depName=aws/aws-cli
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


RUN wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash && \
    echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc && \
    echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> ~/.bashrc


RUN git clone --depth=1 https://github.com/tofuutils/tofuenv.git ~/.tofuenv && \
    echo 'export PATH="$HOME/.tofuenv/bin:$PATH"' >> ~/.bashrc && \
    echo 'eval "$(tofuenv init -)"' >> ~/.bashrc && \
    echo 'export TOFUENV_ROOT="$HOME/.tofuenv"' >> ~/.bashrc 

COPY ./pre-hook.sh /etc/arc/hooks/pre-hook.sh

ENV ACTIONS_RUNNER_HOOK_JOB_STARTED=/etc/arc/hooks/pre-hook.sh

USER runner:runner
