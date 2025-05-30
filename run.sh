## Script para Unix
flex ./src/core/Lexico.l
bison -dyv ./src/core/Sintactico.y
gcc -Isrc/utils lex.yy.c y.tab.c src/utils/symbol.c src/utils/list.c src/utils/terceto.c src/utils/reorder.c src/utils/slice_and_concat.c src/utils/variable_checks.c -o compilador -lfl
./compilador tests/test.txt
rm lex.yy.c
rm y.tab.c
rm y.output
rm y.tab.h
rm compilador