#ifndef SIMBOLS_H
#define SIMBOLS_H
#include "list.h"

typedef struct {
    char name[255];
    char data_type[50];
    char value[50];
    int length;
} symbol;

tLista symbol_table;

void create_symbol_table();
void insert_symbol(symbol s);
void symbol_table_to_file(char* output_file);


#endif // SIMBOLS_H
