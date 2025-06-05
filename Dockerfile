FROM ubuntu:latest AS downloader

# Build args to select terraformer providers and terraformer/terraform versions
ARG TERRAFORMER_PROVIDER=all
ARG TERRAFORMER_VERSION=0.8.30
ARG TERRAFORM_VERSION=1.12.1

RUN apt update
RUN apt install -y curl unzip

# Install the ca-certificate package
RUN apt-get update && apt-get install -y ca-certificates
# Copy the CA certificate from the context to the build container
COPY your_certificate.crt /usr/local/share/ca-certificates/
# Update the CA certificates in the container
RUN update-ca-certificates

# Terraform
RUN curl -Lo terraform.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
RUN unzip terraform.zip -d /tmp
RUN chmod +x /tmp/terraform

# Terraformer
RUN curl -Lo /tmp/terraformer "https://github.com/GoogleCloudPlatform/terraformer/releases/download/${TERRAFORMER_VERSION}/terraformer-${TERRAFORMER_PROVIDER}-linux-amd64"
RUN chmod +x /tmp/terraformer


FROM ubuntu:22.04 AS prod

ARG UID=101
ARG GID=101
USER root

COPY --from=downloader /tmp/terraformer /usr/local/bin/terraformer
COPY --from=downloader /tmp/terraform /usr/local/bin/terraform

USER $UID

ENTRYPOINT ["/usr/local/bin/terraformer"]