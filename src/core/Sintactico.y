// Usa Lexico_ClasePractica
//Solo expresiones sin ()
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symbol.h"
#include "terceto.h"

extern char* yytext;

#define RULE(x) printf("Rule recognized: %s \n", x);
int yyerror(char* e);
int yystopparser=0;
tLista symbol_table;
tLista lista_tercetos;

int index_cte;
int index_assignment;
int index_factor;
int index_term;
int index_expression;
int index_arit_assig;
int index_comparison;
int index_condition;
int index_selection;

extern int yylex();
extern int yyparser();
extern FILE* yyin;
%}

%union {
    char* str_val;
    int int_val;
    float float_val;
}

%token <str_val> ID CTE_STRING OP_ASIG OP_DIV OP_MUL OP_RES OP_SUM OP_ARIT MAYOR MAYOR_IGUAL MENOR MENOR_IGUAL
%token <int_val> CTE_INT
%token <float_val> CTE_FLOAT
%left <str_val> AND OR
%right <str_val> NOT

%type <int_val> expression factor term arithmetic_assig cte comparison condition selection


%start start

%token DIGITO
%token LETRA
%token BOOL

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

%token PUNTO
%token COM
%token DOS_PUNTOS
%token COMA


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
    | /* empty */ {RULE("sentence -> empty");}
    ;

assignment:
    ID OP_ASIG cte 
    {
        tTerceto terceto;
        char str_index_cte[20];
        sprintf(str_index_cte, "%d", index_cte);
        
        agregar_terceto(terceto, &lista_tercetos, $2, $1, str_index_cte);
        RULE("assignment -> ID OP_ASIG cte");
    }
    ;

cte:
    CTE_INT
        {
            tTerceto terceto;
            char value[50];
            strcpy(value, yytext);
            index_cte = agregar_terceto(terceto, &lista_tercetos, value, NULL, NULL);
            $$ = index_cte;
            RULE("cte -> CTE_INT");
        }
    | CTE_FLOAT 
        {
            tTerceto terceto;
            char value[50];
            strcpy(value, yytext);
            index_cte = agregar_terceto(terceto, &lista_tercetos, value, NULL, NULL);
            $$ = index_cte;
            RULE("cte -> CTE_FLOAT");
        } 
    | CTE_STRING 
        {
            tTerceto terceto;
            char value[50];
            strcpy(value, yytext);
            index_cte = agregar_terceto(terceto, &lista_tercetos, value, NULL, NULL);
            $$ = index_cte;
            RULE("cte -> CTE_STRING");
        }
    ;

selection:
    IF PA condition PC CBO group_of_sentences CBC 
        {
            RULE("selection -> IF PA condition PC CBO group_of_sentences CBC");
        }
    | IF PA condition PC CBO group_of_sentences CBC ELSE CBO group_of_sentences CBC 
        {
            RULE("selection -> IF PA condition PC CBO group_of_sentences CBC ELSE CBO group_of_sentences CBC");
        }
    ;

loop:
    WHILE PA condition PC CBO group_of_sentences CBC {RULE("loop -> WHILE PA condition PC CBO group_of_sentences CBC ");}
    ;

condition:
    comparison 
        {
            index_condition = index_comparison;
            $$ = index_condition;
            RULE("condition -> comparison");
        }
    | condition AND comparison 
        {
            tTerceto terceto;

            char izq[20];
            sprintf(izq, "%d", index_condition);

            char der[20];
            sprintf(der, "%d", index_comparison);

            index_condition = agregar_terceto(terceto, &lista_tercetos, $2, izq, der);
            $$ = index_condition;
            RULE("condition -> condition AND comparison");
        }
    | condition OR comparison 
        {
            tTerceto terceto;

            char izq[20];
            sprintf(izq, "%d", index_condition);

            char der[20];
            sprintf(der, "%d", index_comparison);
        
            index_condition = agregar_terceto(terceto, &lista_tercetos, $2, izq, der);
            $$ = index_condition;
            RULE("condition -> condition OR comparison");
        }
    | NOT condition 
        {
            tTerceto terceto;

            char expr[20];
            sprintf(expr, "%d", index_condition);

            index_condition = agregar_terceto(terceto, &lista_tercetos, $1, expr, NULL);
            $$ = index_condition;
            RULE("condition -> NOT condition");
        }
    ;

