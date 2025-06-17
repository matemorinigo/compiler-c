#ifndef ASSEMBLER_H_INCLUDED
#define ASSEMBLER_H_INCLUDED

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "symbol.h"
#include "variable_checks.h"
#include "list.h"

void generarAssembler(tLista* symbol_table);
void escribirInicio(FILE *arch);
void generarTabla(FILE *arch, tLista* symbol_table);


#endif // ASSEMBLER_H_INCLUDED

