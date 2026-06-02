#!/bin/bash
cat <<'EOF'
██████╗ ██████╗  ██████╗ ██╗  ██╗███╗   ███╗ ██████╗ ██╗  ██╗
██╔══██╗██╔══██╗██╔═══██╗╚██╗██╔╝████╗ ████║██╔═══██╗╚██╗██╔╝
██████╔╝██████╔╝██║   ██║ ╚███╔╝ ██╔████╔██║██║   ██║ ╚███╔╝
██╔═══╝ ██╔══██╗██║   ██║ ██╔██╗ ██║╚██╔╝██║██║   ██║ ██╔██╗
██║     ██║  ██║╚██████╔╝██╔╝ ██╗██║ ╚═╝ ██║╚██████╔╝██╔╝ ██╗
╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝

██████╗  █████╗ ████████╗ █████╗  ██████╗███████╗███╗   ██╗████████╗███████╗██████╗
██╔══██╗██╔══██╗╚══██╔══╝██╔══██╗██╔════╝██╔════╝████╗  ██║╚══██╔══╝██╔════╝██╔══██╗
██║  ██║███████║   ██║   ███████║██║     █████╗  ██╔██╗ ██║   ██║   █████╗  ██████╔╝
██║  ██║██╔══██║   ██║   ██╔══██║██║     ██╔══╝  ██║╚██╗██║   ██║   ██╔══╝  ██╔══██╗
██████╔╝██║  ██║   ██║   ██║  ██║╚██████╗███████╗██║ ╚████║   ██║   ███████╗██║  ██║
╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝ ╚═════╝╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝╚═╝  ╚═╝

███╗   ███╗ █████╗ ███╗   ██╗ █████╗  ██████╗ ███████╗██████╗
████╗ ████║██╔══██╗████╗  ██║██╔══██╗██╔════╝ ██╔════╝██╔══██╗
██╔████╔██║███████║██╔██╗ ██║███████║██║  ███╗█████╗  ██████╔╝
██║╚██╔╝██║██╔══██║██║╚██╗██║██╔══██║██║   ██║██╔══╝  ██╔══██╗
██║ ╚═╝ ██║██║  ██║██║ ╚████║██║  ██║╚██████╔╝███████╗██║  ██║
╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝
EOF

echo "PDM Docker setup script by Vichingo455."
URL_STABLE="https://git.vichingo455.qzz.io/Vichingo455/pdm-docker/raw/branch/main/src/docker-compose.yml"
URL_NIGHTLY="https://git.vichingo455.qzz.io/Vichingo455/pdm-docker/raw/branch/main/src/docker-compose.nightly.yml"
COMPOSE_URL=$URL_STABLE
DRY_RUN=false
OUTPUT_FILE="docker-compose.yml"
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --nightly)
            COMPOSE_URL=$URL_NIGHTLY
            echo "Nightly option detected, will use nightly container. This container is updated when commits are detected and stability is not guaranteed."
            ;;
        --dry-run)
            DRY_RUN=true
            echo "Dry run option detected, will download the docker compose without running the container."
            ;;
        --help)
            echo "Usage: $0 [--nightly] [--dry-run]"
            echo "--nightly: downloads the container auto-compiled from commits."
            echo "--dry-run: downloads the docker compose file without running the container."
            exit 0
            ;;
        *)
            echo "Unrecognized option: $1"
            echo "Usage: $0 [--nightly] [--dry-run]"
            echo "--nightly: downloads the container auto-compiled from commits."
            echo "--dry-run: downloads the docker compose file without running the container."
            exit 1
            ;;
    esac
    shift
done

echo "Checking internet connection..."
if ! ping -c 1 -W 2 google.com &> /dev/null; then
    echo "No internet connection, aborting!"
    exit 1
else
    echo "We're internet connected, proceeding..."
fi

echo "Checking if sudo needs to be installed..."
if ! command -v sudo &> /dev/null; then
    echo "Sudo is not installed, installing now..."
    if apt update; then
        if apt install curl -y; then
            echo "Sudo has been installed, proceeding..."
        else
            echo "Error while installing sudo, aborting..."
            exit 1
        fi
    else
        echo "Error while installing sudo, aborting..."
        exit 1
    fi
else
    echo "Sudo is already installed, proceeding..."
fi

echo "Checking if curl needs to be installed..."
if ! command -v curl &> /dev/null; then
    echo "Curl is not installed, installing now..."
    if sudo apt update; then
        if sudo apt install curl -y; then
            echo "Curl has been installed, proceeding..."
        else
            echo "Error while installing curl, aborting..."
            exit 1
        fi
    else
        echo "Error while installing curl, aborting..."
        exit 1
    fi
else
    echo "Curl is already installed, proceeding..."
fi

echo "Downloading docker compose file..."
if curl -sSL "$COMPOSE_URL" -o "$OUTPUT_FILE"; then
    echo "Downloaded docker compose file."
else
    echo "Error while downloading docker compose file with curl, check if curl is installed correctly and your system is internet connected. Aborting!"
    exit 1
fi

if [ "$DRY_RUN" = false ]; then
    echo "Checking if docker is installed..."
    if ! command -v docker &> /dev/null; then
        echo "Docker is not installed, installing now..."
        if curl -fsSL https://get.docker.com | sudo bash; then
            echo "Docker has been installed successfully, proceeding..."
        else
            echo "Error while installing Docker, aborting..."
            exit 1
        fi
    else
        echo "Docker is already installed, proceeding..."
    fi
    echo "Starting Docker container..."
    if sudo docker compose up -d &> /dev/null; then
        echo "Container started successfully! Check the status of the container running: docker logs proxmox-datacenter-manager"
    else
        echo "Error while starting docker container, aborting!"
        exit 1
    fi
fi