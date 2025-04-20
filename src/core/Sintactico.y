// Usa Lexico_ClasePractica
//Solo expresiones sin ()
%{
#include <stdio.h>
#include <stdlib.h>
int yyerror(char* e);
int yystopparser=0;

extern int yylex();
extern int yyparser();
extern FILE* yyin;


%}

%start start

%token DIGITO
%token LETRA
%token BOOL

%token OP_ASIG
%token OP_ARIT
%token OP_SUM
%token OP_RES
%token OP_MUL
%token OP_DIV

%token MAYOR
%token MAYOR_IGUAL
%token MENOR
%token MENOR_IGUAL

%left AND
%left OR
%right NOT

%token PA
%token PC

%token CBO
%token CBC
%token OPEN_COMM
%token CLOSE_COMM
%token OPEN_BRACKET
%token CLOSE_BRACKET

%token READ
%token WRITE
%token IF
%token ELSE
%token INIT
%token WHILE
%token SLICE_AND_CONCAT
%token REORDER
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

start:
    program

program:
    declarations group_of_sentences
    ;

declarations: 
    INIT CBO multiple_datatype_declaration CBC
    ;

multiple_datatype_declaration:
    datatype_declaration
    | multiple_datatype_declaration datatype_declaration
    ;

datatype_declaration:
    var_list DOS_PUNTOS TIPO_DATO
    ;

var_list:
    ID
    | var_list COMA ID
    ;

group_of_sentences:
    sentence
    | group_of_sentences sentence
    ;

sentence:
    assignment
    | loop
    | selection
    | arithmetic_assig
    | input
    | output
    ;

assignment:
    ID OP_ASIG cte
    ;

cte:
    CTE_INT
    | CTE_FLOAT
    | CTE_STRING
    ;

selection:
    IF PA condition PC CBO group_of_sentences CBC
    | IF PA condition PC CBO group_of_sentences CBC ELSE CBO group_of_sentences CBC
    ;

loop:
    WHILE PA condition PC CBO group_of_sentences CBC
    ;

condition:
    comparison
    | condition AND comparison
    | condition OR comparison
    | NOT condition
    ;

comparison:
    expression comparator expression
    ;

arithmetic_assig:
    ID OP_ARIT expression
    ;


comparator:
    MAYOR
    | MAYOR_IGUAL
    | MENOR_IGUAL
    | MENOR
    ;

expression:
    expression OP_SUM term
    | expression OP_RES term
    | term
    ;

term:
    term OP_MUL factor
    | term OP_DIV factor
    | factor
    ;

factor:
    PA expression PC
    | ID
    | CTE_INT
    | CTE_FLOAT
    ;


input:
    READ PA ID PC
    ;

output:
    WRITE PA cte PC
    | WRITE PA ID PC
    ;

%%



int main(int argc, char *argv[])
{
    if((yyin = fopen(argv[1], "rt"))==NULL)
    {
        printf("\nNo se puede abrir el archivo de prueba: %s\n", argv[1]);
        return 1;
    }

    int parserResult = yyparse();

	fclose(yyin);

	printf("Syntax OK \n");
    return 0;
}

int yyerror(char* e)
{
    printf("Error Sintactico\n");
	exit (1);
}
