%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <float.h>
#include "symbol.h"

#include "y.tab.h"


extern tLista symbol_table;

%}

%option noyywrap  
%option yylineno

/*Caracteres alfanumericos*/
DIGITO              [0-9]
LETRA               [a-zA-Z]
BOOL                [0-1]

/*Operadores*/
OP_ASIG   		    ":="
OP_ASIG_COMUN       "="
OP_ARIT             "=:"
OP_SUM		        "+"
OP_MUL              "*"
OP_RES		        "-"
OP_DIV              "/"

/*Comparadores*/
MAYOR               ">"
MAYOR_IGUAL         ">="
MENOR               "<"
MENOR_IGUAL         "<="

/*Operadores logicos*/
AND                 "AND"
OR                  "OR"
NOT                 "NOT"

/*Parentesis, llaves y elementos que encierren cosas*/
PA			        "("
PC			        ")"
CBO                 "{"
CBC                 "}"
OPEN_COMM           "#+"
CLOSE_COMM          "+#"
OPEN_BRACKET        "["
CLOSE_BRACKET       "]"

/*Palabras reservadas*/
READ                "read"
WRITE               "write"
IF                  "if"
ELSE                "else"
INIT                "init"
WHILE               "while"
SLICE_AND_CONCAT    "sliceAndConcat"
REORDER             "reorder"
TIPO_DATO           ("Float"|"Int"|"String")


ID                  {LETRA}+({DIGITO}|{LETRA})*

PUNTO               "."
COM                 "\""
DOS_PUNTOS          ":"
COMA                ","

/*Constantes*/
CTE_INT             {DIGITO}+
CTE_FLOAT           (({DIGITO}*{PUNTO}{DIGITO}+)|({DIGITO}+{PUNTO}{DIGITO}*))
CTE_STRING          \"([^\"\n]|\\\")*\"
CTE_BOOL            {BOOL}

COMM                {OPEN_COMM}.*{CLOSE_COMM}

       
%%
{OP_ASIG}           {
                        yylval.str_val = strdup(yytext);
                        return OP_ASIG;
                    }
{OP_ASIG_COMUN}     {
                        yylval.str_val = strdup(yytext);
                        return OP_ASIG_COMUN;
                    }
{OP_ARIT}           {
                        yylval.str_val = strdup(yytext);
                        return OP_ARIT;
                    }
{OP_SUM}            {
                        yylval.str_val = strdup(yytext);
                        return OP_SUM;
                    }
{OP_MUL}            {
                        yylval.str_val = strdup(yytext);
                        return OP_MUL;
                    }
{OP_RES}            {
                        yylval.str_val = strdup(yytext);
                        return OP_RES;
                    }
{OP_DIV}            {
                        yylval.str_val = strdup(yytext);
                        return OP_DIV;
                    }


{MAYOR}             {
                        yylval.str_val = strdup(yytext);
                        return MAYOR;
                    }
{MAYOR_IGUAL}       {
                        yylval.str_val = strdup(yytext);
                        return MAYOR_IGUAL;
                    }
{MENOR}             {
                        yylval.str_val = strdup(yytext);
                        return MENOR;
                    }
{MENOR_IGUAL}       {
                        yylval.str_val = strdup(yytext);
                        return MENOR_IGUAL;
                    }


{AND}               {
                        yylval.str_val = strdup(yytext);
                        return AND;
                    }
{OR}                {
                        yylval.str_val = strdup(yytext);
                        return OR;
                    }
{NOT}               {
                        yylval.str_val = strdup(yytext);
                        return NOT;
                    }


{PA}                {return PA;}
{PC}                {return PC;}
{CBO}               {return CBO;}
{CBC}               {return CBC;}
{OPEN_BRACKET}      {return OPEN_BRACKET;}
{CLOSE_BRACKET}     {return CLOSE_BRACKET;}


{WHILE}             {return WHILE;}
{READ}              {return READ;}
{WRITE}             {return WRITE;}
{SLICE_AND_CONCAT}  {return SLICE_AND_CONCAT;}
{REORDER}           {return REORDER;}
{IF}                {return IF;}
{ELSE}              {return ELSE;}
{INIT}              {return INIT;}
{TIPO_DATO}         {
                        yylval.str_val = strdup(yytext);
                        return TIPO_DATO;
                    }

{ID}                {
                        symbol sym;

                        strcpy(sym.name, yytext);
                        strcpy(sym.data_type, "");
                        strcpy(sym.value, "");
                        sym.length = strlen(yytext);
                        insert_symbol(sym, &symbol_table);
                        yylval.str_val = strdup(yytext);
                        return ID;
                    }

{PUNTO}             {return PUNTO;}
{COM}               {return COM;}
{DOS_PUNTOS}        {return DOS_PUNTOS;}
{COMA}              {return COMA;}

{CTE_INT}           {
                        long value = strtol(yytext, NULL, 10);
                        if(value >= INT16_MIN && value <= INT16_MAX) {
                            symbol sym;

                            snprintf(sym.name, sizeof(sym.name), "_%s", yytext);
                            strcpy(sym.data_type, "int");
                            strcpy(sym.value, yytext);
                            sym.length = strlen(yytext);
                            insert_symbol(sym, &symbol_table);

                            yylval.int_val = (int)value;
                            return CTE_INT;
                        } else {
                            printf("Error: cte_int fuera del rango de 16 bits: %ld\n", value);
                        }
                    }

{CTE_FLOAT}         {
                        float value = strtof(yytext, NULL);
                        if (value <= FLT_MAX && value >= -FLT_MAX)
                        {
                            symbol sym;

                            snprintf(sym.name, sizeof(sym.name), "_%s", yytext);
                            strcpy(sym.data_type, "float");
                            strcpy(sym.value, yytext);
                            sym.length = strlen(yytext);
                            insert_symbol(sym, &symbol_table);

                            return CTE_FLOAT;
                        }
                        else {
                            printf("Error: cte_float fuera del rango de 32 bits (float): %s\n", yytext);
                        }       
                    }
{CTE_STRING}        {
                        if (strlen(yytext) <= 50){
                            symbol sym;

                            snprintf(sym.name, sizeof(sym.name), "_%s", yytext);
                            strcpy(sym.data_type, "string");
                            strcpy(sym.value, yytext);
                            sym.length = strlen(yytext);
                            insert_symbol(sym, &symbol_table);

                            yylval.str_val = strdup(yytext);
                            return CTE_STRING;
                        }
                        else {
                            printf("Error: tam_max de cadena superado\n");
                        }
                    }

{COMM}
"\n"      		    
"\t"
"\n\t"
" "             		
"\r\n"
.			        { printf( "ERROR LEXICO : Caracter no reconocido: '%s'\n", yytext ); exit (0);}

%%

