#ifndef SLICE_AND_CONCAT_H_INCLUDED
#define SLICE_AND_CONCAT_H_INCLUDED

int validar_concatenarEnPalabra1(int concatenarEnPalabra1);
int validar_limites(int posicion_inicial, int posicion_final, char* palabra);
int slice_and_concat( char* str_final, char* palabra_entera, char* palabra_cortada, int posicion_inicial, int posicion_final);
void eliminar_caracter(char *str, char caracter);

#endif // SLICE_AND_CONCAT_H_INCLUDED
