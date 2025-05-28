#include <stdio.h>
#include <string.h>
#define SLICE_AND_CONCAT_OK 0
#define SLICE_AND_CONCAT_ERROR 1

int validar_concatenarEnPalabra1(int concatenarEnPalabra1) {
    if (concatenarEnPalabra1 < 0 || concatenarEnPalabra1 > 1) {
        return SLICE_AND_CONCAT_ERROR;
    }
    return SLICE_AND_CONCAT_OK;
}

int validar_limites(int posicion_inicial, int posicion_final, char* palabra) {
    if (posicion_inicial < 0 || posicion_final > strlen(palabra) || posicion_inicial > posicion_final) {
        return SLICE_AND_CONCAT_ERROR;
    }
    return SLICE_AND_CONCAT_OK;
}

int slice_and_concat( char* str_final, char* palabra_entera, char* palabra_cortada, int posicion_inicial, int posicion_final) {
    char aux[50];
    char temp[50];
    int largo_palabra_entera = strlen(palabra_entera);
    int largo_str_final = largo_palabra_entera + (posicion_final-posicion_inicial);

    if (largo_str_final > 48) {
        return SLICE_AND_CONCAT_ERROR;
    }
    strcpy(str_final, palabra_entera);
    strncat(str_final, palabra_cortada + posicion_inicial, posicion_final - posicion_inicial + 1);

    sprintf(temp, "\"%s\"", str_final);
    strcpy(str_final, temp);

    return SLICE_AND_CONCAT_OK;
}

void eliminar_caracter(char *str, char caracter) {
    if (str == NULL) return;

    char *src = str;
    char *dst = str;

    while (*src) {
        if (*src != caracter) {
            *dst = *src;
            dst++;
        }
        src++;
    }
    *dst = '\0';
}

