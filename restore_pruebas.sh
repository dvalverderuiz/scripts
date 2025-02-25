#!/bin/bash

# Parámetros
FECHA_USUARIO=$1
RUTA_GUARDADO=$2

# Repositorio backup remoto
USUARIO_REMOTO="admin_backup"
IP_REMOTA="100.77.20.47"
DIR_REMOTO="/dir_${USER}_backup"

# Convertir la fecha de usuario (2025-02-24) al formato del archivo (20250224)
FECHA_ARCHIVO=$(echo "$FECHA_USUARIO" | tr -d '-')

# Verifica si el directorio remoto existe
if ! ssh "${USUARIO_REMOTO}@${IP_REMOTA}" "[ -d '$DIR_REMOTO' ]"; then
    echo "El directorio remoto $DIR_REMOTO no existe en $IP_REMOTA."
    exit 1
fi

# Busca el archivo en el directorio remoto basado en la fecha convertida
ARCHIVO_REMOTO=$(ssh "${USUARIO_REMOTO}@${IP_REMOTA}" "find '$DIR_REMOTO' -name '*${FECHA_ARCHIVO}*' -type f")

if [ -z "$ARCHIVO_REMOTO" ]; then
    echo "No se encontró ningún archivo con la fecha $FECHA_USUARIO en $DIR_REMOTO."
    exit 1
fi

# Copia el archivo desde el servidor remoto a la ruta de guardado local
echo "Copiando el archivo $ARCHIVO_REMOTO a $RUTA_GUARDADO..."
scp "${USUARIO_REMOTO}@${IP_REMOTA}:${ARCHIVO_REMOTO}" "$RUTA_GUARDADO"

if [ $? -eq 0 ]; then
    echo "Archivo copiado exitosamente a $RUTA_GUARDADO."
else
    echo "Error al copiar el archivo."
    exit 1
fi