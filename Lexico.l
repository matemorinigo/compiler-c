%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <float.h>

#include "y.tab.h"

int yyerror(void);

%}

%option noyywrap  
%option yylineno

/*Caracteres alfanumericos*/
DIGITO              [0-9]
LETRA               [a-zA-Z]
BOOL                [0-1]

/*Operadores*/
OP_ASIG   		    ":="
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

/*Palabras reservadas*/
READ                "read"
WRITE               "write"
IF                  "if"
ELSE                "else"
INIT                "init"
WHILE               "while"
SLICE_AND_CONCAT    "sliceAndConcat"
TIPO_DATO           ("Float"|"Int"|"String")


ID                  {LETRA}+({DIGITO}|{LETRA})*

PUNTO               "."
COM                 "\""
DOS_PUNTOS          ":"
COMA                ","

/*Constantes*/
CTE_INT             {OP_RES}?{DIGITO}+
CTE_FLOAT           {OP_RES}?(({DIGITO}*{PUNTO}{DIGITO}+)|({DIGITO}+{PUNTO}{DIGITO}*))
CTE_STRING          {COM}({DIGITO}|{LETRA})*{COM}
CTE_BOOL            {BOOL}


       
%%
{OP_ASIG}
{OP_SUM}            {printf("\nop_suma: %s\n", yytext);}
{OP_MUL}            {printf("\nop_mul: %s\n", yytext);}
{OP_RES}            {printf("\nop_res: %s\n", yytext);}
{OP_DIV}            {printf("\nop_div: %s\n", yytext);}


{MAYOR}             {printf("\nmayor: %s\n", yytext);}
{MAYOR_IGUAL}       {printf("\nmayor igual: %s\n", yytext);}
{MENOR}             {printf("\nmenor: %s\n", yytext);}
{MENOR_IGUAL}       {printf("\nmenor igual: %s\n", yytext);}


{AND}               {printf("\nand: %s\n", yytext);}
{OR}                {printf("\nor: %s\n", yytext);}
{NOT}               {printf("\nnot: %s\n", yytext);}


{PA}                {printf("\nparentesis abre: %s\n", yytext);}
{PC}                {printf("\nparentesis cierra: %s\n", yytext);}
{CBO}               {printf("\nllave abre: %s\n", yytext);}
{CBC}               {printf("\nllave cierra: %s\n", yytext);}
{OPEN_COMM}         {printf("\nopen comment: %s\n", yytext);}
{CLOSE_COMM}        {printf("\nclose comment: %s\n", yytext);}


{WHILE}             {printf("\nwhile: %s\n", yytext);}
{READ}              {printf("\nread: %s\n", yytext);}
{WRITE}             {printf("\nwrite: %s\n", yytext);}
{SLICE_AND_CONCAT}  {printf("\nsliceAndConcat: %s\n", yytext);}
{IF}                {printf("\nif: %s\n", yytext);}
{ELSE}              {printf("\nelse: %s\n", yytext);}
{INIT}              {printf("\ninit: %s\n", yytext);}
{TIPO_DATO}         {printf("\ntipo dato: %s\n", yytext);}

{ID}                {printf("\nid:%s\n", yytext);}

{PUNTO}             {printf("\npunto comment: %s\n", yytext);}
{COM}               {printf("\ncomillas: %s\n", yytext);}
{DOS_PUNTOS}        {printf("\ndos puntos:%s\n", yytext);}
{COMA}              {printf("\ncoma:%s\n", yytext);}

{CTE_INT}           {
                        long value = strtol(yytext, NULL, 10);
                        if(value >= INT16_MIN && value <= INT16_MAX)
                            printf("\ncte_int (16 bits): %ld\n", value);
                        else
                            printf("Error: cte_int fuera del rango de 16 bits: %ld\n", value);

                    }
{CTE_FLOAT}         {
                        float value = strtof(yytext, NULL);
                        if (value <= FLT_MAX && value >= -FLT_MAX)
                            printf("\ncte_float (32 bits): %f\n", value);
                        else
                            printf("Error: cte_float fuera del rango de 32 bits (float): %s\n", yytext);
                    }
{CTE_STRING}        {
                        if (strlen(yytext) <= 50)
                            printf("\ncte_string: %s\n", yytext);
                        else
                            printf("Error: tam_max de cadena superado\n");
                    }
{CTE_BOOL}          {printf("\ncte_bool:%s\n", yytext);}

"\n"      		
"\t"
"\n\t"
" "             		
"\r\n"
.			 { printf( "ERROR LEXICO : Caracter no reconocido: '%s'\n", yytext ); exit (0);}

%%


int main(int argc, char *argv[])
{
    if((yyin = fopen(argv[1], "rt"))==NULL)
    {
        printf("\nNo se puede abrir el archivo de prueba: %s\n", argv[1]);
        return 1;
    }

    yylex(); 
	fclose(yyin);
    return 0;
}

int yyerror(void)
{
    printf("Error Sintactico\n");
	exit (1);
}