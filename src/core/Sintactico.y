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
    program {printf("program\n");}

program:
    declarations group_of_sentences {printf("declaracion_programa\n");}
    ;

declarations: 
    INIT CBO multiple_datatype_declaration CBC {printf("Area_declaracion_variables\n");}
    ;

multiple_datatype_declaration:
    datatype_declaration {printf("linea_declaracion_variables\n");}
    | multiple_datatype_declaration datatype_declaration {printf("linea_declaracion_variables\n");}
    ;

datatype_declaration:
    var_list DOS_PUNTOS TIPO_DATO {printf("declaracion de variables\n");}
    ;

var_list:
    ID {printf("lista_De_variables\n");}
    | var_list COMA ID {printf("lista_De_variables\n");}
    ;

group_of_sentences:
    sentence {printf("sentencia de codigo\n");}
    | group_of_sentences sentence {printf("sentencia de codigo\n");}
    ;

sentence:
    assignment
    | loop
    | selection
    | arithmetic_assig
    | input
    | output
    | sliceAndConcat
    | reorder
    ;

assignment:
    ID OP_ASIG cte {printf("asignacion\n");}
    ;

cte:
    CTE_INT {printf("cte_int\n");}
    | CTE_FLOAT {printf("cte_float\n");}
    | CTE_STRING {printf("cte_string\n");}
    ;

selection:
    IF PA condition PC CBO group_of_sentences CBC {printf("if\n");}
    | IF PA condition PC CBO group_of_sentences CBC ELSE CBO group_of_sentences CBC {printf("if_else\n");}
    ;

loop:
    WHILE PA condition PC CBO group_of_sentences CBC {printf("while\n");}
    ;

condition:
    comparison
    | condition AND comparison {printf("condicion and\n");}
    | condition OR comparison {printf("condicion or\n");}
    | NOT condition {printf("condicion not\n");}
    ;

comparison:
    expression comparator expression {printf("comparacion\n");}
    ;

arithmetic_assig:
    ID OP_ARIT expression {printf("comparacion aritmetica\n");}
    ;


comparator:
    MAYOR {printf("comparacion mayot\n");}
    | MAYOR_IGUAL {printf("comparacion mayor_igual\n");}
    | MENOR_IGUAL {printf("comparacion menor_igual\n");}
    | MENOR {printf("comparacion menor\n");}
    ;

expression:
    expression OP_SUM term {printf("opreacion suma\n");}
    | expression OP_RES term {printf("opreacion resta\n");}
    | term {printf("termino\n");}
    ;

term:
    term OP_MUL factor {printf("opreacion multiplicacion\n");}
    | term OP_DIV factor {printf("opreacion division\n");}
    | factor {printf("factor\n");}
    ;

factor:
    PA expression PC {printf("expresion entre Parentesis\n");}
    | ID {printf("factor_id\n");}
    | CTE_INT {printf("factor_cte_int\n");}
    | CTE_FLOAT {printf("factor_cte_float\n");}
    ;


input:
    READ PA ID PC {printf("lectura_x_consola\n");}
    ;

output:
    WRITE PA cte PC {printf("escritura_x_consola\n");}
    | WRITE PA ID PC {printf("escritura_x_consola\n");}
    ;

sliceAndConcat: /*El ultimo cte/id tendria que ser un bool*/
    SLICE_AND_CONCAT PA cte_int_o_id COMA cte_int_o_id COMA cte_string_o_id COMA cte_string_o_id COMA cte_int_o_id PC 
    {printf("sliceAndConcat\n");}
    ;

reorder: /*El anteultimo cte/id tendria que ser un bool*/
    REORDER PA OPEN_BRACKET lista_expresiones CLOSE_BRACKET COMA cte_int_o_id COMA cte_int_o_id PC {printf("reorder\n");}
    ;

lista_expresiones:
    lista_expresiones COMA expression
    | expression
    ;

cte_int_o_id:
    CTE_INT {printf("parametro_cte_int\n");}
    | ID {printf("parametro_id\n");}
    ;

cte_string_o_id:
    CTE_STRING {printf("parametro_cte_string\n");}
    | ID {printf("parametro_id\n");}
    ;

/*cte_bool_o_id:
    CTE_BOOL
    | ID {printf("id\n");}
    ;*/

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
