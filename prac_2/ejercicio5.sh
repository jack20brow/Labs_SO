#!/bin/bash

# Fail-Fast para comprobar el numero de argumentos pasados
if [ $# -ne 4 ]; then
	echo "Numero de argumentos incorrecto"
	echo "$0 <csv> <year_ini> <year_fin> <N>"
	exit 1
fi


# Fail-Fast para comprobar que el csv no esta vacío
if [ ! -s $1 ]; then
	echo "El primer argumento, correspondiente al csv esta vacío"
	exit 1
fi

LC_NUMERIC=C awk -F ',' -v year_init="$2" -v year_final="$3" '
NR>1 && $3>=year_init && $3<=year_final {
	## Hacemos arrays que tendran el codigo del pais como id
	sum[$2]+=$4
	contador[$2]++
	entity[$2]=$1
}
END{
	for (code in sum){
	
		## Para cada pais que tenga al menos una coincidencia con las condiciones hacemos el output
		media = sum[code] / contador[code]
		printf "%.6f | %s | %s | %d\n", media, code, entity[code], contador[code]
	
	}


}' "$1" | sort -nr | head -n "$4"

## Cogemos el valor del csv, lo ordenamos por numeros y lo hacemos en reverse
## para así tener los mas grandes arriba, finalmente cogemos los primeros n numero
## que serán los pasados por arg.