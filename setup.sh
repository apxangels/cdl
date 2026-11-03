#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

APPDATA_DIR="${SCRIPT_DIR}/AppData"
IMAGE="apxangels/cdl-docker:10.0"
CONFIG_ONLY=false

# Parse arguments
if [ "${1:-}" == "--config-only" ]; then
    CONFIG_ONLY=true
    shift
fi

if [ $# -ge 1 ]; then
    DOWNLOAD_DIR="$1"
elif [ -n "${CDL_DOWNLOAD_DIR:-}" ]; then
    DOWNLOAD_DIR="$CDL_DOWNLOAD_DIR"
else
    DOWNLOAD_DIR="${SCRIPT_DIR}/downloads"
fi

# Build image if missing
if ! docker image inspect "$IMAGE" &>/dev/null; then
    echo "Образ $IMAGE не найден локально. Собираем..."
    docker compose build
fi

# Create directory structure
mkdir -p "${APPDATA_DIR}/.config/cyberdrop-dl"
mkdir -p "${APPDATA_DIR}/.local/share/cyberdrop-dl"
mkdir -p "${APPDATA_DIR}/.cache/cyberdrop-dl"
mkdir -p "${APPDATA_DIR}/.local/state/cyberdrop-dl/logs"
mkdir -p "${DOWNLOAD_DIR}"

# Generate config
CONFIG_FILE="${APPDATA_DIR}/.config/cyberdrop-dl/config.yaml"
echo "Генерация конфигурации..."
docker run --rm -e COLUMNS=999 "$IMAGE" cyberdrop-dl config new \
    | sed 's|download_folder: downloads/cyberdrop-dl|download_folder: /cyberdrop-dl/downloads|g' \
    > "${CONFIG_FILE}"

if [ "$CONFIG_ONLY" = true ]; then
    echo "Конфиг обновлён: ${CONFIG_FILE}"
    exit 0
fi

# Create URLs.txt if missing
if [ ! -f "${SCRIPT_DIR}/URLs.txt" ]; then
    touch "${SCRIPT_DIR}/URLs.txt"
    echo "Создан ${SCRIPT_DIR}/URLs.txt — добавьте ссылки для скачивания."
fi

echo ""
echo "Готово."
echo "  AppData:   ${APPDATA_DIR}"
echo "  Downloads: ${DOWNLOAD_DIR}"
echo ""
echo "Запуск интерактивного TUI:"
echo "  docker compose run --rm cdl-docker"
echo ""
echo "Запуск без TUI (прямое скачивание):"
echo "  docker compose run --rm cdl-docker cyberdrop-dl download"
