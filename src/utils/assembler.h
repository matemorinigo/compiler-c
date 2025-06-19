#ifndef ASSEMBLER_H_INCLUDED
#define ASSEMBLER_H_INCLUDED

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "symbol.h"
#include "variable_checks.h"
#include "list.h"
#include "terceto.h"

void generarAssembler(tLista* symbol_table, tLista* terceto_lista);
void escribirInicio(FILE *arch);
void generarTabla(FILE *arch, tLista* symbol_table);
void escribirInicioCodigo(FILE *arch);
void escribirFinal(FILE *arch);


#endif // ASSEMBLER_H_INCLUDED

