#!/usr/bin/env bash
set -euo pipefail

# Script para ejecutar Trueke en modo desarrollo con variables de entorno

if [ ! -f .env ]; then
  echo "Error: No se encontró el archivo .env"
  echo "Copia .env.example a .env y configura tus credenciales de Supabase"
  exit 1
fi

# Cargar variables de entorno
source .env

# Ejecutar Flutter con las variables de entorno
flutter run \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY"
