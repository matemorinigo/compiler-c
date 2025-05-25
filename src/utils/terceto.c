#include <stdio.h>
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

int agregar_terceto(tTerceto t, tLista* terceto_lista, char* operador, char* op1, char* op2){
    t.indice = ++indice;
    strcpy(t.operador, operador);
    strcpy(t.op1, op1 == NULL ? "NULL" : op1);
    strcpy(t.op2, op2 == NULL ? "NULL" : op2);
    ponerOrdenado(terceto_lista, &t, sizeof(tTerceto), cmp_terceto);
    return indice;
}

void poner_en_archivo(void* t, void* output_file){
    tTerceto* terceto = (tTerceto*)t;
    FILE* file = (FILE*)output_file;
    fprintf(file, "[%d] (%s, %s, %s)\n", 
        terceto->indice,
        terceto->operador,
        terceto->op1[0] == '\0' ? "NULL" : terceto->op1,
        terceto->op2[0] == '\0' ? "NULL" : terceto->op2);
}

void terceto_to_file(char* output_file, tLista* terceto_lista){
    FILE* file = fopen(output_file, "w");
    if (file == NULL) {
        printf("Error al abrir el archivo %s\n", output_file);
        return;
    }
    recorrerLista(terceto_lista, poner_en_archivo, file);
    fclose(file);
}

