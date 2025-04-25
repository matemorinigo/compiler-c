#ifndef SIMBOLS_H
#define SIMBOLS_H
#include "list.h"

typedef struct {
    char name[255];
    char data_type[50];
    char value[50];
    int length;
} symbol;


void create_symbol_table(tLista* l);
void insert_symbol(symbol s, tLista* l);
void symbol_table_to_file(char* output_file, tLista* l);


#endif // SIMBOLS_H
