 #!/bin/bash

#Comprobamos el formato 
if [ $# -ne 3 ]; then
	echo "Formato incorrecto: $0 <csv> <year> <N>"
	exit 1
fi

#Guardamos las variables
csv="$1"
year="$2"
N="$3"

#Con grep buscamo las lineas que contienen el año $year, las columnas de los archivos csv estan separadas por ',', con -t definimos este separador
#Le pedimos que ordene la columna 4 numericamente de mayor a menor, en el caso de empate entra a la segunda "key" que escoge una o otra alfabeticamente
#Seguidamente le pedimos que nos saque las N primeras lineas, con awk usamos print format para mostrar los datos como se pide en el enunciado
#Todos los comandos conectados por pipes
grep ",$year," "$csv" | sort -t ',' -k4,4rn -k1,1 | head -n "$N" | awk  -F ','  '{printf "%.6f | %s | %s | %s\n", $4, $1, $2, $3}'

