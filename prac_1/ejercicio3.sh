#!/bin/bash

#Validación de argumentos (Fail-Fast)
if [ $# -ne 1 ]; then
    echo "Se requiere el formato: $0 <alerta_txt>"
    exit 1
fi

alerta_txt=$1

#Comprobación de existencia del fichero
if [ ! -f "$alerta_txt" ]; then
    echo "Error: el fichero $alerta_txt no existe"
    exit 1
fi

#Variables para el informe
#Contamos líneas de datos (total menos la cabecera)
num_paises=$(grep -c ";" "$alerta_txt")
num_paises=$((num_paises - 1))

#Inicializamos variables por defecto para el caso de fichero vacío (solo cabecera)
paises_lista=""
mayor_pobreza="N/A"
menor_elec="N/A"

#Procesamiento de datos (solo si hay países detectados)
if [ "$num_paises" -gt 0 ]; then
    #Extraer lista de códigos (columna 1) en una sola línea separada por espacios
    paises_lista=$(awk -F';' 'NR > 1 {printf "%s ", $1}' "$alerta_txt" | sed 's/ $//')

    #Encontrar país con mayor PovertyRate (Columna 3)
    #Ordenamos numéricamente por la columna 3 de mayor a menor
    mayor_pobreza=$(awk -F';' 'NR > 1 {print $1, $3}' "$alerta_txt" | sort -k2,2nr | head -n1)

    #Encontrar país con menor Electricity (Columna 4)
    #Ordenamos numéricamente por la columna 4 de menor a mayor
    menor_elec=$(awk -F';' 'NR > 1 {print $1, $4}' "$alerta_txt" | sort -k2,2n | head -n1)
fi

#Generar el fichero resumen_alerta.txt
echo "Fichero analizado: $alerta_txt" > resumen_alerta.txt
echo "$paises_lista" >> resumen_alerta.txt
echo "Países en alerta: $num_paises" >> resumen_alerta.txt
echo "Mayor pobreza: $mayor_pobreza" >> resumen_alerta.txt
echo "Menor acceso electricidad: $menor_elec" >> resumen_alerta.txt

#Salida por pantalla 
echo "Fichero: $alerta_txt"
echo "Países en alerta: $num_paises"
echo "Mayor pobreza: $mayor_pobreza"
echo "Menor acceso electricidad: $menor_elec"
echo "Generado: resumen_alerta.txt"

exit 0
