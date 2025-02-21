#!/bin/bash

# Script de restore de backup, cargado en memoria y habrá que pasarle parámetros como 
# la fecha

# Para meter el script en memoria, mover a /usr/local/bin/

FECHA_ARCHIVO=$1
NOMBRE="backup_"
RAIZ_BACKUP="/home/david/scripts/destino"
REPOSITORIO_RESTORE="repositorio_restore"
ARCHIVO_A_RECUPERAR=$NOMBRE$FECHA_ARCHIVO

echo "$ARCHIVO_A_RECUPERAR"

cp /home/david/scripts/destino/$ARCHIVO_A_RECUPERAR /home/david/scripts/$REPOSITORIO_RESTORE/
