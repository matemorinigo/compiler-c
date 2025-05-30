#ifndef TERCETO_H
#define TERCETO_H
#include "list.h"

typedef struct {
    int indice;
    char operador[50];
    char op1[50];
    char op2[50];
} tTerceto;

void init_tercetos(tLista* terceto_table);
int agregar_terceto(tTerceto t, tLista* terceto_lista, char* operador, char* op1, char* op2);
void terceto_to_file(char* output_file, tLista* terceto_lista);
int obtener_indice_actual();
int actualizar_terceto(tLista* terceto_lista, int indice, char* operador, char* op1, char* op2);
int get_terceto(tLista* terceto_lista, int indice, tTerceto* terceto_destino);
#endif // TERCETO_H