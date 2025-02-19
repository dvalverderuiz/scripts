#!/bin/bash

FECHA=$(date "+%Y-%m-%d")
ORIGEN_COPIAS="/home/dvalverde/sistemas/dircopias/"
DESTINO_COMPRIMIDOS="/home/dvalverde/sistemas/dircomprimidos/"
DESTINO="d_valverde@100.77.20.53:/home/d_valverde/backup_sistemas"
NOMBRE="backup_$FECHA"

echo "Comprimiendo $ORIGEN_COPIAS"
tar -czf "$DESTINO_COMPRIMIDOS$NOMBRE" -C "$ORIGEN_COPIAS" .
echo "Comprimido en $DESTINO_COMPRIMIDOS [HECHO]"


if [ ! -d "$ORIGEN_COPIAS" ]; then
  echo "El directorio $ORIGEN_COPIAS no existe."
  exit 1
fi

if [ ! -d "$DESTINO_COMPRIMIDOS" ]; then
  echo "La carpeta de destino $DESTINO_COMPRIMIDOS no existe."
  exit 1
fi

echo "Copiando los archivos a $DESTINO..."
rsync -avz "$DESTINO_COMPRIMIDOS" $DESTINO



echo "Copiado en $DESTINO [HECHO]"

if [ $? -eq 0 ]; then
  echo "Backup completado correctamente."
else
  echo "Error al copiar los archivos."
  exit 1
fi

exit 0
