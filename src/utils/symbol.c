#include <stdio.h>
#include <string.h>
#include "symbol.h"
#include "list.h"


void put_in_file(void* s, void* output_file);
int cmp_symbols(const void* s1, const void* s2);

void put_in_file(void* s, void* output_file){

    FILE* file = fopen((const char*)output_file, "a");
    symbol* sym = (symbol*)s;

    if (file == NULL) {
        perror("No se pudo abrir el archivo");
        return;
    }

    fprintf(file, "%-55s|%-10s|%-55s|%-5d\n", sym->name, sym->data_type, sym->value, sym->length);

    fclose(file);
}

void create_symbol_table(){
    crearLista(&symbol_table);
}

int cmp_symbols(const void* s1, const void* s2) {
    const symbol* cast_s1 = (const symbol*)s1;
    const symbol* cast_s2 = (const symbol*)s2;

    // Comparar por name
    int cmp = strcmp(cast_s1->name, cast_s2->name);
    if (cmp != 0) return cmp;

    // Comparar por data_type
    cmp = strcmp(cast_s1->data_type, cast_s2->data_type);
    if (cmp != 0) return cmp;

    // Comparar por value
    cmp = strcmp(cast_s1->value, cast_s2->value);
    if (cmp != 0) return cmp;

    // Comparar por length
    return cast_s1->length - cast_s2->length;
}

void insert_symbol(symbol s){
    ponerOrdenado(&symbol_table,&s,sizeof(symbol),cmp_symbols);
}

void write_header(const char* output_file) {
    FILE* file = fopen(output_file, "w");
    if (file == NULL) {
        perror("No se pudo abrir el archivo para escribir encabezado");
        return;
    }

    fprintf(file, "%-55s|%-10s|%-55s|%-5s\n", "Nombre", "Tipo dato", "Valor", "Longitud");
    fclose(file);
}


void symbol_table_to_file(char* output_file){
    write_header(output_file);
    recorrerLista(&symbol_table, put_in_file, output_file);
}