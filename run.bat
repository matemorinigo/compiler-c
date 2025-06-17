:: Script para windows
flex .\src\core\Lexico.l
bison -dyv .\src\core\Sintactico.y

gcc.exe -Isrc/utils lex.yy.c y.tab.c src/utils/symbol.c src/utils/list.c src/utils/terceto.c src/utils/reorder.c src/utils/slice_and_concat.c src/utils/variable_checks.c src/utils/assembler.c -o compilador.exe


compilador.exe tests\test.txt

@echo off
del compilador.exe
del lex.yy.c
del y.tab.c
del y.tab.h
del y.output

pause
