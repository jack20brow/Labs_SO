#!/bin/bash

if [ $# -ne 2 ]; then
	echo "Numero de argumentos incorrecto"
	echo "$0 <directorio> <termino>"
	exit 1
fi


if [ ! -d "$1" ]; then
	echo "El primer argumento no es un directorio"
	exit 1
fi

resultado=$(grep -r -i -o -H "$2" "$1")

# Control de flujo para búsquedas sin resultados
if [ -z "$resultado" ]; then
    echo "No se encontraron ocurrencias."
    exit 0
fi

# Tubería de procesamiento:
# 1. awk -F ':': Aísla la ruta del archivo (campo 1).
# 2. awk -F '/': Aísla el nombre del archivo eliminando el path (último campo).
# 3. sort: Agrupa alfabéticamente para que uniq funcione.
# 4. uniq -c: Cuenta líneas adyacentes idénticas.
# 5. sort -nr: Ordena matemáticamente (-n) en orden descendente (-r).
echo "$resultado" | awk -F ':' '{print $1}' | awk -F '/' '{print $NF}' | sort | uniq -c | sort -nr
