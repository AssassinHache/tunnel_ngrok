#!/usr/bin/env bash
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
cd "$DIR"

ENV_FILE="$DIR/ngrok.env"

echo "=================================================="
echo "    Iniciador de Túnel Ngrok Unificado (GYM)     "
echo "=================================================="

# 1. Comprobar archivo de configuración local
if [ ! -f "$ENV_FILE" ]; then
    echo "Archivo ngrok.env no encontrado. Creando plantilla..."
    cat << 'EOF' > "$ENV_FILE"
# Configuración para Ngrok
# 1. Tu dominio estático gratis (ejemplo: mi-gimnasio.ngrok-free.app)
NGROK_DOMAIN=""

# 2. Tu authtoken de Ngrok (si aún no lo configuraste en tu sistema)
NGROK_AUTHTOKEN=""
EOF
fi

source "$ENV_FILE"

# Si no tiene dominio asignado, solicitarlo
if [ -z "$NGROK_DOMAIN" ]; then
    echo ""
    read -p "Ingresa tu dominio estático de Ngrok (ej: tu-nombre.ngrok-free.app): " INPUT_DOMAIN
    if [ -n "$INPUT_DOMAIN" ]; then
        sed -i "s/^NGROK_DOMAIN=.*/NGROK_DOMAIN=\"$INPUT_DOMAIN\"/" "$ENV_FILE"
        NGROK_DOMAIN="$INPUT_DOMAIN"
    else
        echo "Error: Debes proporcionar un dominio de Ngrok."
        exit 1
    fi
fi

# Si se proporcionó authtoken y ngrok no lo tiene registrado
if [ -n "$NGROK_AUTHTOKEN" ]; then
    ngrok config add-authtoken "$NGROK_AUTHTOKEN" >/dev/null 2>&1 || true
fi

# 2. Levantar el proxy Nginx en Docker
echo ""
echo "[1/2] Verificando y levantando Nginx Reverse Proxy en puerto 8080..."
docker compose up -d || docker-compose up -d

echo ""
echo "[2/2] Conectando Ngrok al proxy (puerto 8080)..."
echo "Dominio: https://$NGROK_DOMAIN"
echo ""
echo "Recuerda que tus 3 servicios deben estar corriendo en local:"
echo " - Frontend (Vite) en puerto 5173"
echo " - Backend PHP (Laravel) en puerto 8000"
echo " - Backend Python (FastAPI) en puerto 5000"
echo ""
echo "Presiona Ctrl+C para detener el túnel."
echo "=================================================="

ngrok http --url="$NGROK_DOMAIN" 8080
