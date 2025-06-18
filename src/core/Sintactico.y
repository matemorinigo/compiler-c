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
int yystopparser=0;
tLista symbol_table;
tLista lista_tercetos;
tLista aux_declarations;

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
int aux_index_jump;
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

%type <int_val> expression factor term arithmetic_assig cte comparison condition selection selection_condition loop while_condition

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
    program {generarAssembler(&symbol_table);}

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
                crear_variable(aux, $3, &symbol_table);
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
        char str_index_cte[20];
        sprintf(str_index_cte, "[%d]", index_cte);

        if(check_var_exists($1, &symbol_table) == 0){
            yyerror("ERROR: Variable usada pero no declarada");
        }
        char aux_datatype[50];
        sprintf(aux_datatype, "T_%s", ult_cte_detectada);

        if(compare_datatypes($1, aux_datatype, &symbol_table) == DIFFERENT_DATATYPE){
            printf("id: %s\n", $1);
            printf("cte: %s\n", aux_datatype);
            yyerror("ERROR: No se puede asignar una constante a una variable de diferente tipo");
        }

        if (check_var_is_int($1, &symbol_table))
            agregar_terceto(terceto, &lista_tercetos, "INT_ASIG", $1, str_index_cte);
        else if (check_var_is_float($1, &symbol_table))
            agregar_terceto(terceto, &lista_tercetos, "FLOAT_ASIG", $1, str_index_cte);
        else
            agregar_terceto(terceto, &lista_tercetos, "STRING_ASIG", $1, str_index_cte);

        RULE("assignment -> ID OP_ASIG cte");
    }
    ;

cte:
    CTE_INT
        {
            tTerceto terceto;
            char value[70];
            sprintf(value,"T_%s", yytext);
            index_cte = agregar_terceto(terceto, &lista_tercetos, value, NULL, NULL);
            $$ = index_cte;
            strcpy(ult_cte_detectada, yytext);
            RULE("cte -> CTE_INT");
        }
    | CTE_FLOAT 
        {
            tTerceto terceto;
            char value[70];
            sprintf(value,"T_%s", yytext);
            index_cte = agregar_terceto(terceto, &lista_tercetos, value, NULL, NULL);
            $$ = index_cte;
            strcpy(ult_cte_detectada, yytext);
            RULE("cte -> CTE_FLOAT");
        } 
    | CTE_STRING 
        {
            tTerceto terceto;
            char value[70];
            sprintf(value,"T_%s", yytext);
            index_cte = agregar_terceto(terceto, &lista_tercetos, value, NULL, NULL);
            $$ = index_cte;
            strcpy(ult_cte_detectada, yytext);
            RULE("cte -> CTE_STRING");
        }
    ;

selection:
    selection_condition CBO group_of_sentences CBC
        {
            tTerceto terceto;

            char str_index_condition[20];
            sprintf(str_index_condition, "[%d]", index_condition);

            char str_index_false[20];
            sprintf(str_index_false, "[%d]", obtener_indice_actual() + 1);

            actualizar_terceto(&lista_tercetos, $1, "JF", str_index_condition, str_index_false);
            RULE("selection -> IF PA condition PC CBO group_of_sentences CBC");
        }
    | selection_condition CBO group_of_sentences CBC ELSE 
        {
            tTerceto terceto;

            aux_index_jump = agregar_terceto(terceto, &lista_tercetos, "JMP", NULL, NULL);

            char str_index_condition[20];
            sprintf(str_index_condition, "[%d]", index_condition);

            char str_index_false[20];
            sprintf(str_index_false, "[%d]", obtener_indice_actual() + 1);

            actualizar_terceto(&lista_tercetos, $1, "JF", str_index_condition, str_index_false);
            RULE("selection -> IF PA condition PC CBO group_of_sentences CBC");
        }
        CBO group_of_sentences CBC
        {
            char str_index_false[20];
            sprintf(str_index_false, "[%d]", obtener_indice_actual() + 1);

            actualizar_terceto(&lista_tercetos, aux_index_jump, "JMP", NULL, str_index_false);

            RULE("selection -> IF PA condition PC CBO group_of_sentences CBC ELSE CBO group_of_sentences CBC");
        }

selection_condition:
    IF PA condition PC
        {
            tTerceto terceto;

            char str_index_condition[20];
            sprintf(str_index_condition, "[%d]", index_condition);

            $$ = agregar_terceto(terceto, &lista_tercetos, "JF", str_index_condition, NULL);
        }

