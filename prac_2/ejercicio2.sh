#!/bin/bash

# ---- EJERCICIO 2 -----
# Ejemplos de uso:
# ./ejercicio2.sh
# Uso: ./ejercicio2.sh <csv> <year> <umbral>
# ./ejercicio2.sh
# share-of-final-energy-consumption-from-renewable-sources.csv
# 2020 40
# Filas (sin cabecera) en filtrado_2020.csv: 64
# ./ejercicio2.sh
# share-of-final-energy-consumption-from-renewable-sources.csv
# 2015 60
# Filas (sin cabecera) en filtrado_2015.csv: 41


# Fail-Fast - Argumentos incorrectos
if [ $# -ne 3 ]; then
	echo "Se requiere el siguiente formato"
	echo "$0 <csv> <year> <umbral>"
	exit 1
fi

# Comprobamos que existe el archivo CSV
if [ ! -f "$1" ]; then
    echo "Error: El CSV no existe"
    exit 1
fi

csv=$1
year=$2
umbral=$3


# Hacemos el awk, para el filtrado utilizamos el LC_NUMERIC=C, lo que hace que los decimales
# esten asociados con los puntos en vez de las comas.
LC_NUMERIC=C awk -F ',' -v year="$year" -v umbral="$umbral" 'NR == 1 || $3==year && ($4) >=umbral {print $0}' "$csv"  > "filtrado_${year}.csv"

num_lineas=$(wc -l < "filtrado_${year}.csv")
echo "Filas (sin cabecera) en filtrado_${year}.csv: $((num_lineas - 1))"
exit 0

