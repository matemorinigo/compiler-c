#ifndef TERCETO_H
#define TERCETO_H
#include "list.h"
#define VAR_INT 1
#define VAR_FLOAT 2
#define VAR_STRING 3
#define ARIT_ASIG_INDEX 4
#define CMP 5
#define SUM 6
#define RES 7
#define MUL 8
#define DIV 9
#define STRING_ASIG 10
#define FLOAT_ASIG 11
#define INT_ASIG 12
#define BLE 14
#define BGT 15
#define BGE 16
#define BI 17
#define PRINT_STR 18
#define PRINT_CTE_STR 19
#define ARIT_ASIG_SIMPLE 21
#define INT_OP 22
#define READ_STRING 23
#define READ_INT 24
#define READ_FLOAT 25
#define PRINT_INT 26
#define PRINT_FLOAT 27

typedef struct {
    int indice;
    char operador[50];
    char op1[50];
    char op2[50];
} tTerceto;




int get_terceto_para_asm(tLista* terceto_lista, int indice, tTerceto* terceto_destino);
void init_tercetos(tLista* terceto_table);
int agregar_terceto(tTerceto t, tLista* terceto_lista, char* operador, char* op1, char* op2);
void terceto_to_file(char* output_file, tLista* terceto_lista);
int obtener_indice_actual();
int actualizar_terceto(tLista* terceto_lista, int indice, char* operador, char* op1, char* op2);
int get_terceto(tLista* terceto_lista, int indice, tTerceto* terceto_destino);
int actualizar_op2(tLista* terceto_lista, int indice, char* op2);
#endif // TERCETO_H