loop:
    while_condition CBO group_of_sentences CBC 
        {
            tTerceto terceto;

            char str_index_condition[20];    
            sprintf(str_index_condition,"[%d]",index_condition);

            char str_index_false[20];
            sprintf(str_index_false, "[%d]", obtener_indice_actual() + 2);

            char str_index_loopback[20];
            sprintf(str_index_loopback, "[%d]", $1);

            actualizar_terceto(&lista_tercetos, $1, "JF", str_index_condition, str_index_false);

            /*Fijarse si vuelve a str_index_loopback o tiene que retorceder mas*/
            $$ = agregar_terceto(terceto,&lista_tercetos,"BI",str_index_loopback,NULL); 
            
            RULE("loop -> WHILE PA condition PC CBO group_of_sentences CBC ");
        }
    ;
while_condition:
    WHILE PA condition PC
    {
        tTerceto terceto;

        char str_index_condition[20];

        sprintf(str_index_condition,"[%d]",index_condition);

        $$ = agregar_terceto(terceto,&lista_tercetos,"JF",str_index_condition,NULL);        
    }
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
            sprintf(izq, "[%d]", index_condition);

            char der[20];
            sprintf(der, "[%d]", index_comparison);

            index_condition = agregar_terceto(terceto, &lista_tercetos, $2, izq, der);
            $$ = index_condition;
            RULE("condition -> condition AND comparison");
        }
    | condition OR comparison 
        {
            tTerceto terceto;

            char izq[20];
            sprintf(izq, "[%d]", index_condition);

            char der[20];
            sprintf(der, "[%d]", index_comparison);
        
            index_condition = agregar_terceto(terceto, &lista_tercetos, $2, izq, der);
            $$ = index_condition;
            RULE("condition -> condition OR comparison");
        }
    | NOT condition 
        {
            tTerceto terceto;

            char expr[20];
            sprintf(expr, "[%d]", index_condition);

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
            sprintf(str_left, "[%d]", $1);  // resultado de la izquierda

            char str_right[20];
            sprintf(str_right, "[%d]", $3);       // resultado de la derecha

            index_comparison = agregar_terceto(terceto, &lista_tercetos, $2, str_left, str_right);
            $$ = index_comparison;
            RULE("comparison -> expression MAYOR expression");
        }
    | expression MAYOR_IGUAL expression 
        {
            tTerceto terceto;

            char str_left[20];
            sprintf(str_left, "[%d]", $1);  // resultado de la izquierda

            char str_right[20];
            sprintf(str_right, "[%d]", $3);       // resultado de la derecha

            index_comparison = agregar_terceto(terceto, &lista_tercetos, $2, str_left, str_right);
            $$ = index_comparison;
            RULE("comparison -> expression MAYOR_IGUAL expression");
        }
    | expression MENOR_IGUAL expression 
        {
            tTerceto terceto;

            char str_left[20];
            sprintf(str_left, "[%d]", $1);  // resultado de la izquierda

            char str_right[20];
            sprintf(str_right, "[%d]", $3);       // resultado de la derecha

            index_comparison = agregar_terceto(terceto, &lista_tercetos, $2, str_left, str_right);
            $$ = index_comparison;
            RULE("comparison -> expression MENOR_IGUAL expression");
        }
    | expression MENOR expression 
        {
            tTerceto terceto;

            char str_left[20];
            sprintf(str_left, "[%d]", $1);  // resultado de la izquierda

            char str_right[20];
            sprintf(str_right, "[%d]", $3);       // resultado de la derecha

            index_comparison = agregar_terceto(terceto, &lista_tercetos, $2, str_left, str_right);
            $$ = index_comparison;
            RULE("comparison -> expression MENOR expression");
        }
    ;

arithmetic_assig:
    ID OP_ARIT expression 
    {
        if(check_var_exists($1, &symbol_table) == 0){
            yyerror("ERROR: Variable usada pero no declarada");
        }

        if(check_var_is_int($1, &symbol_table) == 0){
            yyerror("ERROR: No se pueden hacer asignaciones aritmeticas sobre flotantes (es una feature)");
        }

        tTerceto terceto;
        char str_index_expression[20];
        sprintf(str_index_expression, "[%d]", index_expression);
        
        index_arit_assig = agregar_terceto(terceto, &lista_tercetos, "ARIT_ASIG", $1, str_index_expression);
        $$ = index_arit_assig;

        RULE("arithmetic_assig -> ID OP_ARIT expression");
    }
    ;

