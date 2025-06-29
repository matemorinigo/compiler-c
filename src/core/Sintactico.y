// Usa Lexico_ClasePractica
//Solo expresiones sin ()
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "list.h"
#include "symbol.h"
#include "terceto.h"
#include "reorder.h"
#include "slice_and_concat.h"
#include "variable_checks.h"
#include "assembler.h"

extern char* yytext;

#define RULE(x) printf("Rule recognized: %s \n", x);

int yyerror(char* e);
int semantic_error(char* e);
int sintactic_error(char* e);
int yystopparser=0;
tLista symbol_table;
tLista lista_tercetos;
tLista lista_aux_reorder;
tLista aux_declarations;
tLista aux_conditions;
tLista aux_else;

int index_cte;
int index_assignment;
int index_factor;
int index_term;
int index_expression;
int index_arit_assig;
int index_comparison;
int index_condition;
int aux_index_condition;
int index_selection;
int contador_expresiones_reorder;

char ult_cte_detectada[50];
char aux_term[50];

extern int yylex();
extern int yyparser();
extern FILE* yyin;

%}

%union {
    char* str_val;
    int int_val;
    float float_val;
}

%token <str_val> ID CTE_STRING OP_ASIG OP_DIV OP_MUL OP_RES OP_SUM OP_ARIT MAYOR MAYOR_IGUAL MENOR MENOR_IGUAL OP_ASIG_COMUN TIPO_DATO
%token <int_val> CTE_INT
%token <float_val> CTE_FLOAT
%left <str_val> AND OR
%right <str_val> NOT

%type <int_val> expression factor term arithmetic_assig cte condition selection loop expressions_list

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

%token PUNTO
%token COM
%token DOS_PUNTOS
%token COMA


%token CTE_BOOL


%%

start:
    program {generarAssembler(&symbol_table, &lista_tercetos);}

program:
    declarations group_of_sentences {RULE("program -> declarations group_of_sentences");}
    ;

declarations: 
    INIT CBO multiple_datatype_declaration CBC 
        {
            vaciarLista(&aux_declarations);
            RULE("declarations -> INIT CBO multiple_datatype_declaration CBC");
        }
    ;

multiple_datatype_declaration:
    datatype_declaration {RULE("multiple_datatype_declaration -> datatype_declaration");}
    | multiple_datatype_declaration datatype_declaration {RULE("multiple_datatype_declaration -> multiple_datatype_declaration datatype_declaration");}
    ;

datatype_declaration:
    var_list DOS_PUNTOS TIPO_DATO 
        {
            char aux[50];
            while(sacarPrimero(&aux_declarations, aux, sizeof(aux)))
            {
                if (crear_variable(aux, $3, &symbol_table) == -1)
                {
                    sintactic_error("Error: variable ya declarada");
                }
            }
            RULE("datatype_declaration -> var_list DOS_PUNTOS TIPO_DATO");
        }
    ;

var_list:
    ID
        {
            crearLista(&aux_declarations);
            ponerAlFinal(&aux_declarations, $1, strlen($1) + 1);
            RULE("var_list -> ID");
        }
    | var_list COMA ID 
        {
            ponerAlFinal(&aux_declarations, $3, strlen($3) + 1);
            RULE("var_list -> var_list COMA ID");
        }
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
    ID OP_ASIG cte 
    {
        tTerceto terceto;

        if(check_var_exists($1, &symbol_table) == 0){
            sintactic_error("ERROR: Variable usada pero no declarada");
        }
        char aux_datatype[50];
        sprintf(aux_datatype, "%s", ult_cte_detectada);

        if(compare_datatypes($1, aux_datatype, &symbol_table) == DIFFERENT_DATATYPE){
            printf("id: %s\n", $1);
            printf("cte: %s\n", aux_datatype);
            semantic_error("ERROR: No se puede asignar una constante a una variable de diferente tipo");
        }


        agregar_terceto(terceto, &lista_tercetos, ":=", $1, ult_cte_detectada);


        RULE("assignment -> ID OP_ASIG cte");
    }
    ;

cte:
    CTE_INT
        {
            tTerceto terceto;
            char value[70];
            sprintf(value,"I_%s", yytext);

            sprintf(ult_cte_detectada,"I_%s", yytext);
            RULE("cte -> CTE_INT");
        }
    | CTE_FLOAT 
        {
            tTerceto terceto;
            char value[70];
            char valor_limpio[70];
            strcpy(valor_limpio,yytext);
            sanitize_string(valor_limpio);
            sprintf(value,"F_%s", valor_limpio);

            sprintf(ult_cte_detectada,"F_%s", valor_limpio);
            RULE("cte -> CTE_FLOAT");
        } 
    | CTE_STRING 
        {
            tTerceto terceto;
            char value[70];
            sprintf(value,"%s", $1);

            strcpy(ult_cte_detectada, $1);
            RULE("cte -> CTE_STRING");
        }
    ;

