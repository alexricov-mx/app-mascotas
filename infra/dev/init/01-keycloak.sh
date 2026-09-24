#!/bin/bash
# Crea el usuario y la base de Keycloak. Solo corre cuando el volumen de datos es nuevo.
set -e
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname postgres <<-SQL
  CREATE USER keycloak WITH PASSWORD '${KEYCLOAK_DB_PASSWORD}';
  CREATE DATABASE keycloak OWNER keycloak;
SQL
