# Solucion Ngrok + Reverse Proxy Unificado

Esta carpeta contiene la infraestructura para exponer tus tres servicios locales a traves de una unica URL HTTPS/WSS publica mediante Ngrok y un contenedor Nginx liviano en Docker.

---

## Por que es necesario este proxy?

1. **Permiso de Camara:** Los navegadores requieren obligatoriamente `https://` para activar la camara fuera de localhost.
2. **Evitar Mixed Content:** Si el Frontend corre en HTTPS, las llamadas a la API de Laravel y al WebSocket de Python deben ser seguras (`https://` y `wss://`).
3. **Un solo tunel gratuito:** La cuenta gratuita de Ngrok te da 1 dominio estatico. Nginx agrupa los 3 servicios en el puerto local `8080` para que un solo tunel de Ngrok atienda todo.

---

## Mapeo de Rutas (Puerto 8080)

| Ruta Publica | Destino Local | Descripcion |
|---|---|---|
| `https://tu-dominio/` | `http://localhost:5173` | Frontend Web (Vite con soporte HMR) |
| `https://tu-dominio/api/` | `http://localhost:8000/api/` | Backend Laravel (Endpoints REST) |
| `https://tu-dominio/storage/` | `http://localhost:8000/storage/` | Archivos publicos / subidas de Laravel |
| `wss://tu-dominio/corregir_pose/` | `ws://localhost:5000/corregir_pose/` | WebSocket de Python (FastAPI / Vision) |
| `wss://tu-dominio/ws/` | `ws://localhost:5000/ws/` | WebSocket de Python |

---

## Paso a Paso para Iniciar

### 1. Inicia tus tres servicios locales normalmente
En tres terminales distintas:
- **Frontend (front_gym):** `pnpm run dev` (escuchando en `5173`)
- **Backend PHP:** `php artisan serve` (escuchando en `8000`)
- **Backend Python:** `uvicorn main:app --reload --port 5000` (escuchando en `5000`)

### 2. Configura tu dominio de Ngrok (Solo la primera vez)
Puedes editar el archivo `ngrok.env` o dejar que el script te lo pregunte:
```bash
NGROK_DOMAIN="tu-dominio-fijo.ngrok-free.app"
NGROK_AUTHTOKEN="tu_token_aqui" # Opcional si ya lo hiciste con 'ngrok config add-authtoken'
```

### 3. Ejecuta el script de inicio
```bash
./iniciar.sh
```

El script:
1. Levantara el contenedor Nginx en segundo plano.
2. Abrira el tunel de Ngrok con tu dominio estatico hacia el puerto 8080.

---

## Para detener el proxy
Cuando termines de probar:
```bash
./detener.sh
```