selection:
    IF PA condition PC CBO group_of_sentences CBC
        {
            tTerceto terceto;
            char str_index_condition[20];
            char str_index_false[20];
            sprintf(str_index_false, "[%d]", obtener_indice_actual() + 1);


            int ind_aux;

            switch ($3){
                case 1:
                    sacarPrimero(&aux_conditions, &ind_aux, sizeof(ind_aux));

                    sprintf(str_index_condition, "[%d]", ind_aux);
                    actualizar_op2(&lista_tercetos, ind_aux, str_index_false);
                    break;

                case 2:
                    sacarPrimero(&aux_conditions, &ind_aux, sizeof(ind_aux));
                    sprintf(str_index_condition, "[%d]", ind_aux);
                    actualizar_op2(&lista_tercetos, ind_aux, str_index_false);

                    sacarPrimero(&aux_conditions, &ind_aux, sizeof(ind_aux));
                    sprintf(str_index_condition, "[%d]", ind_aux);
                    actualizar_op2(&lista_tercetos, ind_aux, str_index_false);
                    break;

                case 3:
                    sacarPrimero(&aux_conditions, &ind_aux, sizeof(ind_aux));
                    sprintf(str_index_condition, "[%d]", ind_aux);
                    actualizar_op2(&lista_tercetos, ind_aux, str_index_false);
                    break;

                case 4:
                    sacarPrimero(&aux_conditions, &ind_aux, sizeof(ind_aux));
                    sprintf(str_index_condition, "[%d]", ind_aux);
                    actualizar_op2(&lista_tercetos, ind_aux, str_index_false);
                    break;
            }
            RULE("selection -> IF PA condition PC CBO group_of_sentences CBC");
        }
    | IF PA condition PC CBO group_of_sentences CBC ELSE 
        {
            tTerceto terceto;
            char str_index_condition[20];
            char str_index_false[20];
            sprintf(str_index_false, "[%d]", obtener_indice_actual() + 2);
            int ind_aux;

            switch ($3){
                case 1:
                    sacarPrimero(&aux_conditions, &ind_aux, sizeof(ind_aux));

                    sprintf(str_index_condition, "[%d]", ind_aux);
                    actualizar_op2(&lista_tercetos, ind_aux, str_index_false);
                    break;

                case 2:
                    sacarPrimero(&aux_conditions, &ind_aux, sizeof(ind_aux));
                    sprintf(str_index_condition, "[%d]", ind_aux);
                    actualizar_op2(&lista_tercetos, ind_aux, str_index_false);

                    sacarPrimero(&aux_conditions, &ind_aux, sizeof(ind_aux));
                    sprintf(str_index_condition, "[%d]", ind_aux);
                    actualizar_op2(&lista_tercetos, ind_aux, str_index_false);
                    break;

                case 3:
                    sacarPrimero(&aux_conditions, &ind_aux, sizeof(ind_aux));
                    sprintf(str_index_condition, "[%d]", ind_aux);
                    actualizar_op2(&lista_tercetos, ind_aux, str_index_false);
                    break;

                case 4:
                    sacarPrimero(&aux_conditions, &ind_aux, sizeof(ind_aux));
                    sprintf(str_index_condition, "[%d]", ind_aux);
                    actualizar_op2(&lista_tercetos, ind_aux, str_index_false);
                    break;
            }

            int aux_index_bi = agregar_terceto(terceto, &lista_tercetos, "BI", NULL, NULL);
            ponerAlInicio(&aux_else, &aux_index_bi, sizeof(aux_index_bi));
        }
        CBO group_of_sentences CBC
        {
            int aux_index_bi;
            char str_index_false[20];
            sprintf(str_index_false, "[%d]", obtener_indice_actual() + 1);

            sacarPrimero(&aux_else, &aux_index_bi, sizeof(aux_index_bi));
            actualizar_terceto(&lista_tercetos, aux_index_bi, "BI", NULL, str_index_false);

            RULE("selection -> IF PA condition PC CBO group_of_sentences CBC ELSE CBO group_of_sentences CBC");
            
        }

