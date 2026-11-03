# cyberdrop-dl v10 

Fork of [cyberdrop-dl-patched](https://github.com/Cyberdrop-DL/cyberdrop-dl) version **10.x** in Docker.

## Fast start
```bash
# 1. Set up directory structure 
./setup.sh

# 2. Add links to URLS
# 3. Start up

docker compose run --rm cdl-docker
```

Upon the first launch, an interactive TUI opens. Configuration, database data, and logs are located in `AppData/` on the host.

---

## Structure

```
.
├── docker-compose.yml
├── setup.sh                 # скрипт первичной настройки
├── generate-config.sh       # перегенерация конфига
├── URLs.txt                 # список ссылок для скачивания
├── AppData/                 # persistent-данные контейнера
│   ├── .config/cyberdrop-dl/config.yaml
│   ├── .local/share/cyberdrop-dl/cyberdrop.db
│   ├── .cache/cyberdrop-dl/cache.json
│   └── .local/state/cyberdrop-dl/logs/
└── downloads/               # сюда попадают файлы
```

---

## setup.sh
Sets the download directory (either interactively or via arguments) and generates a basic `config.yaml` file compatible with v10.

**Usage examples:**

```bash
# Interactive mode (defaults to ./downloads)
./setup.sh

# Specify the download directory directly
./setup.sh /mnt/media/downloads

# Via an environment variable
CDL_DOWNLOAD_DIR=/mnt/media/downloads ./setup.sh

# Regenerate only the config file (e.g., after changing the path)
./generate-config.sh /mnt/media/downloads
```

---

## Running

**Interactive TUI (default):**

```bash
docker compose run --rm cdl-docker
```

**Direct download (without TUI):**

```bash
docker compose run --rm cdl-docker cyberdrop-dl download
```

If a `URLs.txt` file exists, it will be automatically passed as the `--input-file` argument.

**Downloading a specific URL (without using `URLs.txt`):**

```bash
docker compose run --rm cdl-docker cyberdrop-dl download "https://bunkr.cr/a/XXXX"
```

---

## Configuration

After running `setup.sh`, the file `AppData/.config/cyberdrop-dl/config.yaml` will contain all default settings. You can edit it to suit your needs:

- **download_folder** — the path for downloads (automatically set by `setup.sh`).
- **logs.level** — the logging level (`DEBUG`, `INFO`, `WARNING`).
- **network.proxy** — HTTP proxy settings.
- **auth.pixeldrain.api_key** — your PixelDrain API key, etc. > Important: Do not change the `logs.folder`, `cache_file`, or `database_file` paths — they are resolved via `XDG_*` variables and are already directed to `AppData/`.

---

## Updating the Image

```bash
docker compose build --no-cache
docker compose run --rm cdl-docker
```

---

## Useful CLI Flags (v10)

| Flag | Description |
|------|-------------|
| `--ignore-history` | Re-download items that have already been downloaded |
| `--no-deep-scrape` | Disable additional scraping |
| `--download-folder /path` | Temporarily override the download path |
| `--input-file urls.txt` | Specify a different file containing URLs |

For the full list, run: `docker compose run --rm cdl-docker cyberdrop-dl download --help`