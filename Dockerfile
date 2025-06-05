FROM ubuntu:22.04 AS downloader

# Build args to select terraformer providers and terraformer/terraform versions
ARG TERRAFORMER_PROVIDER=google
ARG TERRAFORMER_VERSION=0.8.30
ARG TERRAFORM_VERSION=1.12.1

RUN apt update
RUN apt install -y curl unzip

# Terraform
RUN curl -Lo terraform.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
RUN unzip terraform.zip -d /tmp
RUN chmod +x /tmp/terraform

# Terraformer
RUN curl -Lo /tmp/terraformer "https://github.com/GoogleCloudPlatform/terraformer/releases/download/${TERRAFORMER_VERSION}/terraformer-${TERRAFORMER_PROVIDER}-linux-amd64"
RUN chmod +x /tmp/terraformer


FROM ubuntu:22.04 AS prod

COPY --from=downloader /tmp/terraformer /usr/local/bin/terraformer
COPY --from=downloader /tmp/terraform /usr/local/bin/terraform

ENTRYPOINT ["/usr/local/bin/terraformer"]