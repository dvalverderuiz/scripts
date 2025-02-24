#!/bin/bash

# Parámetros
PARAMETRO=$1
USUARIO_REMOTO="admin_backup"  
IP_REMOTA="100.77.20.47"  

# Rutas
DIR_LOCAL="/dir_${USER}_backup"
DIR_REMOTO="/dir_${USER}_backup"


if [ "$PARAMETRO" == "estructura" ]; then
    
    # Verificación en local
    if [ ! -d "$DIR_LOCAL" ]; then
        mkdir -p "$DIR_LOCAL"
        echo "Directorio $DIR_LOCAL creado."
    else
        echo "El directorio $DIR_LOCAL ya existe."
    fi

    # Verificación carpeta remota
    if ssh "${USUARIO_REMOTO}@${IP_REMOTA}" "[ ! -d '$DIR_REMOTO' ]"; then
        ssh "${USUARIO_REMOTO}@${IP_REMOTA}" "mkdir -p '$DIR_REMOTO'"
        echo "Directorio remoto $DIR_REMOTO creado en $IP_REMOTA."
    else
        echo "El directorio remoto $DIR_REMOTO ya existe en $IP_REMOTA."
    fi


elif [ -d "$PARAMETRO" ]; then
    
    FECHA=$(date +"%Y%m%d_%H%M%S")
    FECHA_LOG=$(date +"%Y%m%d_%H:%M:%S")
    NOMBRE_BACKUP="backup_$(basename "$PARAMETRO")_$FECHA.tar.gz"

    # Local
    TAR_LOCAL="$DIR_LOCAL/$NOMBRE_BACKUP"
    tar -czf "$TAR_LOCAL" -C "$(dirname "$PARAMETRO")" "$(basename "$PARAMETRO")"
    echo "Backup local creado en $TAR_LOCAL"

    # Remoto
    TAR_REMOTO="$DIR_REMOTO/$NOMBRE_BACKUP"
    scp "$TAR_LOCAL" "${USUARIO_REMOTO}@${IP_REMOTA}:$TAR_REMOTO"
    if [ $? -eq 0 ]; then
        echo "Backup remoto creado en $IP_REMOTA:$TAR_REMOTO"
	echo "$FECHA Backup remoto creado en $IP_REMOTA:$TAR_REMOTO" >> $DIR_LOCAL/logs.log
    else
        echo "Error al transferir el backup a la máquina remota."
    fi

else
    echo "Uso:" 
    echo "  $0 estructura               # Crea las carpetas necesarias"
    echo "  $0 /ruta/a/directorio       # Hace backup comprimido en local y remoto"
fi
