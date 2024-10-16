FROM debian:buster-slim

ENV GITHUB_OWNER=""
ENV GITHUB_REPOSITORY=""
ENV RUNNER_WORKDIR="_work"
ENV RUNNER_LABELS=""
ENV ADDITIONAL_PACKAGES=""
ENV GH_RUNNER_VERSION="2.320.0"

RUN apt-get update \
    && apt-get install -y \
        curl \
        sudo \
        git \
        jq \
        iputils-ping \
    && useradd -m github \
    && usermod -aG sudo github \
    && curl -L -o /usr/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 \
    && chmod +x /usr/bin/yq \
    && echo "%sudo ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

WORKDIR /home/github

RUN GH_RUNNER_VERSION=$GH_RUNNER_VERSION \
    && curl -L -O https://github.com/actions/runner/releases/download/v${GH_RUNNER_VERSION}/actions-runner-linux-x64-${GH_RUNNER_VERSION}.tar.gz \
    && tar -zxf actions-runner-linux-x64-${GH_RUNNER_VERSION}.tar.gz \
    && rm -f actions-runner-linux-x64-${GH_RUNNER_VERSION}.tar.gz \
    && ./bin/installdependencies.sh \
    && chown -R github: /home/github \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && apt-get clean

COPY entrypoint.sh /home/github/entrypoint.sh
RUN chmod +x /home/github/entrypoint.sh

USER github
ENTRYPOINT ["/home/github/entrypoint.sh"]
