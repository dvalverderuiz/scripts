#!/bin/bash

FECHA=$(date "+%Y-%m-%d")
ORIGEN_COPIAS="/home/david/scripts/dircopias/"
DESTINO_COMPRIMIDOS="/home/david/scripts/dircomprimidos/"
DESTINO="/home/david/scripts/destino"
NOMBRE="backup_$FECHA"

echo "· Comprimiendo..."
tar -czf "$DESTINO_COMPRIMIDOS$NOMBRE" -C "$ORIGEN_COPIAS" .
echo "· Comprimido en $DESTINO_COMPRIMIDOS [HECHO]"


if [ ! -d "$ORIGEN_COPIAS" ]; then
  echo "El directorio $ORIGEN_COPIAS no existe."
  exit 1
fi

if [ ! -d "$DESTINO_COMPRIMIDOS" ]; then
  echo "La carpeta de destino $DESTINO_COMPRIMIDOS no existe."
  exit 1
fi

echo "· Copiando los archivos..."
cp -r "$DESTINO_COMPRIMIDOS"/* "$DESTINO"
echo "· Copiado en $DESTINO [HECHO]"

if [ $? -eq 0 ]; then
  echo "Backup completado correctamente."
else
  echo "Error al copiar los archivos."
  exit 1
fi

exit 0