loop:
    WHILE PA condition PC CBO group_of_sentences CBC 
        {
            tTerceto terceto;
            char str_index_condition[20];
            char str_index_false[20];
            sprintf(str_index_false, "[%d]", obtener_indice_actual() + 2);
            char str_index_loopback[20];
        

            int ind_aux;

            switch ($3){
                case 1:
                    sacarPrimero(&aux_conditions, &ind_aux, sizeof(ind_aux));

                    sprintf(str_index_condition, "[%d]", ind_aux);
                    actualizar_op2(&lista_tercetos, ind_aux, str_index_false);

                    sprintf(str_index_loopback, "[%d]", ind_aux - 1);

                    break;

                case 2:
                    sacarPrimero(&aux_conditions, &ind_aux, sizeof(ind_aux));
                    sprintf(str_index_condition, "[%d]", ind_aux);
                    actualizar_op2(&lista_tercetos, ind_aux, str_index_false);

                    sacarPrimero(&aux_conditions, &ind_aux, sizeof(ind_aux));
                    sprintf(str_index_condition, "[%d]", ind_aux);
                    actualizar_op2(&lista_tercetos, ind_aux, str_index_false);

                    sprintf(str_index_loopback, "[%d]", ind_aux - 1);

                    break;

                case 3:
                    sacarPrimero(&aux_conditions, &ind_aux, sizeof(ind_aux));
                    sprintf(str_index_condition, "[%d]", ind_aux);
                    actualizar_op2(&lista_tercetos, ind_aux, str_index_false);

                    sprintf(str_index_loopback, "[%d]", ind_aux - 3);

                    break;

                case 4:
                    sacarPrimero(&aux_conditions, &ind_aux, sizeof(ind_aux));
                    sprintf(str_index_condition, "[%d]", ind_aux);
                    actualizar_op2(&lista_tercetos, ind_aux, str_index_false);

                    sprintf(str_index_loopback, "[%d]", ind_aux - 1);

                    break;
            }

            $$ = agregar_terceto(terceto,&lista_tercetos,"BI", NULL,str_index_loopback); 
            RULE("loop -> WHILE PA condition PC CBO group_of_sentences CBC ");
        }
    ;

