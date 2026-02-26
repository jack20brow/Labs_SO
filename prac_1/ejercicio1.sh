#!/bin/bash

# COMPORTAMIENTO DESEADO #########################################

# ./ejercicio1.sh
# Se requiere el siguiente formato:
# ./ejercicio1.sh <csv> <CODE1> <CODE2> <YEAR>
# ./ejercicio1.sh share-of-population-living-in-poverty-by-national-
# poverty-lines.csv ESP COL 2019
# Año: 2019
# COD1: ESP (Spain) Pobreza: 21 %
# COD2: COL (Colombia) Pobreza: 36.5 %
# Diferencia (COL - ESP): 15.5 puntos porcentuales
# País con mayor pobreza en 2019: COL
# ./ejercicio1.sh share-of-population-living-in-poverty-by-national-
# poverty-lines.csv ESP USA 2019
# Error: no hay dato para CODE=USA en YEAR=2019
# ./ejercicio1.sh share-of-population-living-in-poverty-by-national-
# poverty-lines.csv ESP ESP 2019
# Año: 2019
# COD1: ESP (Spain) Pobreza: 21 %
# COD2: ESP (Spain) Pobreza: 21 %
# Diferencia (ESP - ESP): 0.0 puntos porcentuales
# País con mayor pobreza en 2019: EMPATE

##################################################################

# CÓDIGO

# comprobar numero de argumentos
if [ $# -eq 4 ]; then


	# asignar variables
	# primero comprobamos que el archivo csv exista
	archivo="$1"
	if [ ! -e "$archivo" ]; then
		echo "Error, el archivo pasado por parámetro($archivo) no existe"
		exit 1
	fi

	#cogemos el resto de parametros y asignamos a variables
	csv="$1"
	id1="$2"
	id2="$3"
	year="$4"

	# identificar los dos paises
	# usamos grep para identificar las líneas del archivo csv que estaremos tratando
	#pais1=$(grep -i ",$id1,$year" "$archivo")
	#pais2=$(grep -i ",$id2,$year" "$archivo")

	# así podemos tener en una variable los tres valores que nos interesan.
	# utilizamos el ofs para definir un separador entre valores, cada vez que ponemos una coma
	# en el print final, inyectamos el OFS, que nos ayudará a extraer los datos en el futuro.
	pais1=$(awk -F',' -v id="$id1" -v year="$year" 'BEGIN {OFS="|"} $2 == id && $3 == year {print $1, $4; exit}' "$csv")
	pais2=$(awk -F',' -v id="$id2" -v year="$year" 'BEGIN {OFS="|"} $2 == id && $3 == year {print $1, $4; exit}' "$csv")
	
	# ahora mismo en las variables tendriamos el nombre completo del pais y el indice de pobreza
	# separados por el ofs.

	#comprovamos si existen datos según los parámetros, de lo contrario lanzamos excepcion y detenemos ejecución.
	if [ -z "$pais1" ]; then
		echo "Error: no hay dato para CODE=$id1 en YEAR=$year"
		exit 1
	fi

	if [ -z "$pais2" ]; then
		echo "Error: no hay dato para CODE=$id2 en YEAR=$year"
		exit 1
	fi

	# comparar indices de pobreza
	# extraemos los valores guardados en dos variables distintas

	IFS='|' read -r nombre1 indice1 <<< "$pais1"
	IFS='|' read -r nombre2 indice2 <<< "$pais2"


	echo "Año: $year"
	echo "COD1: $id1 ($nombre1) Pobreza: $indice1 %"
	echo "COD2: $id2 ($nombre2) Pobreza: $indice2 %"

	
	if [ "$(echo "$indice1 > $indice2" | bc)" -eq 1 ]; then

		dif=$(echo "$indice1 - $indice2" | bc)

		echo "Diferencia ($id1 - $id2): $dif puntos porcentuales"
    	echo "País con mayor pobreza en $year: $id1"
    elif [ "$(echo "$indice2 > $indice1" | bc)" -eq 1 ]; then

    	dif=$(echo "$indice2 - $indice1" | bc)

    	echo "Diferencia ($id2 - $id1): $dif puntos porcentuales"
    	echo "País con mayor pobreza en $year: $id2"
    else

    	echo "Diferencia ($id1 - $id2) : 0.0 puntos porcentuales"
    	echo "País con mayor pobreza en $year: EMPATE"
    fi


else
	echo "Se requiere el siguiente formato:"
	echo "./ejercicio1.sh <csv> <CODE1> <CODE2> <YEAR>"
fi




