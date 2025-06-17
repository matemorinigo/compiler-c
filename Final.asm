include macros2.asm
include number.asm

.MODEL SMALL
.386
.STACK 200h

.DATA
NEW_LINE DB 0AH,0DH,'$'
CWprevio DW ?
T_"Condición evaluada como verdadera" db "Condición evaluada como verdadera", '$'
T_"Demostrando reorder:" db "Demostrando reorder:", '$'
T_"Fin del programa" db "Fin del programa", '$'
T_"Hola" db "Hola", '$'
T_"Incrementando b" db "Incrementando b", '$'
T_"Ingrese un valor para la variable c:" db "Ingrese un valor para la variable c:", '$'
T_"Juan" db "Juan", '$'
T_"Mundo" db "Mundo", '$'
T_"Perez" db "Perez", '$'
T_"Programa de prueba integral" db "Programa de prueba integral", '$'
T_"Resultado de sliceAndConcat:" db "Resultado de sliceAndConcat:", '$'
T_"a es mayor que b" db "a es mayor que b", '$'
T_"a no es menor que b" db "a no es menor que b", '$'
T_"c está en rango válido" db "c está en rango válido", '$'
T_"c fuera de rango" db "c fuera de rango", '$'
T_0 dd 0
T_1 dd 1
T_10 dd 10
T_100 dd 100
T_2 dd 2
T_20 dd 20
T_3 dd 3
T_3.14159 dd 3.14159
T_5 dd 5
T_50 dd 50
T_99.5 dd 99.5
a dd 
apellido db , '$'
b dd 
c dd 
interna_@expr_0 dd 0
interna_@expr_1 dd 0
interna_@expr_2 dd 0
interna_@expr_3 dd 0
nombre db , '$'
resultadoTexto db , '$'
x dd 
y dd 
z dd 

