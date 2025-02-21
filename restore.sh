#!/bin/bash

# Script de restore de backup, cargado en memoria y habrá que pasarle parámetros como 
# la fecha

RAIZ_BACKUP="/home/david/scripts/destino"

FECHA_ARCHIVO=$1
# Buscar la manera de que sea lo máximo escalable posible.
# Mirar de implementar USUARIO=$2 para que este disponible en todas las máquinas. 
# Ejecutar un try para crear la estructura en la máquina cliente si no existe.
NOMBRE="backup_"

ARCHIVO_A_RECUPERAR=$NOMBRE$FECHA_ARCHIVO
CARPETA="restore_$ARCHIVO_A_RECUPERAR"

REPOSITORIO_RESTORE="/home/david/scripts/repositorio_restore/$CARPETA"

echo "· Restaurando archivo: $ARCHIVO_A_RECUPERAR..."

mkdir $REPOSITORIO_RESTORE

cp /home/david/scripts/destino/$ARCHIVO_A_RECUPERAR $REPOSITORIO_RESTORE
echo "· Copiando del destino..."

tar -xzf $REPOSITORIO_RESTORE/$ARCHIVO_A_RECUPERAR -C $REPOSITORIO_RESTORE
echo "· Descomprimiendo..."

echo "Restauración completada en $REPOSITORIO_RESTORE"
