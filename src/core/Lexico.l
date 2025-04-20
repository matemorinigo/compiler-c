%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <float.h>

#include "y.tab.h"




%}

%option noyywrap  
%option yylineno

/*Caracteres alfanumericos*/
DIGITO              [0-9]
LETRA               [a-zA-Z]
BOOL                [0-1]

/*Operadores*/
OP_ASIG   		    ":="
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
CTE_INT             {OP_RES}?{DIGITO}+
CTE_FLOAT           {OP_RES}?(({DIGITO}*{PUNTO}{DIGITO}+)|({DIGITO}+{PUNTO}{DIGITO}*))
CTE_STRING          {COM}({DIGITO}|{LETRA}|" ")*{COM}
CTE_BOOL            {BOOL}


       
%%
{OP_ASIG}           {return OP_ASIG;}
{OP_ARIT}           {return OP_ARIT;}
{OP_SUM}            {return OP_SUM;}
{OP_MUL}            {return OP_MUL;}
{OP_RES}            {return OP_RES;}
{OP_DIV}            {return OP_DIV;}


{MAYOR}             {return MAYOR;}
{MAYOR_IGUAL}       {return MAYOR_IGUAL;}
{MENOR}             {return MENOR;}
{MENOR_IGUAL}       {return MENOR_IGUAL;}


{AND}               {return AND;}
{OR}                {return OR;}
{NOT}               {return NOT;}


{PA}                {return PA;}
{PC}                {return PC;}
{CBO}               {return CBO;}
{CBC}               {return CBC;}
{OPEN_COMM}         {return OPEN_COMM;}
{CLOSE_COMM}        {return CLOSE_COMM;}
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
{TIPO_DATO}         {return TIPO_DATO;}

{ID}                {return ID;}

{PUNTO}             {return PUNTO;}
{COM}               {return COM;}
{DOS_PUNTOS}        {return DOS_PUNTOS;}
{COMA}              {return COMA;}

{CTE_INT}           {
                        long value = strtol(yytext, NULL, 10);
                        if(value >= INT16_MIN && value <= INT16_MAX)
                            return CTE_INT;
                        else
                            printf("Error: cte_int fuera del rango de 16 bits: %ld\n", value);

                    }
{CTE_FLOAT}         {
                        float value = strtof(yytext, NULL);
                        if (value <= FLT_MAX && value >= -FLT_MAX)
                             return CTE_FLOAT;
                        else
                            printf("Error: cte_float fuera del rango de 32 bits (float): %s\n", yytext);
                    }
{CTE_STRING}        {
                        if (strlen(yytext) <= 50)
                            return CTE_STRING;
                        else
                            printf("Error: tam_max de cadena superado\n");
                    }


"\n"      		    
"\t"
"\n\t"
" "             		
"\r\n"
.			        { printf( "ERROR LEXICO : Caracter no reconocido: '%s'\n", yytext ); exit (0);}

%%

