FROM debian:stretch

RUN apt-get update \
    && apt-get install -y wget vim htop tree git libssl-dev curl ruby python3 jq \
    && wget https://bootstrap.pypa.io/get-pip.py \
    && python3 get-pip.py \
    && pip3 install awscli==1.16.169 \
    && pip3 install ansible==2.4.6

RUN wget https://releases.hashicorp.com/terraform/0.11.14/terraform_0.11.14_linux_amd64.zip \
    && unzip terraform_0.11.14_linux_amd64.zip \
    && mv terraform /usr/bin/
