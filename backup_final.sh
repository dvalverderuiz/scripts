#!/bin/bash

# Parámetros
PARAMETRO=$1
USUARIO_REMOTO="admin_backup"
IP_REMOTA="100.77.20.47"

# Rutas
DIR_LOCAL="/dir_$(whoami)_backup"
DIR_REMOTO="/dir_$(whoami)_backup"
ARCHIVO_LOG="$DIR_LOCAL/logs.log"
DIR_HOME="/home/$(whoami)"
BACKUP_BASE="$DIR_LOCAL/backup_base.tar.gz"

# Función para escribir en el log
escribir_log() {
    local mensaje=$1
    local fecha=$(date +"%Y%m%d_%H%M%S")
    echo "$fecha - $mensaje" >> "$ARCHIVO_LOG"
}

# Crear directorio local si no existe
if [ ! -d "$DIR_LOCAL" ]; then
    mkdir -p "$DIR_LOCAL"
    escribir_log "Directorio local $DIR_LOCAL creado."
fi

# Función para realizar backup incremental
backup_incremental() {
    FECHA=$(date +"%Y%m%d_%H%M%S")
    NOMBRE_BACKUP="backup_incremental_$FECHA.tar.gz"
    TAR_LOCAL="$DIR_LOCAL/$NOMBRE_BACKUP"
    TAR_REMOTO="$DIR_REMOTO/$NOMBRE_BACKUP"

    # Revisar si esta tar podría funcionar:
    tar --verbose --create --file=/mnt/data/documents0.tar  --listed-incremental=/mnt/data/documents.snar  ~/Documents    
    
    tar --listed-incremental="$DIR_LOCAL/snapshot.snar" -czf "$TAR_LOCAL" -C "$DIR_HOME" .
    escribir_log "Backup incremental creado en $TAR_LOCAL."
    
    scp "$TAR_LOCAL" "${USUARIO_REMOTO}@${IP_REMOTA}:$TAR_REMOTO"
    if [ $? -eq 0 ]; then
        escribir_log "Backup incremental transferido a $IP_REMOTA:$TAR_REMOTO."
    else
        escribir_log "Error al transferir el backup incremental a la máquina remota."
    fi
}

# Verificación de parámetros
if [ "$PARAMETRO" == "estructura" ]; then
    # Verificación en local
    if [ ! -d "$DIR_LOCAL" ]; then
        mkdir -p "$DIR_LOCAL"
        escribir_log "Directorio local $DIR_LOCAL creado."
    else
        escribir_log "El directorio local $DIR_LOCAL ya existe."
    fi
    
    # Verificación carpeta remota
    ssh "${USUARIO_REMOTO}@${IP_REMOTA}" "mkdir -p '$DIR_REMOTO'"
    escribir_log "Directorio remoto $DIR_REMOTO verificado en $IP_REMOTA."

elif [ "$PARAMETRO" == "full" ]; then
    FECHA=$(date +"%Y%m%d_%H%M%S")
    NOMBRE_BACKUP="backup_full_$FECHA.tar.gz"
    TAR_LOCAL="$DIR_LOCAL/$NOMBRE_BACKUP"
    TAR_REMOTO="$DIR_REMOTO/$NOMBRE_BACKUP"
    
    tar -czf "$TAR_LOCAL" -C "$DIR_HOME" .
    escribir_log "Backup full creado en $TAR_LOCAL."
    
    scp "$TAR_LOCAL" "${USUARIO_REMOTO}@${IP_REMOTA}:$TAR_REMOTO"
    if [ $? -eq 0 ]; then
        escribir_log "Backup full transferido a $IP_REMOTA:$TAR_REMOTO."
    else
        escribir_log "Error al transferir el backup full a la máquina remota."
    fi

elif [ "$PARAMETRO" == "incremental" ]; then
    backup_incremental

elif [ -d "$PARAMETRO" ]; then
    FECHA=$(date +"%Y%m%d_%H%M%S")
    NOMBRE_BACKUP="backup_$(basename "$PARAMETRO")_$FECHA.tar.gz"
    TAR_LOCAL="$DIR_LOCAL/$NOMBRE_BACKUP"
    TAR_REMOTO="$DIR_REMOTO/$NOMBRE_BACKUP"
    
    tar -czf "$TAR_LOCAL" -C "$PARAMETRO" .
    escribir_log "Backup local creado en $TAR_LOCAL."
    
    scp "$TAR_LOCAL" "${USUARIO_REMOTO}@${IP_REMOTA}:$TAR_REMOTO"
    if [ $? -eq 0 ]; then
        escribir_log "Backup transferido a $IP_REMOTA:$TAR_REMOTO."
    else
        escribir_log "Error al transferir el backup a la máquina remota."
    fi

else
    echo "Uso:"
    echo "  $0 estructura               # Crea las carpetas necesarias"
    echo "  $0 full                     # Hace un backup completo del directorio home en local y remoto"
    echo "  $0 incremental              # Realiza un backup incremental del directorio home en local y remoto"
    echo "  $0 /ruta/a/directorio       # Hace backup comprimido en local y remoto"
fi
