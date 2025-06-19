#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include "symbol.h"
#include "list.h"

void put_in_file(void* s, void* output_file);
int cmp_symbols_by_name(const void* s1, const void* s2);
void sanitize_symbol_name(void* s, void* unused);
void sanitize_string(char* str);

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

void create_symbol_table(tLista* symbol_table){
    crearLista(symbol_table);
}

int get_symbol_by_name(char* name, symbol* symbol_destino, tLista* symbol_table){
    symbol search_symbol;
    strcpy(search_symbol.name, name);
    return buscarElemento(symbol_table, &search_symbol, symbol_destino, sizeof(symbol), cmp_symbols_by_name);
}

int cmp_symbols_by_name(const void* s1, const void* s2) {
    const symbol* cast_s1 = (const symbol*)s1;
    const symbol* cast_s2 = (const symbol*)s2;
    return strcmp(cast_s1->name, cast_s2->name);
}

void insert_symbol(symbol s, tLista* symbol_table){
    ponerOrdenado(symbol_table,&s,sizeof(symbol),cmp_symbols_by_name);
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

void symbol_table_to_file(char* output_file, tLista* symbol_table){
    write_header(output_file);
    recorrerLista(symbol_table, put_in_file, output_file);
}

int get_symbol_by_index(unsigned index, symbol* symbol_destino, tLista* symbol_table)
{
    return obtenerElemento(symbol_table, symbol_destino, sizeof(symbol), index);
}

int get_value_by_name(char* name, char* value_destino, tLista* symbol_table) {
    symbol found_symbol;
    
    if (get_symbol_by_name(name, &found_symbol, symbol_table) == 1) {
        strcpy(value_destino, found_symbol.value);
        return 1; // Símbolo encontrado
    }
    
    return 0; // Símbolo no encontrado
}

void sanitize_string(char* str) {
    for (int i = 0; str[i] != '\0'; i++) {
        if (!isalnum(str[i])) {
            str[i] = '_';
        }
    }
}

void sanitize_symbol_name(void* s, void* unused) {
    symbol* sym = (symbol*)s;
    sanitize_string(sym->name);
}

void sanitize_all_symbol_names(tLista* symbol_table) {
    recorrerLista(symbol_table, sanitize_symbol_name, NULL);
}