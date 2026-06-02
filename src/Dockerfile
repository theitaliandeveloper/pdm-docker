FROM debian:trixie

LABEL org.opencontainers.image.title="Proxmox Datacenter Manager"
LABEL org.opencontainers.image.description="Proxmox Datacenter Manager under Docker"
LABEL org.opencontainers.image.source="https://github.com/willmortimer/proxmox-datacenter-manager-docker"

ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NOWARNINGS=yes

# Force dpkg non-interactive behavior
RUN echo 'DPkg::options { "--force-confdef"; "--force-confnew"; };' > /etc/apt/apt.conf.d/99force-conf

# Upgrade system
RUN apt-get update && apt-get upgrade -y

# Install system dependencies
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    ca-certificates \
    curl \
    iproute2 \
    rsyslog \
    openssl \
    procps \
    --no-install-recommends && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Proxmox Datacenter Manager
RUN echo 'deb http://download.proxmox.com/debian/pdm trixie pdm-no-subscription' \
        > /etc/apt/sources.list.d/pdm.list && \
    wget -qO /etc/apt/trusted.gpg.d/proxmox-release-trixie.gpg \
        https://enterprise.proxmox.com/debian/proxmox-release-trixie.gpg && \
    apt-get update && \
    apt-get install -y \
        proxmox-datacenter-manager \
        proxmox-datacenter-manager-ui \
        --no-install-recommends && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Create required directories and set permissions
RUN mkdir -p \
        /var/lib/pdm \
        /var/lib/proxmox-datacenter-manager \
        /etc/proxmox-datacenter-manager \
        /var/log/proxmox-datacenter-manager \
        /run/proxmox-datacenter && \
    chown www-data:www-data \
        /var/lib/pdm \
        /var/lib/proxmox-datacenter-manager \
        /etc/proxmox-datacenter-manager && \
    chmod 1770 \
        /etc/proxmox-datacenter-manager && \
    chown root:root \
        /var/log/proxmox-datacenter-manager

# Copy and set entrypoint
COPY start-pdm.sh /usr/local/bin/start-pdm.sh
RUN chmod +x /usr/local/bin/start-pdm.sh

# Trying to fix rsyslog
COPY rsyslog.conf /etc/rsyslog.conf

# Password fix
RUN echo 'root:pdm' | chpasswd

EXPOSE 8443

VOLUME /var/lib/pdm
VOLUME /var/lib/proxmox-datacenter-manager
VOLUME /etc/proxmox-datacenter-manager

ENTRYPOINT ["/usr/local/bin/start-pdm.sh"]
