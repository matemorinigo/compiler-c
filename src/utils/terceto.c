#include <string.h>
#include "terceto.h"
#include "list.h"

int indice = 0;

int cmp_terceto(const void* t1, const void* t2){
    return ((tTerceto*)t1)->indice - ((tTerceto*)t2)->indice;
}

void init_tercetos(tLista* terceto_table){
    crearLista(terceto_table);
}

void agregar_terceto(tTerceto t, tLista* terceto_table, char* operador, char* op1, char* op2){
    t.indice = ++indice;
    strcpy(t.operador, operador);
    strcpy(t.op1, op1);
    strcpy(t.op2, op2);
    ponerOrdenado(terceto_table, &t, sizeof(tTerceto), cmp_terceto);
}