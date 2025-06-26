#ifndef LISTASIMPLEMENTEENLAZADA_H_INCLUDED
#define LISTASIMPLEMENTEENLAZADA_H_INCLUDED
#include <stdlib.h>

typedef struct sNodo
{
    void* dato;
    size_t tamDato;
    struct sNodo* siguiente;
} tNodo;

typedef tNodo* tLista;

void crearLista(tLista* pl);
int ponerAlFinal(tLista* pl,const void* dato,size_t tamDato);
int ponerAlInicio(tLista* pl,const void* dato,size_t tamDato);
int ponerOrdenado(tLista* pl,const void* dato,size_t tamDato,int cmp(const void*,const void*));
int sacarUltimo(tLista* pl,void* destino,size_t tamDato);
int sacarPrimero(tLista* pl,void* destino,size_t tamDato);
int sacarElemento(tLista* pl,void* destino,size_t tamDato,unsigned pos);
void vaciarLista(tLista* pl);
void vaciarListaSinDestruir(tLista* pl);
void recorrerLista(tLista* pl,void funcion(void*, void*), void* param);
void filtrarLista(tLista* pl,int ffiltro(const void*));
void reducirLista(tLista* pl,void* acum,void funcion(const void*,void*));
void ordenarListaInsercion(tLista* pl,int cmp(const void*,const void*));
tNodo** buscarMenorLista(tLista* pl, int cmp(const void*,const void*));
void ordenarListaSeleccion(tLista* pl,int cmp(const void*,const void*));
int actualizarNodo(tLista* pl, const void* datoBuscar, const void* datoNuevo, size_t tamDato, int cmp(const void*, const void*));
int buscarElemento(tLista* pl, const void* datoBuscar, void* destino, size_t tamDato, int cmp(const void*, const void*));
int obtenerElemento(tLista* pl, void* destino, size_t tamDato, unsigned pos);

#endif // LISTASIMPLEMENTEENLAZADA_H_INCLUDED
