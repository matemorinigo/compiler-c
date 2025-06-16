#ifndef VARIABLE_CHECKS_H
#define VARIABLE_CHECKS_H

#include "symbol.h"
#include "list.h"

#define VAR_EXISTS 1
#define VAR_DONT_EXISTS 0
#define SAME_DATATYPE 0
#define DIFFERENT_DATATYPE 1
#define IS_STRING 1
#define IS_NOT_STRING 0
#define IS_NUMERIC 1
#define IS_NOT_NUMERIC 0
#define IS_INT 1
#define IS_NOT_INT 0

void crear_variable(char* var_name, char* data_type, tLista* symbol_table);
int check_var_exists(char* var_name, tLista* symbol_table);
int compare_datatypes(char* elem1, char* elem2, tLista* symbol_table);
int check_var_is_string(char* var_name, tLista* symbol_table);
int check_var_is_numeric(char* var_name, tLista* symbol_table);
int check_var_is_int(char* var_name, tLista* symbol_table);

#endif // VARIABLE_CHECKS_H