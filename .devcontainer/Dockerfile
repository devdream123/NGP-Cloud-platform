FROM mcr.microsoft.com/devcontainers/base:bullseye

ENV DEBIAN_FRONTEND noninteractive

# Downloading and installing gcloud
RUN curl https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz > /tmp/google-cloud-sdk.tar.gz && \
    mkdir -p /usr/local/gcloud &&  \
    tar -C /usr/local/gcloud -xvf /tmp/google-cloud-sdk.tar.gz && \
    /usr/local/gcloud/google-cloud-sdk/install.sh

# Adding the gcloud path to local
ENV PATH $PATH:/usr/local/gcloud/google-cloud-sdk/bin

# Install kubectl
RUN gcloud components install kubectl

# # Set gcloud config to mapped volumed
ENV CLOUDSDK_CONFIG=/root/.config/gcloud
ENV GOOGLE_APPLICATION_CREDENTIALS=/root/.config/gcloud/application_default_credentials.json

# Install zscalar certificate (requires Quantium network or VPN)
RUN sudo wget -O /usr/local/share/ca-certificates/ZscalerRootCertificate.crt https://repo.build.quantium.com.au/artifactory/quantium-certs/ZscalerRootCertificate.crt && \
  sudo update-ca-certificates

ENV DEBIAN_FRONTEND teletype