comparison:
    expression MAYOR expression 
        {
            tTerceto terceto;

            char str_left[20];
            sprintf(str_left, "%d", $1);  // resultado de la izquierda

            char str_right[20];
            sprintf(str_right, "%d", $3);       // resultado de la derecha

            index_comparison = agregar_terceto(terceto, &lista_tercetos, $2, str_left, str_right);
            $$ = index_comparison;
            RULE("comparison -> expression MAYOR expression");
        }
    | expression MAYOR_IGUAL expression 
        {
            tTerceto terceto;

            char str_left[20];
            sprintf(str_left, "%d", $1);  // resultado de la izquierda

            char str_right[20];
            sprintf(str_right, "%d", $3);       // resultado de la derecha

            index_comparison = agregar_terceto(terceto, &lista_tercetos, $2, str_left, str_right);
            $$ = index_comparison;
            RULE("comparison -> expression MAYOR_IGUAL expression");
        }
    | expression MENOR_IGUAL expression 
        {
            tTerceto terceto;

            char str_left[20];
            sprintf(str_left, "%d", $1);  // resultado de la izquierda

            char str_right[20];
            sprintf(str_right, "%d", $3);       // resultado de la derecha

            index_comparison = agregar_terceto(terceto, &lista_tercetos, $2, str_left, str_right);
            $$ = index_comparison;
            RULE("comparison -> expression MENOR_IGUAL expression");
        }
    | expression MENOR expression 
        {
            tTerceto terceto;

            char str_left[20];
            sprintf(str_left, "%d", $1);  // resultado de la izquierda

            char str_right[20];
            sprintf(str_right, "%d", $3);       // resultado de la derecha

            index_comparison = agregar_terceto(terceto, &lista_tercetos, $2, str_left, str_right);
            $$ = index_comparison;
            RULE("comparison -> expression MENOR expression");
        }
    ;

arithmetic_assig:
    ID OP_ARIT expression 
    {
        tTerceto terceto;
        char str_index_expression[20];
        sprintf(str_index_expression, "%d", index_expression);
        
        index_arit_assig = agregar_terceto(terceto, &lista_tercetos, $2, $1, str_index_expression);
        $$ = index_arit_assig;

        RULE("arithmetic_assig -> ID OP_ARIT expression");
    }
    ;

expression:
    expression OP_SUM term 
        {
            tTerceto terceto;

            char str_index_expression[20];
            sprintf(str_index_expression, "%d", index_expression);

            char str_index_term[20];
            sprintf(str_index_term, "%d", index_term);

            index_expression = agregar_terceto(terceto, &lista_tercetos, $2,str_index_expression, str_index_term);
            $$ = index_expression;
            RULE("expression -> expression OP_SUM term");
        }
    | expression OP_RES term 
        {
            tTerceto terceto;

            char str_index_expression[20];
            sprintf(str_index_expression, "%d", index_expression);

            char str_index_term[20];
            sprintf(str_index_term, "%d", index_term);

            index_expression = agregar_terceto(terceto, &lista_tercetos, $2,str_index_expression, str_index_term);
            $$ = index_expression;
            RULE("expression -> expression OP_RES term");
        }
    | term 
        {
            index_expression = index_term;
            $$ = index_expression;
            RULE("expression -> term");
        }
    ;

term:
    term OP_MUL factor 
        {
            tTerceto terceto;

            char str_index_term[20];
            sprintf(str_index_term, "%d", index_term);

            char str_index_factor[20];
            sprintf(str_index_factor, "%d", index_factor);

            index_term = agregar_terceto(terceto, &lista_tercetos, $2,str_index_term, str_index_factor);
            $$ = index_term;
            RULE("term -> term OP_MUL factor");
        }
    | term OP_DIV factor 
        {
            tTerceto terceto;

            char str_index_term[20];
            sprintf(str_index_term, "%d", index_term);

            char str_index_factor[20];
            sprintf(str_index_factor, "%d", index_factor);

            index_term = agregar_terceto(terceto, &lista_tercetos, $2,str_index_term, str_index_factor);
            $$ = index_term;
            RULE("term -> term OP_DIV factor");
        }
    | factor 
        {
            index_term = index_factor;
            $$ = index_term;
            RULE("term -> factor");
        }
    ;

factor:
    PA expression PC 
        {
            index_factor = index_expression;
            $$ = index_factor;
            RULE("factor -> PA expression PC");
        }
    | ID 
        {
            tTerceto terceto;
            char value[50];
            strcpy(value, yytext);
            index_factor = agregar_terceto(terceto, &lista_tercetos, value, NULL, NULL);
            $$ = index_factor;
            RULE("factor -> ID");
        }
    | CTE_INT 
        {
            tTerceto terceto;
            char value[50];
            strcpy(value, yytext);
            index_factor = agregar_terceto(terceto, &lista_tercetos, value, NULL, NULL);
            $$ = index_factor;
            RULE("factor -> CTE_INT");
        }
    | CTE_FLOAT 
        {
            tTerceto terceto;
            char value[50];
            strcpy(value, yytext);
            index_factor = agregar_terceto(terceto, &lista_tercetos, value, NULL, NULL);
            $$ = index_factor;
            RULE("factor -> CTE_FLOAT");
        }
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
    init_tercetos(&lista_tercetos);

    int parserResult = yyparse();

	fclose(yyin);

	printf("Syntax OK \n");

    symbol_table_to_file("tabla_simbolos.txt", &symbol_table);
    terceto_to_file("tercetos.txt", &lista_tercetos);
    return 0;
}

int yyerror(char* e)
{
    extern int yylineno;
    printf("Error Sintactico en la línea %d: %s\n", yylineno, e);
    printf("Token inesperado o contexto: '%s'\n", yytext);
    exit(1);
}
