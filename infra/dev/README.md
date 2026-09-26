# Entorno local de desarrollo (se movió)

Desde el 2026-09-25 el entorno local (PostgreSQL + PostGIS y Keycloak en Podman) vive en el repositorio del API:

**`app-mascotas-api/infra/dev/`** — ver su `README.md`.

Se usa el mismo proyecto de contenedores (`amiva-dev`) y el mismo volumen de datos, así que no se pierde nada al cambiar de carpeta. El `.env` que pudiera quedar en esta carpeta ya no se usa (el vigente está en `app-mascotas-api/infra/dev/.env`).