expression:
    expression OP_SUM term
        {
            tTerceto terceto;



            char str_index_expression[20];
            sprintf(str_index_expression, "[%d]", index_expression);

            char str_index_term[20];
            sprintf(str_index_term, "[%d]", index_term);

            index_expression = agregar_terceto(terceto, &lista_tercetos, "SUM",str_index_expression, str_index_term);
            $$ = index_expression;
            RULE("expression -> expression OP_SUM term");
        }
    | expression OP_RES term
        {
            tTerceto terceto;

            char str_index_expression[20];
            sprintf(str_index_expression, "[%d]", index_expression);

            char str_index_term[20];
            sprintf(str_index_term, "[%d]", index_term);

            index_expression = agregar_terceto(terceto, &lista_tercetos, "RES",str_index_expression, str_index_term);
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
            sprintf(str_index_term, "[%d]", index_term);

            char str_index_factor[20];
            sprintf(str_index_factor, "[%d]", index_factor);

            index_term = agregar_terceto(terceto, &lista_tercetos, "MUL",str_index_term, str_index_factor);
            $$ = index_term;
            RULE("term -> term OP_MUL factor");
        }
    | term OP_DIV factor     
        {
            tTerceto terceto;

            char str_index_term[20];
            sprintf(str_index_term, "[%d]", index_term);

            char str_index_factor[20];
            sprintf(str_index_factor, "[%d]", index_factor);

            index_term = agregar_terceto(terceto, &lista_tercetos, "DIV",str_index_term, str_index_factor);
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
            if(check_var_exists($1, &symbol_table) == 0){
                yyerror("ERROR: Variable usada pero no declarada");
            }

            if(check_var_is_int($1, &symbol_table) == 0){
                yyerror("ERROR: No se puede hacer operaciones aritmeticas con flotantes (es una feature)");
            }

            tTerceto terceto;
            char value[70];
            sprintf(value,"%s", yytext);
            index_factor = agregar_terceto(terceto, &lista_tercetos, value, NULL, NULL);
            $$ = index_factor;
            RULE("factor -> ID");
        }
    | CTE_INT 
        {
            tTerceto terceto;
            char value[70];
            sprintf(value,"T_%s", yytext);
            index_factor = agregar_terceto(terceto, &lista_tercetos, value, NULL, NULL);
            $$ = index_factor;
            RULE("factor -> CTE_INT");
        }
    ;


input:
    READ PA ID PC 
        {
            if(check_var_exists($3, &symbol_table) == 0){
                yyerror("ERROR: Variable usada pero no declarada");
            }

            if(check_var_is_string($3, &symbol_table) == IS_NOT_STRING){
                yyerror("ERROR: La funcion READ debe recibir una variable string");
            }

            tTerceto terceto;
            char var_destino[50];
            strcpy(var_destino, $3);

            agregar_terceto(terceto, &lista_tercetos, "READ", var_destino, NULL);

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
                yyerror("ERROR: Variable usada pero no declarada");
            }
            if(check_var_is_numeric($3, &symbol_table) == IS_NOT_NUMERIC){
                yyerror("ERROR: La funcion WRITE debe recibir una variable numerica");
            }

            tTerceto terceto;
            char id_to_print[50];
            strcpy(id_to_print, $3);

            agregar_terceto(terceto, &lista_tercetos, "PRINT_VAR", id_to_print, NULL);
            RULE("output -> WRITE PA ID PC");
        }
    ;