condition:
    ID MAYOR ID
        {
            tTerceto terceto;
            char aux_index_condition[50];

            if(!check_var_exists($1, &symbol_table))
                sintactic_error("Error: variable usada pero no decalarada");
            if(!check_var_exists($3, &symbol_table))
                sintactic_error("Error: variable usada pero no decalarada");
            if(!check_var_is_numeric($1, &symbol_table))
                sintactic_error("Error: Solo se pueden comparar variables numericas");
            if(!check_var_is_numeric($3, &symbol_table))
                sintactic_error("Error: Solo se pueden variables numericas");

            if(compare_datatypes($1, $3, &symbol_table) == DIFFERENT_DATATYPE){
                semantic_error("Error: No se pueden comparar variables de diferente tipo");
            }

            char str_left[50];
            sprintf(str_left, "%s", $1);  // resultado de la izquierda

            char str_right[50];
            sprintf(str_right, "%s", $3);       // resultado de la derecha

            index_condition = agregar_terceto(terceto, &lista_tercetos, "CMP", str_left, str_right);
            sprintf(aux_index_condition, "[%d]", index_condition);

            index_condition = agregar_terceto(terceto, &lista_tercetos, "BLE", aux_index_condition, "");
            ponerAlInicio(&aux_conditions, &index_condition, sizeof(index_condition));

            $$ = 1;

            RULE("condition -> ID MAYOR ID");
        }
    | ID MAYOR ID AND ID MAYOR ID
        {
            tTerceto terceto;
            char aux_index_condition[50];

            if(!check_var_exists($1, &symbol_table))
                sintactic_error("Error: variable usada pero no decalarada");
            if(!check_var_exists($3, &symbol_table))
                sintactic_error("Error: variable usada pero no decalarada");
            if(!check_var_exists($5, &symbol_table))
                sintactic_error("Error: variable usada pero no decalarada");
            if(!check_var_exists($7, &symbol_table))
                sintactic_error("Error: variable usada pero no decalarada");

            if(!check_var_is_numeric($1, &symbol_table))
                sintactic_error("Error: Solo se pueden variables numericas");
            if(!check_var_is_numeric($3, &symbol_table))
                sintactic_error("Error: Solo se pueden variables numericas");
            if(!check_var_is_numeric($5, &symbol_table))
                sintactic_error("Error: Solo se pueden variables numericas");
            if(!check_var_is_numeric($7, &symbol_table))
                sintactic_error("Error: Solo se pueden variables numericas");

            if(compare_datatypes($1, $3, &symbol_table) == DIFFERENT_DATATYPE){
                semantic_error("Error: No se pueden comparar variables de diferente tipo");
            }

            if(compare_datatypes($5, $7, &symbol_table) == DIFFERENT_DATATYPE){
                semantic_error("Error: No se pueden comparar variables de diferente tipo");
            }

            char first_id[50];
            sprintf(first_id, "%s", $1);

            char second_id[50];
            sprintf(second_id, "%s", $3);

            char third_id[50];
            sprintf(third_id, "%s", $5);

            char fourth_id[50];
            sprintf(fourth_id, "%s", $7);

            index_condition = agregar_terceto(terceto, &lista_tercetos, "CMP", first_id, second_id);
            sprintf(aux_index_condition, "[%d]", index_condition);

            index_condition = agregar_terceto(terceto, &lista_tercetos, "BLE", aux_index_condition, "");
            ponerAlInicio(&aux_conditions, &index_condition, sizeof(index_condition));

            index_condition = agregar_terceto(terceto, &lista_tercetos, "CMP", third_id, fourth_id);
            sprintf(aux_index_condition, "[%d]", index_condition);

            index_condition = agregar_terceto(terceto, &lista_tercetos, "BLE", aux_index_condition, "");
            ponerAlInicio(&aux_conditions, &index_condition, sizeof(index_condition));

            $$ = 2;
        }
    | ID MAYOR ID OR ID MAYOR ID
        {
            tTerceto terceto;
            char aux_index_condition[50];
            char aux_index_salto[50];

            if(!check_var_exists($1, &symbol_table))
                sintactic_error("Error: variable usada pero no decalarada");
            if(!check_var_exists($3, &symbol_table))
                sintactic_error("Error: variable usada pero no decalarada");
            if(!check_var_exists($5, &symbol_table))
                sintactic_error("Error: variable usada pero no decalarada");
            if(!check_var_exists($7, &symbol_table))
                sintactic_error("Error: variable usada pero no decalarada");

            if(!check_var_is_numeric($1, &symbol_table))
                sintactic_error("Error: Solo se pueden variables numericas");
            if(!check_var_is_numeric($3, &symbol_table))
                sintactic_error("Error: Solo se pueden variables numericas");
            if(!check_var_is_numeric($5, &symbol_table))
                sintactic_error("Error: Solo se pueden variables numericas");
            if(!check_var_is_numeric($7, &symbol_table))
                sintactic_error("Error: Solo se pueden variables numericas");

            if(compare_datatypes($1, $3, &symbol_table) == DIFFERENT_DATATYPE){
                semantic_error("Error: No se pueden comparar variables de diferente tipo");
            }

            if(compare_datatypes($5, $7, &symbol_table) == DIFFERENT_DATATYPE){
                semantic_error("Error: No se pueden comparar variables de diferente tipo");
            }

            char first_id[50];
            sprintf(first_id, "%s", $1);

            char second_id[50];
            sprintf(second_id, "%s", $3);

            char third_id[50];
            sprintf(third_id, "%s", $5);

            char fourth_id[50];
            sprintf(fourth_id, "%s", $7);

            index_condition = agregar_terceto(terceto, &lista_tercetos, "CMP", first_id, second_id);
            sprintf(aux_index_condition, "[%d]", index_condition);
            sprintf(aux_index_salto, "[%d]", index_condition+4);

            index_condition = agregar_terceto(terceto, &lista_tercetos, "BGT", aux_index_condition, aux_index_salto);

            index_condition = agregar_terceto(terceto, &lista_tercetos, "CMP", third_id, fourth_id);
            sprintf(aux_index_condition, "[%d]", index_condition);

            index_condition = agregar_terceto(terceto, &lista_tercetos, "BLE", aux_index_condition, "");
            ponerAlInicio(&aux_conditions, &index_condition, sizeof(index_condition));


            $$ = 3;
        }
    | NOT ID MAYOR ID
        {
            tTerceto terceto;
            char aux_index_condition[50];

            if(!check_var_exists($2, &symbol_table))
                sintactic_error("Error: variable usada pero no decalarada");
            if(!check_var_exists($4, &symbol_table))
                sintactic_error("Error: variable usada pero no decalarada");

            if(!check_var_is_numeric($2, &symbol_table))
                sintactic_error("Error: Solo se pueden variables numericas");
            if(!check_var_is_numeric($4, &symbol_table))
                sintactic_error("Error: Solo se pueden variables numericas");

            if(compare_datatypes($2, $4, &symbol_table) == DIFFERENT_DATATYPE){
                semantic_error("Error: No se pueden comparar variables de diferente tipo");
            }

            char str_left[50];
            sprintf(str_left, "%s", $2);  // resultado de la izquierda

            char str_right[50];
            sprintf(str_right, "%s", $4);       // resultado de la derecha

            index_condition = agregar_terceto(terceto, &lista_tercetos, "CMP", str_left, str_right);
            sprintf(aux_index_condition, "[%d]", index_condition);

            index_condition = agregar_terceto(terceto, &lista_tercetos, "BGT", aux_index_condition, "");
            ponerAlInicio(&aux_conditions, &index_condition, sizeof(index_condition));

            $$ = 4;

            RULE("condition -> ID MAYOR ID");
        }

