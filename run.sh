## Script para Unix
flex Lexico.l
bison -dyv Sintactico.y
gcc lex.yy.c y.tab.c -o compilador -lfl
./compilador tests/variable_declaration.txt
rm lex.yy.c
rm y.tab.c
rm y.output
rm y.tab.h
rm compilador