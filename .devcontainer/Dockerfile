FROM mcr.microsoft.com/devcontainers/base:bullseye

ARG HELM_VERSION="v3.11.0"
ARG HELM_BINARY="linux-amd64/helm"
ARG HELMFILE_VERSION="0.150.0"
ARG HELM_DIFF_VERSION="v3.6.0"
ARG HELM_SECRETS_VERSION="v4.2.2"
ARG HELM_GIT_VERSION="v0.14.3"

ENV DEBIAN_FRONTEND noninteractive

# Install zscalar certificate (requires Quantium network or VPN otherwise will skip)
RUN (sudo wget -O /usr/local/share/ca-certificates/ZscalerRootCertificate.crt https://repo.build.quantium.com.au/artifactory/quantium-certs/ZscalerRootCertificate.crt && \
  sudo update-ca-certificates) || echo "Skipping downloading ZScaler certificate"

# Downloading and installing gcloud
RUN curl https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz > /tmp/google-cloud-sdk.tar.gz && \
  mkdir -p /usr/local/gcloud &&  \
  tar -C /usr/local/gcloud -xvf /tmp/google-cloud-sdk.tar.gz && \
  /usr/local/gcloud/google-cloud-sdk/install.sh

# Adding the gcloud path to local
ENV PATH $PATH:/usr/local/gcloud/google-cloud-sdk/bin

# Install kubectl
RUN gcloud components install kubectl

# Set gcloud config to mapped volumed
ENV CLOUDSDK_CONFIG=/root/.config/gcloud
ENV GOOGLE_APPLICATION_CREDENTIALS=/root/.config/gcloud/application_default_credentials.json

#Helm
RUN wget https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz -O - \
  | tar xz && mv ${HELM_BINARY} /usr/bin/helm

RUN helm plugin install https://github.com/databus23/helm-diff --version ${HELM_DIFF_VERSION} && \
  helm plugin install https://github.com/jkroepke/helm-secrets --version ${HELM_SECRETS_VERSION} && \
  helm plugin install https://github.com/aslafy-z/helm-git.git --version ${HELM_GIT_VERSION}

RUN  wget https://github.com/helmfile/helmfile/releases/download/v${HELMFILE_VERSION}/helmfile_${HELMFILE_VERSION}_linux_amd64.tar.gz -O - \
  | tar xz && mv helmfile /usr/bin/helmfile && \
  rm -f *.tar.gz

ENV DEBIAN_FRONTEND teletype