arithmetic_assig:
    ID OP_ARIT expression 
    {
        if(check_var_exists($1, &symbol_table) == 0){
            sintactic_error("ERROR: Variable usada pero no declarada");
        }

        char var_aux_base[50] = "aux_var_";
        char nombre_expr_aux[50];
        sprintf(nombre_expr_aux,"%s%d", var_aux_base, index_expression);

        if(compare_datatypes($1, nombre_expr_aux, &symbol_table) == DIFFERENT_DATATYPE){
                printf("%s\n", $1);
                printf("%s\n", nombre_expr_aux);
                semantic_error("Error: No se puede operar entre variables de diferente tipo");
        }

        tTerceto terceto;
        char str_index_expression[20];
        sprintf(str_index_expression, "[%d]", index_expression);
        
        index_arit_assig = agregar_terceto(terceto, &lista_tercetos, "=:", $1, str_index_expression);
        $$ = index_arit_assig;

        RULE("arithmetic_assig -> ID OP_ARIT expression");
    }
    ;

expression:
    expression OP_SUM term
        {
            symbol sym;
            tTerceto terceto;
            char var_aux_base[50] = "aux_var_";
            char nombre_expr_aux[50];
            char nombre_term_aux[50];

            char str_index_expression[20];
            sprintf(str_index_expression, "[%d]", index_expression);
            sprintf(nombre_expr_aux,"%s%d", var_aux_base, index_expression);

            char str_index_term[20];
            sprintf(str_index_term, "[%d]", index_term);
            sprintf(nombre_term_aux,"%s%d", var_aux_base, index_term);

            if(compare_datatypes(nombre_expr_aux, nombre_term_aux, &symbol_table) == DIFFERENT_DATATYPE){
                printf("%s\n", nombre_expr_aux);
                printf("%s\n", nombre_term_aux);
                semantic_error("Error: No se puede operar entre variables de diferente tipo");
            }

            index_expression = agregar_terceto(terceto, &lista_tercetos, "SUM",str_index_expression, str_index_term);

            snprintf(sym.name, sizeof(sym.name), "aux_var_%d", index_expression);

            if(check_var_is_int(nombre_expr_aux, &symbol_table)){
                strcpy(sym.data_type, "int");
            }
            else if(check_var_is_float(nombre_expr_aux, &symbol_table)){
                strcpy(sym.data_type, "float");
            }

            strcpy(sym.value, "");
            sym.length = 0;
            insert_symbol(sym, &symbol_table);

            $$ = index_expression;
            RULE("expression -> expression OP_SUM term");
        }
    | expression OP_RES term
        {
            symbol sym;
            tTerceto terceto;
            char var_aux_base[50] = "aux_var_";
            char nombre_expr_aux[50];
            char nombre_term_aux[50];
            

            char str_index_expression[20];
            sprintf(str_index_expression, "[%d]", index_expression);
            sprintf(nombre_expr_aux,"%s%d", var_aux_base, index_expression);

            char str_index_term[20];
            sprintf(str_index_term, "[%d]", index_term);
            sprintf(nombre_term_aux,"%s%d", var_aux_base, index_term);

            index_expression = agregar_terceto(terceto, &lista_tercetos, "RES",str_index_expression, str_index_term);

            snprintf(sym.name, sizeof(sym.name), "aux_var_%d", index_expression);

            if(check_var_is_int(nombre_expr_aux, &symbol_table)){
                strcpy(sym.data_type, "int");
            }
            else if(check_var_is_float(nombre_expr_aux, &symbol_table)){
                strcpy(sym.data_type, "float");
            }
            
            strcpy(sym.value, "");
            sym.length = 0;
            insert_symbol(sym, &symbol_table);

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
            symbol sym;
            tTerceto terceto;
            char var_aux_base[50] = "aux_var_";
            char nombre_term_aux[50];
            char nombre_factor_aux[50];


            char str_index_term[20];
            sprintf(str_index_term, "[%d]", index_term);
            sprintf(nombre_term_aux,"%s%d", var_aux_base, index_term);


            char str_index_factor[20];
            sprintf(str_index_factor, "[%d]", index_factor);
            sprintf(nombre_factor_aux,"%s%d", var_aux_base, index_factor);

            if(compare_datatypes(nombre_factor_aux, nombre_term_aux, &symbol_table) == DIFFERENT_DATATYPE){
                printf("%s\n", nombre_factor_aux);
                printf("%s\n", nombre_term_aux);
                semantic_error("Error: No se puede operar entre variables de diferente tipo");
            }

            index_term = agregar_terceto(terceto, &lista_tercetos, "MUL",str_index_term, str_index_factor);

            snprintf(sym.name, sizeof(sym.name), "%s%d", var_aux_base, index_term);

            if(check_var_is_int(nombre_factor_aux, &symbol_table)){
                strcpy(sym.data_type, "int");
            }
            else if(check_var_is_float(nombre_factor_aux, &symbol_table)){
                strcpy(sym.data_type, "float");
            }

            strcpy(sym.value, "");
            sym.length = 0;
            insert_symbol(sym, &symbol_table);

            $$ = index_term;
            RULE("term -> term OP_MUL factor");
        }
    | term OP_DIV factor     
        {
            symbol sym;
            tTerceto terceto;
            char var_aux_base[50] = "aux_var_";
            char nombre_term_aux[50];
            char nombre_factor_aux[50];


            char str_index_term[20];
            sprintf(str_index_term, "[%d]", index_term);
            sprintf(nombre_term_aux,"%s%d", var_aux_base, index_term);


            char str_index_factor[20];
            sprintf(str_index_factor, "[%d]", index_factor);
            sprintf(nombre_factor_aux,"%s%d", var_aux_base, index_factor);

            if(compare_datatypes(nombre_factor_aux, nombre_term_aux, &symbol_table) == DIFFERENT_DATATYPE){
                semantic_error("Error: No se puede operar entre variables de diferente tipo");
            }

            index_term = agregar_terceto(terceto, &lista_tercetos, "DIV",str_index_term, str_index_factor);

            snprintf(sym.name, sizeof(sym.name), "%s%d", var_aux_base, index_term);

            if(check_var_is_int(nombre_factor_aux, &symbol_table)){
                strcpy(sym.data_type, "int");
            }
            else if(check_var_is_float(nombre_factor_aux, &symbol_table)){
                strcpy(sym.data_type, "float");
            }

            strcpy(sym.value, "");
            sym.length = 0;
            insert_symbol(sym, &symbol_table);

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
    ID 
        {
            symbol sym;
            if(check_var_exists($1, &symbol_table) == 0){
                sintactic_error("ERROR: Variable usada pero no declarada");
            }

            if(check_var_is_string($1, &symbol_table)){
                sintactic_error("ERROR: No se puede hacer operaciones aritmeticas con strings");
            }

            tTerceto terceto;
            char value[70];
            sprintf(value,"%s", yytext);
            index_factor = agregar_terceto(terceto, &lista_tercetos, value, NULL, NULL);

            snprintf(sym.name, sizeof(sym.name), "aux_var_%d", index_factor);

            if(check_var_is_int($1, &symbol_table)){
                strcpy(sym.data_type, "int");
            }
            if(check_var_is_float($1, &symbol_table)){
                strcpy(sym.data_type, "float");
            }

            strcpy(sym.value, "");
            sym.length = 0;
            insert_symbol(sym, &symbol_table);


            $$ = index_factor;
            RULE("factor -> ID");
        }
    | CTE_INT 
        {
            tTerceto terceto;
            symbol sym;

            char value[70];
            sprintf(value,"I_%s", yytext);
            index_factor = agregar_terceto(terceto, &lista_tercetos, value, NULL, NULL);

            snprintf(sym.name, sizeof(sym.name), "aux_var_%d", index_factor);
            strcpy(sym.data_type, "int");
            strcpy(sym.value, "");
            sym.length = 0;
            insert_symbol(sym, &symbol_table);

            $$ = index_factor;
            RULE("factor -> CTE_INT");
        }
    | CTE_FLOAT 
        {
            tTerceto terceto;
            symbol sym;
            char value[70];
            char valor_limpio[70];

            strcpy(valor_limpio,yytext);
            sanitize_string(valor_limpio);

            sprintf(value,"F_%s", valor_limpio);
            index_factor = agregar_terceto(terceto, &lista_tercetos, value, NULL, NULL);

            snprintf(sym.name, sizeof(sym.name), "aux_var_%d", index_factor);
            strcpy(sym.data_type, "float");
            strcpy(sym.value, "");
            sym.length = 0;
            insert_symbol(sym, &symbol_table);
            
            $$ = index_factor;
            RULE("factor -> CTE_FLOAT");
        }
    ;


input:
    READ PA ID PC 
        {
            if(check_var_exists($3, &symbol_table) == 0){
                sintactic_error("ERROR: Variable usada pero no declarada");
            }

            tTerceto terceto;
            char var_destino[50];
            strcpy(var_destino, $3);

            if(check_var_is_string($3, &symbol_table) == IS_STRING){
                agregar_terceto(terceto, &lista_tercetos, "READ_STRING", var_destino, NULL);
            }
            else if(check_var_is_int($3, &symbol_table) == IS_INT){
                agregar_terceto(terceto, &lista_tercetos, "READ_INT", var_destino, NULL);
            }
            else if(check_var_is_float($3, &symbol_table) == IS_FLOAT){
                agregar_terceto(terceto, &lista_tercetos, "READ_FLOAT", var_destino, NULL);
            }
            

            RULE("input -> READ PA ID PC");
        }
    ;

output:
    WRITE PA CTE_STRING PC
        {
            tTerceto terceto;
            char cte_to_print[50];
            strcpy(cte_to_print, $3);

            agregar_terceto(terceto, &lista_tercetos, "PRINT_STR", cte_to_print, NULL);

            RULE("output -> WRITE PA cte PC");
        }
    | WRITE PA ID PC
        {
            if(check_var_exists($3, &symbol_table) == 0){
                sintactic_error("ERROR: Variable usada pero no declarada");
            }

            tTerceto terceto;
            char id_to_print[50];
            strcpy(id_to_print, $3);

            if(check_var_is_int($3, &symbol_table) == IS_INT){
                agregar_terceto(terceto, &lista_tercetos, "PRINT_INT", id_to_print, NULL);
            }
            else if(check_var_is_float($3, &symbol_table) == IS_FLOAT){
                agregar_terceto(terceto, &lista_tercetos, "PRINT_FLOAT", id_to_print, NULL);
            }
            else if(check_var_is_string($3, &symbol_table) == IS_STRING){
                agregar_terceto(terceto, &lista_tercetos, "PRINT_STR", id_to_print, NULL);
            }
            
            RULE("output -> WRITE PA ID PC");
        }
    ;

sliceAndConcat: /*El ultimo cte/id tendria que ser un bool*/
    ID OP_ASIG_COMUN SLICE_AND_CONCAT PA CTE_INT COMA CTE_INT COMA CTE_STRING COMA CTE_STRING COMA CTE_INT PC 
        {
            if(check_var_exists($1, &symbol_table) == 0){
                sintactic_error("ERROR: Variable usada pero no declarada");
            }

            if(check_var_is_string($1, &symbol_table) == IS_NOT_STRING){
                sintactic_error("ERROR: La funcion sliceAndConcat devuelve un string");
            }

            // Variables Auxiliares
            int idx_aux;
            char str_idx_aux[50];

            // Asignacion de variables
            tTerceto terceto;
            char id_destino[50];
            strcpy(id_destino, $1);
            int limite_inicial = $5;
            int limite_final = $7;
            char palabra1[50];
            char palabra2[50];
            char str_final[50];
            get_value_by_name($9, palabra1, &symbol_table);
            get_value_by_name($11, palabra2, &symbol_table);

            eliminar_caracter(palabra1, '"');
            eliminar_caracter(palabra2, '"');

            int concatenarEnPalabra1 = $13; //Booleano, si True, cortamos palabra 2 y concatenamos a 1
                                            //Si False, cortamos palabra 1 y concatenamos a 2

            //Validar
            if(validar_concatenarEnPalabra1(concatenarEnPalabra1) == SLICE_AND_CONCAT_ERROR)
            {
                sintactic_error("valor de concatenarEnPalabra1 inválido, debe ser 0 o 1");
            }
            
            // Generar str_final
            if (concatenarEnPalabra1 == 1)
            {
                //Validamos limites
                if (validar_limites(limite_inicial, limite_final, palabra2) == SLICE_AND_CONCAT_ERROR)
                {
                    sintactic_error("Límites fuera de rango");
                }
                if (slice_and_concat(str_final, palabra1, palabra2, limite_inicial, limite_final) == SLICE_AND_CONCAT_ERROR)
                {
                    sintactic_error("La cadena final excede los 50 caracteres");
                }
            }
            else
            {
                //Validamos limites
                if (validar_limites(limite_inicial, limite_final, palabra1) == SLICE_AND_CONCAT_ERROR)
                {
                    sintactic_error("Límites fuera de rango");
                }
                if (slice_and_concat(str_final, palabra2, palabra1, limite_inicial, limite_final) == SLICE_AND_CONCAT_ERROR)
                {
                    sintactic_error("La cadena final excede los 50 caracteres");
                }
            }
            // Asignar id_destino
            symbol sym;
            snprintf(sym.name, sizeof(sym.name), "T_%s", str_final);
            sanitize_string(sym.name);
            strcpy(sym.data_type, "string");
            strcpy(sym.value, str_final);
            sym.length = strlen(str_final);
            insert_symbol(sym, &symbol_table);

            agregar_terceto(terceto, &lista_tercetos, ":=", id_destino, sym.name);

            RULE("sliceAndConcat -> SLICE_AND_CONCAT PA CTE_INT COMA CTE_INT COMA CTE_STRING COMA CTE_STRING COMA CTE_INT PC");
        }
    ;

reorder: /*El anteultimo cte/id tendria que ser un bool*/
    REORDER PA OPEN_BRACKET expressions_list CLOSE_BRACKET COMA CTE_INT COMA CTE_INT PC 
        {
            int direccion = $7; //1: izq, 0: der
            int pivote = $9;
            int inicio_ordenamiento;
            int fin_ordenamiento;
            tTerceto terceto;
            int contador;
            symbol sym;

            strcpy(sym.name, "min_");
            strcpy(sym.data_type, "int");
            strcpy(sym.value, "0");
            sym.length = 0;
            insert_symbol(sym, &symbol_table);

            strcpy(sym.name, "aux_");
            strcpy(sym.data_type, "int");
            strcpy(sym.value, "0");
            sym.length = 0;
            insert_symbol(sym, &symbol_table);

            strcpy(sym.name, "T_corchete_abre");
            strcpy(sym.data_type, "string");
            strcpy(sym.value, "\"[\"");
            sym.length = 1;
            insert_symbol(sym, &symbol_table);

            strcpy(sym.name, "T_corchete_cierra");
            strcpy(sym.data_type, "string");
            strcpy(sym.value, "\"]\"");
            sym.length = 1;
            insert_symbol(sym, &symbol_table);

            strcpy(sym.name, "T_coma");
            strcpy(sym.data_type, "string");
            strcpy(sym.value, "\";\"");
            sym.length = 1;
            insert_symbol(sym, &symbol_table);

            //Validaciones
            if (direccion < 0 && direccion > 1)
            {
                sintactic_error("Dirección inválida. Debe ser 0 (derecha) o 1 (izquierda).");
            }
            if (pivote < 0 || pivote > contador_expresiones_reorder)
            {
                sintactic_error("Pivote fuera de rango");
            }

            // Inicio de ordenamiento
            if (direccion == 0)
            {
                inicio_ordenamiento = pivote;
                fin_ordenamiento = contador_expresiones_reorder + 1;
            }
            else
            {
                inicio_ordenamiento = 0;
                fin_ordenamiento = pivote + 1;
            }
            //Crear los tercetos que ordenaran las variables
            crear_tercetos_ordenamiento(inicio_ordenamiento, fin_ordenamiento, &lista_tercetos, &lista_aux_reorder);

            // Mostrar resultado
            char primer_variable_lista[50];
            obtenerElemento(&lista_aux_reorder, &primer_variable_lista, sizeof(primer_variable_lista), 0);

            if(check_var_is_int(primer_variable_lista, &symbol_table)){
                crear_print_tercetos(contador, 0, contador_expresiones_reorder, &lista_tercetos, &lista_aux_reorder);
            }
            else{
                crear_print_tercetos(contador, 1, contador_expresiones_reorder, &lista_tercetos, &lista_aux_reorder);
            }

            vaciarListaSinDestruir(&lista_aux_reorder);

            RULE("REORDER -> REORDER PA OPEN_BRACKET expressions_list CLOSE_BRACKET COMA CTE_INT COMA CTE_INT PC");
        }
    ;

expressions_list:
    expressions_list COMA expression 
        {
            tTerceto terceto;
            int index_expression_list = $1;
            int index_expression = $3;

            char sample_var_expression_list[50];
            char str_var_expression[50];
            
            sprintf(str_var_expression,"aux_var_%d", index_expression);
            sprintf(sample_var_expression_list, "aux_var_%d", index_expression_list);

            contador_expresiones_reorder++;

            if(compare_datatypes(str_var_expression, sample_var_expression_list, &symbol_table) == DIFFERENT_DATATYPE){
                symbol_table_to_file("symbol_table.txt", &symbol_table);
                printf("%s\n", str_var_expression);
                printf("%s\n", sample_var_expression_list);
                semantic_error("Error: No se pueden hacer reorder entre expresiones de diferente tipo de dato");
            }

            ponerAlFinal(&lista_aux_reorder, &str_var_expression, sizeof(str_var_expression));

            $$ = index_expression;

            RULE("expressions_list -> expressions_list COMA expression");
        }
    | expression 
        {
            tTerceto terceto;
            int index_expression = $1;
            char str_var_expression[50];
            contador_expresiones_reorder = 0;

            sprintf(str_var_expression,"aux_var_%d", index_expression);

            ponerAlFinal(&lista_aux_reorder, &str_var_expression, sizeof(str_var_expression));

            $$ = index_expression;

            RULE("expressions_list -> expression");
        }
    ;

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
    crearLista(&aux_conditions);
    crearLista(&aux_else);
    crearLista(&lista_aux_reorder);

    int parserResult = yyparse();

	fclose(yyin);

	printf("Syntax OK \n");

    symbol_table_to_file("symbol_table.txt", &symbol_table);
    terceto_to_file("intermediate_code.txt", &lista_tercetos);
    return 0;
}


int semantic_error(char* e)
{
    extern int yylineno;
    printf("Error Semantico en la línea %d: %s\n", yylineno, e);
    printf("Token inesperado o contexto: '%s'\n", yytext);
    exit(1);
}


int sintactic_error(char* e)
{
    extern int yylineno;
    printf("Error Sintactico en la línea %d: %s\n", yylineno, e);
    printf("Token inesperado o contexto: '%s'\n", yytext);
    exit(1);
}

int yyerror(char* e)
{
    extern int yylineno;
    printf("Error Sintactico en la línea %d: %s\n", yylineno, e);
    printf("Token inesperado o contexto: '%s'\n", yytext);
    exit(1);
}