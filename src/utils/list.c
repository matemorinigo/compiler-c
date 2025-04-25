#include <stdlib.h>
#include <string.h>
#include "list.h"

#define MIN(x,y) ((x) >= (y) ? (y) : (x))

void crearLista(tLista* pl)
{
    *pl = NULL;
}

int ponerAlFinal(tLista* pl,const void* dato,size_t tamDato)
{
    tNodo* nuevo;

    if((nuevo = (tNodo*)malloc(sizeof(tNodo))) == NULL ||
            (nuevo->dato = malloc(tamDato)) == NULL)
    {
        free(nuevo);
        return 0;
    }

    while(*pl)
        pl = &(*pl)->siguiente;

    memcpy(nuevo->dato,dato,tamDato);
    nuevo->tamDato = tamDato;
    nuevo->siguiente = NULL;

    *pl = nuevo;

    return 1;
}

int ponerAlInicio(tLista* pl,const void* dato,size_t tamDato)
{
    tNodo* nuevo;

    if((nuevo = (tNodo*)malloc(sizeof(tNodo))) == NULL ||
            (nuevo->dato = malloc(tamDato)) == NULL)
    {
        free(nuevo);
        return 0;
    }

    memcpy(nuevo->dato,dato,tamDato);
    nuevo->tamDato = tamDato;

    nuevo->siguiente = *pl;
    *pl = nuevo;

    return 0;
}

int ponerOrdenado(tLista* pl,const void* dato,size_t tamDato,int cmp(const void*,const void*))
{
    tNodo* nuevo;

    if((nuevo = (tNodo*)malloc(sizeof(tNodo))) == NULL ||
            (nuevo->dato = malloc(tamDato)) == NULL)
    {
        free(nuevo);
        return 0;
    }

    while(*pl && cmp((*pl)->dato,dato) < 0)
    {
        pl = &(*pl)->siguiente;
    }
    if(*pl && cmp((*pl)->dato,dato) == 0)
    {
        return 1;
    }

    memcpy(nuevo->dato,dato,tamDato);
    nuevo->tamDato = tamDato;

    nuevo->siguiente = *pl;
    *pl = nuevo;

    return 1;
}

int sacarUltimo(tLista* pl,void* destino,size_t tamDato)
{
    if(!(*pl))
        return 0;

    while((*pl)->siguiente)
        pl = &(*pl)->siguiente;

    memcpy(destino,(*pl)->dato,MIN(tamDato,(*pl)->tamDato));

    free((*pl)->dato);
    free(*pl);
    *pl = NULL;

    return 1;
}

int sacarPrimero(tLista* pl,void* destino,size_t tamDato)
{
    tNodo* nae;

    if(!(*pl))
        return 0;

    memcpy(destino,(*pl)->dato,MIN(tamDato,(*pl)->tamDato));

    nae = *pl;
    *pl = nae->siguiente;
    free(nae->dato);
    free(nae);

    return 1;
}

int sacarElemento(tLista* pl,void* destino,size_t tamDato,unsigned pos)
{
    tNodo* nae;

    while(*pl && pos--)
        pl = &(*pl)->siguiente;

    if(*pl == NULL)
        return 0;

    nae = *pl;
    memcpy(destino,nae->dato,MIN(tamDato,nae->tamDato));
    *pl = nae->siguiente;

    free(nae->dato);
    free(nae);

    return 1;
}

void vaciarLista(tLista* pl)
{
    tNodo* nae;

    while(*pl)
    {
        nae = *pl;
        pl = &(*pl)->siguiente;
        free(nae->dato);
        free(nae);
    }
}

void recorrerLista(tLista* pl,void funcion(void*, void*), void* param)
{
    while(*pl)
    {
        funcion((*pl)->dato, param);
        pl = &(*pl)->siguiente;
    }
}

void filtrarLista(tLista* pl,int ffiltro(const void*))
{
    tNodo* nae;

    while(*pl)
    {
        if(ffiltro((*pl)->dato))
        {
            nae = *pl;
            *pl = nae->siguiente;
            free(nae->dato);
            free(nae);
        }
        else
            pl = &(*pl)->siguiente;
    }
}

void reducirLista(tLista* pl,void* acum,void funcion(const void*,void*))
{
    while(*pl)
    {
        funcion((*pl)->dato,acum);
        pl = &(*pl)->siguiente;
    }
}

void ordenarListaInsercion(tLista* pl,int cmp(const void*,const void*))
{
    tLista listaOrdenada = NULL;
    tLista* pListaOrdenada;
    tNodo* nodo;

    while(*pl)
    {
        nodo = *pl;
        *pl = nodo->siguiente;

        pListaOrdenada = &listaOrdenada;
        while(*pListaOrdenada && cmp((*pListaOrdenada)->dato,nodo->dato) < 0)
        {
            pListaOrdenada = &(*pListaOrdenada)->siguiente;
        }
        nodo->siguiente = *pListaOrdenada;
        *pListaOrdenada = nodo;
    }

    *pl = listaOrdenada;
}

tNodo** buscarMenorLista(tLista* pl, int cmp(const void*,const void*))
{
    tNodo** menor = pl;

    while( *(pl = &(*pl)->siguiente) )
    {
        if(cmp((*menor)->dato,(*pl)->dato) > 0)
        {
            menor = pl;
        }
    }
    return menor;
}

void ordenarListaSeleccion(tLista* pl,int cmp(const void*,const void*))
{
    tLista listaOrdenada = NULL;
    tLista* pListaOrdenada = &listaOrdenada;
    tNodo** aux;
    tNodo* menor;

    while(*pl)
    {
        aux = buscarMenorLista(pl,cmp);
        menor = *aux;
        *aux = menor->siguiente;

        *pListaOrdenada = menor;
        pListaOrdenada = &(menor->siguiente);
    }
    *pListaOrdenada = NULL;
    *pl = listaOrdenada;
}