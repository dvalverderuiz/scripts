#!/bin/bash

# Parámetros
PARAMETRO=$1
USUARIO_REMOTO="admin_backup"  
IP_REMOTA="100.77.20.47"  

# Rutas
DIR_LOCAL="/dir_${USER}_backup"
DIR_REMOTO="/dir_${USER}_backup"
ARCHIVO_LOG="$DIR_LOCAL/logs.log"
DIR_HOME="/home/${USER}"


# Función para escribir en el log
escribir_log() {
    local mensaje=$1
    local fecha=$(date +"%Y%m%d_%H:%M:%S")
    echo "$fecha - $mensaje" >> "$ARCHIVO_LOG"
}

# Crear directorio local si no existe
if [ ! -d "$DIR_LOCAL" ]; then
    mkdir -p "$DIR_LOCAL"
    escribir_log "Directorio local $DIR_LOCAL creado."
fi

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
    if ssh "${USUARIO_REMOTO}@${IP_REMOTA}" "[ ! -d '$DIR_REMOTO' ]"; then
        ssh "${USUARIO_REMOTO}@${IP_REMOTA}" "mkdir -p '$DIR_REMOTO'"
        escribir_log "Directorio remoto $DIR_REMOTO creado en $IP_REMOTA."
    else
        escribir_log "El directorio remoto $DIR_REMOTO ya existe en $IP_REMOTA."
    fi

elif [ "$PARAMETRO" == "full" ]; then
	FECHA=$(date +"%Y%m%d_%H%M%S")
    NOMBRE_BACKUP="backup_$(basename "FULL")_$FECHA.tar.gz"
	
	# Full local
	TAR_LOCAL="$DIR_HOME/$NOMBRE_BACKUP"
    tar -czf "$TAR_LOCAL" -C "$(dirname "$DIR_HOME")" "$(basename "$NOMBRE_BACKUP")"
    escribir_log "Full backup automático local creado en $TAR_LOCAL."
	
	# Full remoto
	TAR_REMOTO="$DIR_REMOTO/$NOMBRE_BACKUP"
    scp "$TAR_LOCAL" "${USUARIO_REMOTO}@${IP_REMOTA}:$TAR_REMOTO"
    if [ $? -eq 0 ]; then
        escribir_log "Backup remoto creado en $IP_REMOTA:$TAR_REMOTO."
    else
        escribir_log "Error al transferir el backup a la máquina remota."
    fi



elif [ -d "$PARAMETRO" ]; then
    
    FECHA=$(date +"%Y%m%d_%H%M%S")
    NOMBRE_BACKUP="backup_$(basename "$PARAMETRO")_$FECHA.tar.gz"

    # Local
    TAR_LOCAL="$DIR_LOCAL/$NOMBRE_BACKUP"
    tar -czf "$TAR_LOCAL" -C "$(dirname "$PARAMETRO")" "$(basename "$PARAMETRO")"
    escribir_log "Backup local creado en $TAR_LOCAL."

    # Remoto
    TAR_REMOTO="$DIR_REMOTO/$NOMBRE_BACKUP"
    scp "$TAR_LOCAL" "${USUARIO_REMOTO}@${IP_REMOTA}:$TAR_REMOTO"
    if [ $? -eq 0 ]; then
        escribir_log "Backup remoto creado en $IP_REMOTA:$TAR_REMOTO."
    else
        escribir_log "Error al transferir el backup a la máquina remota."
    fi

else
    echo "Uso:" 
    echo "  $0 estructura               # Crea las carpetas necesarias"
    echo "  $0 /ruta/a/directorio       # Hace backup comprimido en local y remoto"
fi