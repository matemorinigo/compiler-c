#ifndef TERCETO_H
#define TERCETO_H
#include "list.h"
#define VAR_INT 1
#define VAR_FLOAT 2
#define VAR_STRING 3
#define CMP_INT 5
#define SUM_INT 6
#define RES_INT 7
#define MUL_INT 8
#define DIV_INT 9
#define STRING_ASIG 10
#define FLOAT_ASIG 11
#define INT_ASIG 12
#define BLE_INT 14
#define BGT_INT 15
#define BGE_INT 16
#define BI 17
#define PRINT_STR 18
#define PRINT_CTE_STR 19
#define INT_OP 22
#define READ_STRING 23
#define READ_INT 24
#define READ_FLOAT 25
#define PRINT_INT 26
#define PRINT_FLOAT 27
#define PRINT_STR_SIN_NEW_LINE 28
#define PRINT_INT_SIN_NEW_LINE 29
#define ARIT_ASIG_INT 31
#define FLOAT_OP 32
#define SUM_FLOAT 33
#define RES_FLOAT 34
#define MUL_FLOAT 35
#define DIV_FLOAT 36
#define ARIT_ASIG_FLOAT 37
#define CMP_FLOAT 38
#define BLE_FLOAT 39
#define BGT_FLOAT 40
#define BGE_FLOAT 41
#define PRINT_FLOAT_SIN_NEW_LINE 42

typedef struct {
    int indice;
    char operador[50];
    char op1[50];
    char op2[50];
} tTerceto;




int get_terceto_para_asm(tLista* terceto_lista, tLista* symbol_table, int indice, tTerceto* terceto_destino);
void init_tercetos(tLista* terceto_table);
int agregar_terceto(tTerceto t, tLista* terceto_lista, char* operador, char* op1, char* op2);
void terceto_to_file(char* output_file, tLista* terceto_lista);
int obtener_indice_actual();
int actualizar_terceto(tLista* terceto_lista, int indice, char* operador, char* op1, char* op2);
int get_terceto(tLista* terceto_lista, int indice, tTerceto* terceto_destino);
int actualizar_op2(tLista* terceto_lista, int indice, char* op2);
#endif // TERCETO_H