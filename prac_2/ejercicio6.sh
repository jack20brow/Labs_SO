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

# Con el -r buscamos en todos los directorios y subdirectorios
# Con la -i ignoramos todas las mayusculas
# Con la -o hace que si en una misma linea aparece mas de una vez, se cuente como diferentes apariciones
# El -H guardamos la ruta, para despues usarla para saber de donde viene cada aparicion del termino
resultado=$(grep -r -i -o -H "$2" "$1")

# Control de flujo para búsquedas sin resultados
if [ -z "$resultado" ]; then
    echo "No se encontraron ocurrencias."
    exit 1
fi



# Tubería de procesamiento:
# 1. awk -F ':': Aísla la ruta del archivo (campo 1).
# 2. awk -F '/': Aísla el nombre del archivo eliminando el path (último campo).
# 3. sort: Agrupa alfabéticamente para que uniq funcione.
# 4. uniq -c: Cuenta líneas idénticas.
# 5. sort -nr: Ordena matemáticamente (-n) en orden descendente (-r).
echo "$resultado" | awk -F ':' '{print $1}' | awk -F '/' '{print $NF}' | sort | uniq -c | sort -nr
exit 0