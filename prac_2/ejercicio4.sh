#!/bin/bash

#COmprobación de argumento
if [ $# -ne 2 ];then
	echo "Formato incorrecto: $0 <fichero_entrada> <fichero_salida>"
	exit 1
fi

#asignamos variable a los argumentos
archivo_entrada=$1
archivo_salida=$2

#COmprobamos que el archivo de entrada exista y no sea un directorio
if [ ! -f "$archivo_entrada" ];then
	echo "Archivo entrada no existente o diferente de archivo regular"
	exit 1
fi

#Contamos las lineas del archivo con wc (usamos < para que no nos devuelva tambien el nombre del archivo)
lineas_entrada=$(wc -l < "$archivo_entrada")
echo "Fichero entrada OK. Lineas entrada: $lineas_entrada " 

#Procesamos con sed (Substituimos el carriage return por nada, ahora sí eliminamos las vacias, y limpiamos comas)
sed -E 's/\r//g; /^$/d; s/ *, */,/g' "$archivo_entrada" > "$archivo_salida"

#Contamos las lineas del nuevo archivo con wc
lineas_salida=$(wc -l < "$archivo_salida")
echo "Fichero salida OK. Lineas entrada: $lineas_salida " 

