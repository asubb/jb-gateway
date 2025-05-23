FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -yq \
    openssh-server \
    sudo \
    curl \
    iputils-ping \
    net-tools \
    git \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    host \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Docker CLI
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce-cli && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/sshd

# Create jb-gateway user with home directory
RUN useradd -m -d /home/jb-gateway -s /bin/bash jb-gateway && \
    echo "jb-gateway:password" | chpasswd && \
    usermod -aG sudo jb-gateway && \
    echo "jb-gateway ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Copy scripts
COPY entrypoint.sh /entrypoint.sh
COPY host-ssh.sh /usr/local/bin/host-ssh
RUN chmod +x /entrypoint.sh /usr/local/bin/host-ssh

EXPOSE 22

CMD ["/entrypoint.sh"]