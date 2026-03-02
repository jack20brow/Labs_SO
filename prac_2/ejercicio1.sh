#!/bin/bash

# Fail-Fast - Argumentos incorrectos
if [ $# -ne 1 ]; then
	echo "Se requiere el siguiente formato"
	echo "$0 <fichero>"
	exit 1
fi

archivo=$1

# Fail-Fast - Fichero inexistente
if [ ! -e $archivo ]; then
	echo "Error: el fichero no existe o no es un fichero regular"
	exit 1
fi

# Mirar como saber que fichero es
# comando file
formato="$(file "$1")"
echo "Tipo: $1: "$formato""

# Directorio actual
directorio="$(pwd)/"$0""
echo "Directorio: "$directorio""

# Nombre
nombre=$(basename "$(pwd)"/"$1")
echo "Nombre: "$nombre""

# Numero de lineas
num_lineas=$(wc -l < "$archivo")
echo "Lineas: $((num_lineas))"

# Numero de columnas
# NF esta en el man de awk
num_columnas=$(awk -F ',' 'NR == 1 {print NF; exit}' "$archivo")
echo "Columnas: "$num_columnas""

# Primeras tres lineas
echo "Primeras tres lineas:"
echo "$(head -n 3 "$archivo")"

# Ultimas tres lineas
echo "Ultimas tres lineas"
echo "$(tail -n 3 "$archivo")"

