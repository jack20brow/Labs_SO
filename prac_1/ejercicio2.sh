#!/bin/bash

# COMPORTAMIENTO DESEADO #########################################

# Ejemplo de uso:
# ./ejercicio2.sh share-of-population-living-in-poverty-by-national-
# poverty-lines.csv access-to-basic-services.csv 2011 30 50
# Generado: alerta_ods1_2011.txt
# Países detectados: 6
# ./ejercicio2.sh share-of-population-living-in-poverty-by-national-
# poverty-lines.csv access-to-basic-services.csv 2019 40 80
# Generado: alerta_ods1_2019.txt
# Países detectados: 3
# Contenido del fichero: alerta_ods1_2019.txt
# Code;Entity;PovertyRate;Electricity
# MWI;Malawi;50.7;11.2
# MLI;Mali;42.3;47.9
# MOZ;Mozambique;68.2;29.7


##################################################################

# CÓDIGO

# Pasamos las pruebas de inconsistencia de argumentos de entrada con un Fail-Fast
if [ $# -ne  5 ];then
	echo "Se requiere el siguiente formato"
	echo "$0 <poverty_csv> <services_csv> <YEAR> <POV_MIN> <ELEC_MAX>"
	exit 1
fi


estad_pobreza=$1
estad_servicios=$2

if [ ! -s "$estad_pobreza" ];then
	echo "Error, el archivo $1 está vacío"
	exit 1
elif [ ! -s "$estad_servicios" ];then
	echo "Error, el archivo $2 está vacio"
	exit 1
fi

# Lógica



echo "Code;Entity;PovertyRate;Electricity" > "alerta_ods1_${3}.txt"

join -t ';' -1 1 -2 1 \
	<(awk -F ',' -v pov_min="$4" -v year="$3" 'BEGIN {OFS=";"} NR > 1 && $4 >= pov_min && $3 == year {print $2, $1, $4}' "$estad_pobreza" | sort -t ';' -k1,1)\
	<(awk -F ',' -v elec_max="$5" -v year="$3" 'BEGIN {OFS=";"} NR > 1 && $4 <= elec_max && $3 == year {print $2, $4}' "$estad_servicios" | sort -t ';' -k1,1) >> "alerta_ods1_${3}.txt"

echo "Generado: alerta_ods1_${3}.txt"

num_lineas=$(wc -l < "alerta_ods1_${3}.txt")
echo "Países detectados: $((num_lineas-1))"

exit 0