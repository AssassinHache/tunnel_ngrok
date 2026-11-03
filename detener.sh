#!/usr/bin/env bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
cd "$DIR"

echo "Deteniendo el contenedor del proxy Nginx..."
docker compose down || docker-compose down
echo "Proxy detenido con exito."