sliceAndConcat: /*El ultimo cte/id tendria que ser un bool*/
    ID OP_ASIG_COMUN SLICE_AND_CONCAT PA CTE_INT COMA CTE_INT COMA CTE_STRING COMA CTE_STRING COMA CTE_INT PC 
        {
            if(check_var_exists($1, &symbol_table) == 0){
                yyerror("ERROR: Variable usada pero no declarada");
            }

            if(check_var_is_string($1, &symbol_table) == IS_NOT_STRING){
                yyerror("ERROR: La funcion sliceAndConcat devuelve un string");
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
            strcpy(palabra1, $9);
            strcpy(palabra2, $11);

            eliminar_caracter(palabra1, '"');
            eliminar_caracter(palabra2, '"');

            int concatenarEnPalabra1 = $13; //Booleano, si True, cortamos palabra 2 y concatenamos a 1
                                            //Si False, cortamos palabra 1 y concatenamos a 2

            //Validar
            if(validar_concatenarEnPalabra1(concatenarEnPalabra1) == SLICE_AND_CONCAT_ERROR)
            {
                yyerror("valor de concatenarEnPalabra1 inválida, debe ser 0 o 1");
            }
            
            // Generar str_final
            if (concatenarEnPalabra1 == 1)
            {
                //Validamos limites
                if (validar_limites(limite_inicial, limite_final, palabra2) == SLICE_AND_CONCAT_ERROR)
                {
                    yyerror("Límites fuera de rango");
                }
                if (slice_and_concat(str_final, palabra1, palabra2, limite_inicial, limite_final) == SLICE_AND_CONCAT_ERROR)
                {
                    yyerror("La cadena final excede los 50 caracteres");
                }
            }
            else
            {
                //Validamos limites
                if (validar_limites(limite_inicial, limite_final, palabra1) == SLICE_AND_CONCAT_ERROR)
                {
                    yyerror("Límites fuera de rango");
                }
                if (slice_and_concat(str_final, palabra2, palabra1, limite_inicial, limite_final) == SLICE_AND_CONCAT_ERROR)
                {
                    yyerror("La cadena final excede los 50 caracteres");
                }
            }
            // Asignar id_destino
            idx_aux = agregar_terceto(terceto, &lista_tercetos, str_final, NULL, NULL);
            sprintf(str_idx_aux, "[%d]", idx_aux);

            agregar_terceto(terceto, &lista_tercetos, "STRING_ASIG", id_destino, str_idx_aux);

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
            char* nombre_base_variable_aux = "interna_@expr_";
            char nombre_dinamico_variable[50];
            int contador;

            //Validaciones
            if (direccion < 0 && direccion > 1)
            {
                yyerror("Dirección inválida. Debe ser 0 (derecha) o 1 (izquierda).");
            }
            if (pivote < 0 || pivote > contador_expresiones_reorder)
            {
                yyerror("Pivote fuera de rango");
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
            crear_tercetor_ordenamiento(inicio_ordenamiento, fin_ordenamiento, nombre_base_variable_aux, &lista_tercetos);

            // Mostrar resultado
            crear_print_tercetos(contador, contador_expresiones_reorder, nombre_base_variable_aux, &lista_tercetos);

            RULE("REORDER -> REORDER PA OPEN_BRACKET expressions_list CLOSE_BRACKET COMA CTE_INT COMA CTE_INT PC");
        }
    ;

expressions_list:
    expressions_list COMA expression 
        {
            symbol sym;
            char* nombre_base_variable_aux = "interna_@expr_";
            char nombre_dinamico_variable[50];
            char str_index_expression[50];
            tTerceto terceto;

            contador_expresiones_reorder++;
            sprintf(str_index_expression,"[%d]", $3);
            sprintf(nombre_dinamico_variable, "%s%d", nombre_base_variable_aux, contador_expresiones_reorder);

            sprintf(sym.name, "%s", nombre_dinamico_variable);
            strcpy(sym.data_type, "int");
            strcpy(sym.value, "0");
            sym.length = strlen(nombre_dinamico_variable);
            insert_symbol(sym, &symbol_table);

            agregar_terceto(terceto, &lista_tercetos, "=:", nombre_dinamico_variable, str_index_expression);

            RULE("expressions_list -> expressions_list COMA expression");
        }
    | expression 
        {
            symbol sym;
            char* nombre_base_variable_aux = "interna_@expr_";
            char nombre_dinamico_variable[50];
            char str_index_expression[50];
            tTerceto terceto;

            contador_expresiones_reorder = 0;
            sprintf(str_index_expression,"[%d]", $1);
            sprintf(nombre_dinamico_variable, "%s%d", nombre_base_variable_aux, contador_expresiones_reorder);


            sprintf(sym.name, "%s", nombre_dinamico_variable);
            strcpy(sym.data_type, "int");
            strcpy(sym.value, "0");
            sym.length = strlen(nombre_dinamico_variable);
            insert_symbol(sym, &symbol_table);

            agregar_terceto(terceto, &lista_tercetos, "=:", nombre_dinamico_variable, str_index_expression);

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

    int parserResult = yyparse();

	fclose(yyin);

	printf("Syntax OK \n");

    symbol_table_to_file("symbol_table.txt", &symbol_table);
    terceto_to_file("intermediate_code.txt", &lista_tercetos);
    return 0;
}

int yyerror(char* e)
{
    extern int yylineno;
    printf("Error Sintactico en la línea %d: %s\n", yylineno, e);
    printf("Token inesperado o contexto: '%s'\n", yytext);
    exit(1);
}
