// Usa Lexico_ClasePractica
//Solo expresiones sin ()
%{
#include <stdio.h>
#include <stdlib.h>

int yystopparser=0;

int yyerror();
extern int yylex();
extern int yyparser();
extern File* yyin;


%}

%start program

%token DIGITO
%token LETRA
%token BOOL

%token OP_ASIG
%token OP_SUM
%token OP_RES
%token OP_MUL
%token OP_DIV

%token MAYOR
%token MAYOR_IGUAL
%token MENOR
%token MENOR_IGUAL

%token AND
%token OR
%token NOT

%token PA
%token PC

%token CBO
%token CBC
%token OPEN_COMM
%token CLOSE_COMM

%token READ
%token WRITE
%token IF
%token ELSE
%token INIT
%token WHILE
%token SLICE_AND_CONCAT
%token TIPO_DATO

%token ID

%token PUNTO
%token COM
%token DOS_PUNTOS
%token COMA

%token CTE_INT
%token CTE_FLOAT
%token CTE_STRING
%token CTE_BOOL


%%

program


%%



int main(int argc, char *argv[])
{
    if((yyin = fopen(argv[1], "rt"))==NULL)
    {
        printf("\nNo se puede abrir el archivo de prueba: %s\n", argv[1]);
        return 1;
    }

    int parserResult = yyparser();


	fclose(yyin);
    return 0;
}

int yyerror(void)
{
    printf("Error Sintactico\n");
	exit (1);
}
