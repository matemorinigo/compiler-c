#include <stdio.h>
#include <string.h>
#include "terceto.h"

void crear_print_tercetos(int contador, int contador_expresiones_reorder, const char *nombre_base_variable_aux, tLista *lista_tercetos) 
{
    tTerceto terceto;
    char nombre_dinamico_variable[50];
    agregar_terceto(terceto, lista_tercetos, "PRINT_STR", "T_corchete_abre", NULL);
    contador = 0;
    //Printeamos todas las expresiones que caen antes del pivote
    while(contador < contador_expresiones_reorder)
    {
        contador++;
        sprintf(nombre_dinamico_variable, "%s%d", nombre_base_variable_aux, contador);
        agregar_terceto(terceto, lista_tercetos, "PRINT_INT", nombre_dinamico_variable, NULL);
        if(contador <= contador_expresiones_reorder)
            agregar_terceto(terceto, lista_tercetos, "PRINT_STR", "T_coma", NULL);
    }
    agregar_terceto(terceto, lista_tercetos, "PRINT_STR", "T_corchete_cierra", NULL);

}

void crear_tercetor_ordenamiento(int inicio_ordenamiento, int fin_ordenamiento, const char *nombre_base_variable_aux, tLista *lista_tercetos)
{
    tTerceto terceto;
    char nombre_dinamico_variable[50];
    for(int i = inicio_ordenamiento; i < fin_ordenamiento - 1; i++)
        {
            int idx_aux;
            int idx_var;
            int idx_min;
            char str_idx_min[50];
            char str_idx_aux[50];
            char str_idx_var[50];

            //El primer elemento es el minimo
            sprintf(nombre_dinamico_variable, "%s%d", nombre_base_variable_aux, i);
            agregar_terceto(terceto, lista_tercetos, "ARIT_ASIG", "min_", nombre_dinamico_variable);

            for(int j = i+1; j < fin_ordenamiento; j++)
            {
                int idx_cond;
                int idx_cond_para_JF;
                char str_idx_cond[50];
                char str_idx_cond_para_JF[50];
                sprintf(nombre_dinamico_variable, "%s%d", nombre_base_variable_aux, j);

                // Comparo var < min
                idx_cond = agregar_terceto(terceto, lista_tercetos, "CMP", nombre_dinamico_variable, "min_");
                sprintf(str_idx_cond,"[%d]",idx_cond);

                // Si min es menor, salto a despues de la asignacion
                sprintf(str_idx_cond_para_JF,"[%d]",idx_cond + 6);
                agregar_terceto(terceto, lista_tercetos, "BGE", str_idx_cond, str_idx_cond_para_JF);

                //// Si var es menor, intercambio

                //aux = min
                agregar_terceto(terceto, lista_tercetos, "ARIT_ASIG", "aux_", "min_");

                //min = var
                agregar_terceto(terceto, lista_tercetos, "ARIT_ASIG", "min_", nombre_dinamico_variable);

                //var = aux
                agregar_terceto(terceto, lista_tercetos, "ARIT_ASIG", nombre_dinamico_variable, "aux_");
            }
            sprintf(nombre_dinamico_variable, "%s%d", nombre_base_variable_aux, i);

            //// Intercambio la variable actual con el minimo
            //aux = min

            idx_aux = agregar_terceto(terceto, lista_tercetos, "ARIT_ASIG", "aux_", "min_");
            sprintf(str_idx_aux,"[%d]",idx_aux);

            //min = var
            agregar_terceto(terceto, lista_tercetos, "ARIT_ASIG", "min_", nombre_dinamico_variable);

            //var = aux
            agregar_terceto(terceto, lista_tercetos, "ARIT_ASIG", nombre_dinamico_variable, "aux_");

        }
}