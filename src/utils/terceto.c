#include <stdio.h>
#include <string.h>
#include "terceto.h"
#include "list.h"
#include "variable_checks.h"

int indice = 0;
int ult_cmp;

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

int obtener_indice_actual() {
    return indice;
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

int actualizar_terceto(tLista* terceto_lista, int indice, char* operador, char* op1, char* op2){
    tTerceto tercetoBuscar = { .indice = indice };
    tTerceto tercetoNuevo = { .indice = indice };
    strcpy(tercetoNuevo.operador, operador);
    strcpy(tercetoNuevo.op1, op1 == NULL ? "NULL" : op1);
    strcpy(tercetoNuevo.op2, op2 == NULL ? "NULL" : op2);

    return actualizarNodo(terceto_lista, &tercetoBuscar, &tercetoNuevo, sizeof(tTerceto), cmp_terceto);
}

int get_terceto(tLista* terceto_lista, int indice, tTerceto* terceto_destino){
    tTerceto tercetoBuscar = { .indice = indice };
    
    return buscarElemento(terceto_lista, &tercetoBuscar, terceto_destino, sizeof(tTerceto), cmp_terceto);
}

int actualizar_op2(tLista* terceto_lista, int indice, char* op2){
    tTerceto tercetoActual;
    
    // Primero obtenemos el terceto actual
    if (get_terceto(terceto_lista, indice, &tercetoActual) == 0) {
        return -1; // Error: terceto no encontrado
    }
    
    // Creamos el terceto actualizado manteniendo los valores existentes
    tTerceto tercetoBuscar = { .indice = indice };
    tTerceto tercetoNuevo = { .indice = indice };
    strcpy(tercetoNuevo.operador, tercetoActual.operador);
    strcpy(tercetoNuevo.op1, tercetoActual.op1);
    strcpy(tercetoNuevo.op2, op2 == NULL ? "NULL" : op2);

    return actualizarNodo(terceto_lista, &tercetoBuscar, &tercetoNuevo, sizeof(tTerceto), cmp_terceto);
}

int get_terceto_para_asm(tLista* terceto_lista, tLista* symbol_table, int indice, tTerceto* terceto_destino){
    int indice_terceto_op1;
    char aux_var[50];
    tTerceto tercetoBuscar = { .indice = indice };
    buscarElemento(terceto_lista, &tercetoBuscar, terceto_destino, sizeof(tTerceto), cmp_terceto);
    
    if(strcmp(terceto_destino->operador, "=:") == 0){
        if(check_var_is_int(terceto_destino->op1, symbol_table)){
            return ARIT_ASIG_INT;
        }
        if(check_var_is_float(terceto_destino->op1, symbol_table)){
            return ARIT_ASIG_FLOAT;
        }
    }
    if(strcmp(terceto_destino->operador, ":=") == 0){
        if(check_var_is_int(terceto_destino->op1, symbol_table)){
            return INT_ASIG;
        }
        if(check_var_is_float(terceto_destino->op1, symbol_table)){
            return FLOAT_ASIG;
        }
        if(check_var_is_string(terceto_destino->op1, symbol_table)){
            return STRING_ASIG;
        }
        return -1;
    }
    if(strcmp(terceto_destino->operador, "SUM") == 0){
        sscanf(terceto_destino->op1, "[%d]", &indice_terceto_op1);
        sprintf(aux_var, "aux_var_%d", indice_terceto_op1);
        if(check_var_is_int(aux_var, symbol_table)){
            return SUM_INT;
        }
        if(check_var_is_float(aux_var, symbol_table)){
            return SUM_FLOAT;
        }
    }
    if(strcmp(terceto_destino->operador, "RES") == 0){
        sscanf(terceto_destino->op1, "[%d]", &indice_terceto_op1);
        sprintf(aux_var, "aux_var_%d", indice_terceto_op1);
        if(check_var_is_int(aux_var, symbol_table)){
            return RES_INT;
        }
        if(check_var_is_float(aux_var, symbol_table)){
            return RES_FLOAT;
        }
    }
    if(strcmp(terceto_destino->operador, "MUL") == 0){
        sscanf(terceto_destino->op1, "[%d]", &indice_terceto_op1);
        sprintf(aux_var, "aux_var_%d", indice_terceto_op1);
        if(check_var_is_int(aux_var, symbol_table)){
            return MUL_INT;
        }
        if(check_var_is_float(aux_var, symbol_table)){
            return MUL_FLOAT;
        }
    }
    if(strcmp(terceto_destino->operador, "DIV") == 0){
        sscanf(terceto_destino->op1, "[%d]", &indice_terceto_op1);
        sprintf(aux_var, "aux_var_%d", indice_terceto_op1);
        if(check_var_is_int(aux_var, symbol_table)){
            return DIV_INT;
        }
        if(check_var_is_float(aux_var, symbol_table)){
            return DIV_FLOAT;
        }
    }
    if(strcmp(terceto_destino->operador, "CMP") == 0){
        if(check_var_is_int(terceto_destino->op1, symbol_table)){
            ult_cmp = CMP_INT;
            return CMP_INT;
        }
        if(check_var_is_float(terceto_destino->op1, symbol_table)){
            ult_cmp = CMP_FLOAT;
            return CMP_FLOAT;
        }
    }
    if(strcmp(terceto_destino->operador, "BLE") == 0){
        if(ult_cmp == CMP_INT){
            return BLE_INT;
        }
        if(ult_cmp == CMP_FLOAT){
            return BLE_FLOAT;
        }
    }
    if(strcmp(terceto_destino->operador, "BGT") == 0){
        if(ult_cmp == CMP_INT){
            return BGT_INT;
        }
        if(ult_cmp == CMP_FLOAT){
            return BGT_FLOAT;
        }
    }
    if(strcmp(terceto_destino->operador, "BGE") == 0){
        if(ult_cmp == CMP_INT){
            return BGE_INT;
        }
        if(ult_cmp == CMP_FLOAT){
            return BGE_FLOAT;
        }
    }
    if(strcmp(terceto_destino->operador, "BI") == 0){
        return BI;
    }
    if(strcmp(terceto_destino->operador, "READ_STRING") == 0){
        return READ_STRING;
    }
    if(strcmp(terceto_destino->operador, "READ_INT") == 0){
        return READ_INT;
    }
    if(strcmp(terceto_destino->operador, "READ_FLOAT") == 0){
        return READ_FLOAT;
    }
    if(strcmp(terceto_destino->operador, "PRINT_INT") == 0){
        return PRINT_INT;
    }
    if(strcmp(terceto_destino->operador, "PRINT_FLOAT") == 0){
        return PRINT_FLOAT;
    }
    if(strcmp(terceto_destino->operador, "PRINT_STR") == 0){
        return PRINT_STR;
    }
    if(strcmp(terceto_destino->operador, "PRINT_CTE_STR") == 0){
        return PRINT_CTE_STR;
    }
    if(strcmp(terceto_destino->operador, "PRINT_STR_SIN_NEW_LINE") == 0){
        return PRINT_STR_SIN_NEW_LINE;
    }
    if(strcmp(terceto_destino->operador, "PRINT_INT_SIN_NEW_LINE") == 0){
        return PRINT_INT_SIN_NEW_LINE;
    }
    if(strcmp(terceto_destino->operador, "PRINT_FLOAT_SIN_NEW_LINE") == 0){
        return PRINT_FLOAT_SIN_NEW_LINE;
    }
    // Si llego hasta aca, es que el operador es una variable que sera usada para una operacion aritmetica.
    if(check_var_is_int(terceto_destino->operador, symbol_table)){
        return INT_OP;
    }
    if(check_var_is_float(terceto_destino->operador, symbol_table)){
        return FLOAT_OP;
    }
    printf("Terceto: %s %s %s\n", terceto_destino->operador, terceto_destino->op1, terceto_destino->op2);
    return -1;
}