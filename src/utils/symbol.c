#include <stdio.h>
#include <string.h>
#include "symbol.h"
#include "list.h"

void put_in_file(void* s, void* output_file);
int cmp_symbols(const void* s1, const void* s2);
int cmp_symbols_by_name(const void* s1, const void* s2);

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

int cmp_symbols_by_name(const void* s1, const void* s2) {
    const symbol* cast_s1 = (const symbol*)s1;
    const symbol* cast_s2 = (const symbol*)s2;
    return strcmp(cast_s1->name, cast_s2->name);
}

void insert_symbol(symbol s, tLista* symbol_table){
    symbol existing_symbol;
    
    // Buscar si ya existe un símbolo con el mismo nombre
    if (buscarElemento(symbol_table, &s, &existing_symbol, sizeof(symbol), cmp_symbols_by_name)) {
        // Si existe, actualizar sus datos (especialmente el tipo de dato si no lo tenía)
        if (strlen(existing_symbol.data_type) == 0 && strlen(s.data_type) > 0) {
            strcpy(existing_symbol.data_type, s.data_type);
        }
        if (strlen(existing_symbol.value) == 0 && strlen(s.value) > 0) {
            strcpy(existing_symbol.value, s.value);
        }
        if (existing_symbol.length == 0 && s.length > 0) {
            existing_symbol.length = s.length;
        }
        
        // Actualizar el nodo existente
        actualizarNodo(symbol_table, &s, &existing_symbol, sizeof(symbol), cmp_symbols_by_name);
    } else {
        // Si no existe, insertarlo usando cmp_symbols_by_name para evitar duplicados
        ponerOrdenado(symbol_table, &s, sizeof(symbol), cmp_symbols_by_name);
    }
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

int update_symbol_data_type(const char* name, const char* new_data_type, tLista* symbol_table) {
    symbol search_symbol;
    symbol found_symbol;
    
    // Crear un símbolo temporal para la búsqueda
    strcpy(search_symbol.name, name);
    
    // Buscar el símbolo en la tabla
    if (!buscarElemento(symbol_table, &search_symbol, &found_symbol, sizeof(symbol), cmp_symbols_by_name)) {
        return 0; // Símbolo no encontrado
    }
    
    // Actualizar el data_type del símbolo encontrado
    strcpy(found_symbol.data_type, new_data_type);
    
    // Actualizar el nodo en la lista
    return actualizarNodo(symbol_table, &search_symbol, &found_symbol, sizeof(symbol), cmp_symbols_by_name);
}