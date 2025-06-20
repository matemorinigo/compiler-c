#include "variable_checks.h"
#include <string.h>

#define TO_LOWER(c) (((c) >= 'A' && (c) <= 'Z') ? ((c) + 32) : (c))

void to_lower(char* str){
    for(int i = 0; i < strlen(str); i++){
        str[i] = TO_LOWER(str[i]);
    }
}

int crear_variable(char* var_name, char* data_type, tLista* symbol_table){
    symbol sym;

    strcpy(sym.name, var_name);
    to_lower(data_type);
    strcpy(sym.data_type, data_type);
    strcpy(sym.value, "");
    sym.length = strlen(var_name);

    if(check_var_exists(var_name, symbol_table)){
        return -1;	
    }

    insert_symbol(sym, symbol_table);
    return 0;
}

int check_var_exists(char* var_name, tLista* symbol_table){
    symbol sym;

    return get_symbol_by_name(var_name, &sym, symbol_table);
}

int compare_datatypes(char* elem1, char* elem2, tLista* symbol_table){
    symbol sym1;
    symbol sym2;

    get_symbol_by_name(elem1, &sym1, symbol_table);
    get_symbol_by_name(elem2, &sym2, symbol_table);

    if(strcmp(sym1.data_type, sym2.data_type)){
        return DIFFERENT_DATATYPE;
    }
    return SAME_DATATYPE;
}

int check_var_is_string(char* var_name, tLista* symbol_table){
    symbol sym;
    
    if(!get_symbol_by_name(var_name, &sym, symbol_table)){
        return IS_NOT_STRING; // Variable no existe
    }
    
    if(strcmp(sym.data_type, "string") == 0){
        return IS_STRING;
    }
    return IS_NOT_STRING;
}

int check_var_is_numeric(char* var_name, tLista* symbol_table){
    symbol sym;
    
    if(!get_symbol_by_name(var_name, &sym, symbol_table)){
        return IS_NOT_NUMERIC; // Variable no existe
    }
    
    if(strcmp(sym.data_type, "int") == 0 || strcmp(sym.data_type, "float") == 0){
        return IS_NUMERIC;
    }
    return IS_NOT_NUMERIC;
}

int check_var_is_int(char* var_name, tLista* symbol_table){
    symbol sym;
    
    if(!get_symbol_by_name(var_name, &sym, symbol_table)){
        return IS_NOT_INT; // Variable no existe
    }

    if(strcmp(sym.data_type, "int") == 0){
        return IS_INT;
    }
    return IS_NOT_INT;
}

int check_var_is_float(char* var_name, tLista* symbol_table){
    symbol sym;
    
    if(!get_symbol_by_name(var_name, &sym, symbol_table)){
        return IS_NOT_FLOAT; // Variable no existe
    }

    if(strcmp(sym.data_type, "float") == 0){
        return IS_FLOAT;
    }
    return IS_NOT_FLOAT;
}