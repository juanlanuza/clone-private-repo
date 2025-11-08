#!/bin/bash

# ===========================================
# 🔐 Clonar repositorio privado de GitHub usando token personal
# ===========================================

# ──────────────────────────────────────────────────────────────
# 🔧 ¿Cómo se usa?
# ──────────────────────────────────────────────────────────────
# 1️⃣ Coloca este script en el servidor
# 2️⃣ Ejecuta:
#     chmod +x clone_private_repo.sh && ./clone_private_repo.sh
# 3️⃣ Si no existe `.env` o está incompleto, el script te guiará.
#    Si ya existe y es válido, usará los valores de ahí.

set -e

ENV_FILE=".env"

# ──────────────────────────────────────────────────────────────
# 📝 Función para crear/regenerar el .env
# ──────────────────────────────────────────────────────────────
function create_env_file() {
    echo ""
    echo "🔧 Por favor, introduce los datos para configurar $ENV_FILE."
    echo ""

    # Pedir las variables al usuario
    read -p "Introduce tu nombre de usuario de GitHub (USERNAME): " USERNAME

    # Pedir token de forma segura y validar que no esté vacío
    # Usamos 'local' para que esta variable solo exista dentro de la función
    local NEW_GITHUB_TOKEN=""
    while [[ -z "$NEW_GITHUB_TOKEN" ]]; do
        read -sp "Introduce tu token de acceso personal (GITHUB_TOKEN) (input oculto): " NEW_GITHUB_TOKEN
        echo "" # Salto de línea después del read -s
        if [[ -z "$NEW_GITHUB_TOKEN" ]]; then
            echo "❌ El token no puede estar vacío. Inténtalo de nuevo."
        fi
    done

    read -p "Propietario del repo (USERNAME_REPO) [Presiona Enter para usar '$USERNAME']: " NEW_USERNAME_REPO
    # Asignar default si la entrada está vacía
    NEW_USERNAME_REPO=${NEW_USERNAME_REPO:-$USERNAME}

    read -p "Nombre del repositorio (REPO_NAME): " NEW_REPO_NAME
    echo ""

    # Crear el archivo .env con el formato solicitado usando un "Here Document"
    cat << EOF > "$ENV_FILE"
# ---- GitHub ----

# ---- Credentials ----

# Usuario que tiene el token de GitHub
USERNAME=$USERNAME

# Token personal de acceso
GITHUB_TOKEN=$NEW_GITHUB_TOKEN

# ---- Repo ----

# Usuario propietario del repositorio (puede ser distinto de USERNAME si es una organización o tercero)
USERNAME_REPO=$NEW_USERNAME_REPO

# Nombre del repositorio a clonar
REPO_NAME=$NEW_REPO_NAME
EOF

    echo "✅ Archivo $ENV_FILE (re)generado correctamente."
    echo ""
}


# ──────────────────────────────────────────────────────────────
# 📂 Cargar o crear variables del entorno (.env)
# ──────────────────────────────────────────────────────────────

RECREATE_ENV=false

if [[ ! -f "$ENV_FILE" ]]; then
    echo "🤔 No se encontró el archivo $ENV_FILE."
    RECREATE_ENV=true
else
    # Si el archivo existe, cargarlo para validarlo
    export $(grep -vE '^\s*#' "$ENV_FILE" | grep -vE '^\s*$' | xargs)
    
    # Validar variables mínimas
    if [[ -z "$USERNAME" || -z "$USERNAME_REPO" || -z "$REPO_NAME" ]]; then
        echo "❌ El archivo $ENV_FILE existe pero está incompleto."
        RECREATE_ENV=true
    else
        echo "✅ Archivo $ENV_FILE cargado correctamente."
    fi
fi

# Si se marcó para recrear (ya sea por no existir o estar incompleto)
if [[ "$RECREATE_ENV" == "true" ]]; then
    create_env_file
    # Recargar las variables recién creadas
    export $(grep -vE '^\s*#' "$ENV_FILE" | grep -vE '^\s*$' | xargs)
fi


# ──────────────────────────────────────────────────────────────
# 🔐 Pedir el token si no está definido correctamente
# ──────────────────────────────────────────────────────────────
# Si el archivo .env *existía* y tenía el placeholder, esto lo pedirá.
# Si acabamos de (re)crear el archivo, el token ya es correcto y este bloque se omitirá.
if [[ -z "$GITHUB_TOKEN" || "$GITHUB_TOKEN" == "ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" ]]; then
  echo -n "🔐 Introduce tu token de GitHub (input oculto): "
  read -s GITHUB_TOKEN
  echo ""
fi

# ──────────────────────────────────────────────────────────────
# 🚀 Clonar repositorio privado de forma segura
# ──────────────────────────────────────────────────────────────
REPO_URL="https://""${USERNAME}":"${GITHUB_TOKEN}""@github.com/${USERNAME_REPO}/${REPO_NAME}.git"

echo "⏳ Clonando repositorio desde GitHub..."
git clone "$REPO_URL"

# Limpiar la variable sensible del entorno
unset GITHUB_TOKEN

# ──────────────────────────────────────────────────────────────
# 🗑️ Limpieza opcional del .env
# ──────────────────────────────────────────────────────────────
echo ""
# -n 1 (lee un solo caracter) -r (no interpreta \ como escape)
read -p "¿Deseas eliminar el archivo sensible .env ahora? (s/n): " -n 1 -r DELETE_CHOICE
echo "" # Salto de línea después del read -n 1

# Comprobar si la respuesta es 's' o 'S'
if [[ "$DELETE_CHOICE" =~ ^[sS]$ ]]; then
    if rm "$ENV_FILE"; then
        echo "🗑️ Archivo $ENV_FILE eliminado."
    else
        echo "⚠️ No se pudo eliminar $ENV_FILE."
    fi
else
    echo "ℹ️ Archivo $ENV_FILE conservado. Recuerda borrarlo manualmente."
fi

# ──────────────────────────────────────────────────────────────
# ✅ Final
# ──────────────────────────────────────────────────────────────
echo ""
echo "✅ Repositorio clonado correctamente."
echo ""