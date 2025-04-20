:: Script para windows
flex .\src\core\Lexico.l
bison -dyv .\src\core\Sintactico.y

gcc.exe lex.yy.c y.tab.c -o compilador.exe

compilador.exe tests\prueba.txt

@echo off
del compilador.exe
del lex.yy.c
del y.tab.c
del y.tab.h
del y.output

pause
