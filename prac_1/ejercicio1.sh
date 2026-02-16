#!/bin/bash


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



# comprobar numero de argumentos
if [$# = 4]; then
	# asignar variables

	# comprobar fichero

	# analizar año pasado por arg.

	# identificar los dos paises con sus ID

	# comparar indices de pobreza

	# imprimir que país tiene mayor pobreza






else
	echo "Se requiere el siguiente formato:"
	echo "./ejercicio1.sh <csv> <CODE1> <CODE2> <YEAR>"
fi




