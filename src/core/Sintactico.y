// Usa Lexico_ClasePractica
//Solo expresiones sin ()
%{
#include <stdio.h>
#include <stdlib.h>
#include "symbol.h"

extern char* yytext;

#define RULE(x) printf("Rule recognized: %s \n", x);
int yyerror(char* e);
int yystopparser=0;
tLista symbol_table;

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
    declarations group_of_sentences {RULE("program -> declarations group_of_sentences");}
    ;

declarations: 
    INIT CBO multiple_datatype_declaration CBC {RULE("declarations -> INIT CBO multiple_datatype_declaration CBC");}
    ;

multiple_datatype_declaration:
    datatype_declaration {RULE("multiple_datatype_declaration -> datatype_declaration");}
    | multiple_datatype_declaration datatype_declaration {RULE("multiple_datatype_declaration -> multiple_datatype_declaration datatype_declaration");}
    ;

datatype_declaration:
    var_list DOS_PUNTOS TIPO_DATO {RULE("datatype_declaration -> var_list DOS_PUNTOS TIPO_DATO");}
    ;

var_list:
    ID {RULE("var_list -> ID");}
    | var_list COMA ID {RULE("var_list -> var_list COMA ID");}
    ;

group_of_sentences:
    sentence {RULE("group_of_sentences -> sentence");}
    | group_of_sentences sentence {RULE("group_of_sentences -> group_of_sentences sentence");}
    ;

sentence:
    assignment {RULE("sentence -> assignment");}
    | loop {RULE("sentence -> loop");}
    | selection {RULE("sentence -> selection");}
    | arithmetic_assig {RULE("sentence -> arithmetic_assig");}
    | input {RULE("sentence -> input");}
    | output {RULE("sentence -> output");}
    | sliceAndConcat {RULE("sentence -> sliceAndConcat");}
    | reorder {RULE("sentence -> reorder");}
    ;

assignment:
    ID OP_ASIG cte {RULE("assignment ->  ID OP_ASIG cte");}
    ;

cte:
    CTE_INT {RULE("cte -> CTE_INT");}
    | CTE_FLOAT {RULE("cte -> CTE_FLOAT");} 
    | CTE_STRING {RULE("cte -> CTE_STRING");}
    ;

selection:
    IF PA condition PC CBO group_of_sentences CBC {RULE("selection -> IF PA condition PC CBO group_of_sentences CBC");}
    | IF PA condition PC CBO group_of_sentences CBC ELSE CBO group_of_sentences CBC {RULE("selection -> IF PA condition PC CBO group_of_sentences CBC ELSE CBO group_of_sentences CBC");}
    ;

loop:
    WHILE PA condition PC CBO group_of_sentences CBC {RULE("loop -> WHILE PA condition PC CBO group_of_sentences CBC ");}
    ;

condition:
    comparison {RULE("condition -> comparison");}
    | condition AND comparison {RULE("condition -> condition AND comparison");}
    | condition OR comparison {RULE("condition -> condition OR comparison");}
    | NOT condition {RULE("condition -> NOT condition");}
    ;

comparison:
    expression comparator expression {RULE("comparison -> expression comparator expression");}
    ;

arithmetic_assig:
    ID OP_ARIT expression {RULE("arithmetic_assig -> ID OP_ARIT expression");}
    ;


comparator:
    MAYOR {RULE("comparator -> MAYOR");}
    | MAYOR_IGUAL {RULE("comparator -> MAYOR_IGUAL");}
    | MENOR_IGUAL {RULE("comparator -> MENOR_IGUAL");}
    | MENOR {RULE("comparator -> MENOR");}
    ;

expression:
    expression OP_SUM term {RULE("expression -> expression OP_SUM term");}
    | expression OP_RES term {RULE("expression -> expression OP_RES term");}
    | term {RULE("expression -> term");}
    ;

term:
    term OP_MUL factor {RULE("term -> term OP_MUL factor");}
    | term OP_DIV factor {RULE("term -> term OP_DIV factor");}
    | factor {RULE("term -> factor");}
    ;

factor:
    PA expression PC {RULE("factor -> PA expression PC");}
    | ID {RULE("factor -> ID");}
    | CTE_INT {RULE("factor -> CTE_INT");}
    | CTE_FLOAT {RULE("factor -> CTE_FLOAT");}
    ;


input:
    READ PA ID PC {RULE("input -> READ PA ID PC");}
    ;

output:
    WRITE PA cte PC {RULE("output -> WRITE PA cte PC");}
    | WRITE PA ID PC {RULE("output -> WRITE PA ID PC");}
    ;

sliceAndConcat: /*El ultimo cte/id tendria que ser un bool*/
    SLICE_AND_CONCAT PA cte_int_o_id COMA cte_int_o_id COMA cte_string_o_id COMA cte_string_o_id COMA cte_int_o_id PC {RULE("sliceAndConcat");}
    ;

reorder: /*El anteultimo cte/id tendria que ser un bool*/
    REORDER PA OPEN_BRACKET expressions_list CLOSE_BRACKET COMA cte_int_o_id COMA cte_int_o_id PC {RULE("reorder");}
    ; 

expressions_list:
    expressions_list COMA expression {RULE("expressions_list -> expressions_list COMA expression");}
    | expression {RULE("expressions_list -> expression");}
    ;

cte_int_o_id:
    CTE_INT {RULE("cte_int_o_id -> CTE_INT");}
    | ID {RULE("cte_int_o_id -> ID");}
    ;

cte_string_o_id:
    CTE_STRING {RULE("cte_string_o_id -> CTE_STRING");}
    | ID {RULE("cte_string_o_id -> ID");}
    ;

/*cte_bool_o_id:
    CTE_BOOL {RULE("cte_bool_o_id -> CTE_BOOL");}
    | ID {RULE("cte_bool_o_id -> ID");}
    ;*/

%%



int main(int argc, char *argv[])
{
    if((yyin = fopen(argv[1], "rt"))==NULL)
    {
        printf("\nNo se puede abrir el archivo de prueba: %s\n", argv[1]);
        return 1;
    }
    create_symbol_table(&symbol_table);

    int parserResult = yyparse();

	fclose(yyin);

	printf("Syntax OK \n");

    symbol_table_to_file("tabla_simbolos.txt", &symbol_table);
    return 0;
}

int yyerror(char* e)
{
    extern int yylineno;
    printf("Error Sintactico en la línea %d: %s\n", yylineno, e);
    printf("Token inesperado o contexto: '%s'\n", yytext);
    exit(1);
}
