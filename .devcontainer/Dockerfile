FROM mcr.microsoft.com/devcontainers/python:3.12

## ensure image is up to date
RUN apt update \
    && apt -y upgrade

## https://cloud.google.com/sdk/docs/install-sdk#deb
RUN apt-get install -y apt-transport-https ca-certificates gnupg curl \
    && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
    && apt-get update \
    && apt-get install -y google-cloud-cli

## run init/update script on every new bash terminal
RUN echo 'init_and_update' >> ~vscode/.bashrc

## install dbt's CLI completion
RUN curl https://raw.githubusercontent.com/fishtown-analytics/dbt-completion.bash/master/dbt-completion.bash > ~vscode/.dbt-completion.bash \
    && echo 'source ~vscode/.dbt-completion.bash' >> ~vscode/.bashrc

## install Snyk for security scanning
RUN curl https://static.snyk.io/cli/latest/snyk-linux -o /usr/local/bin/snyk \
    && chmod +x /usr/local/bin/snyk