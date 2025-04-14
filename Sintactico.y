// Usa Lexico_ClasePractica
//Solo expresiones sin ()
%{
#include <stdio.h>
#include <stdlib.h>

int yystopparser=0;


int yyerror();
int yylex();


%}

%token WHILE
%token MT
%token LT
%token CBO
%token CBC
%token OPEN_COMM
%token CLOSE_COMM
%token OP_SUM
%token OP_RES
%token OP_MUL
%token OP_DIV
%token PA
%token PC
%token PUNTO
%token COM
%token READ
%token WRITE
%token IF
%token ELSE 
%token CTE_INT
%token CTE_FLOAT
%token CTE_STRING

%%
input:
    /* vacío */ 
    ;

%%