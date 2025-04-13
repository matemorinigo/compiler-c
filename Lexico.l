%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "y.tab.h"
FILE  *yyin;
int yylval;
char *yyltext;


int yyerror(void);

%}

%option noyywrap  
%option yylineno

DIGITO              [0-9]
LETRA               [a-zA-Z]
OP_AS   		    ":="
OP_SUM		        "+"
OP_MUL              "*"
OP_RES		        "-"
OP_DIV              "/"
PA			        "("
PC			        ")"
WHILE               "while"
MT                  ">"
LT                  "<"
CBO                 "{"
CBC                 "}"
OPEN_COMM           "#+"
CLOSE_COMM          "+#"
PUNTO_DECIMAL       "."
COM                 ""'
READ                "read"
WRITE               "write"
IF                  "if"
ELSE                "else"
CTE_INT             {OP_RES}?{DIGITO}+
CTE_FLOAT           {OP_RES}?{DIGITO}+{PUNTO}{DIGITO}+
CTE_STRING          {COM}{DIGITO|LETRA}*{COM}



%%
{DIGITO}            {printf("\ndigito: %s\n", yytext);}
{LETRA}             {printf("\nletra: %s\n", yytext);}
{OP_SUM}            {printf("\nop_suma: %s\n", yytext);}
{OP_MUL}            {printf("\nop_mul: %s\n", yytext);}
{OP_RES}            {printf("\nop_res: %s\n", yytext);}
{OP_DIV}            {printf("\nop_div: %s\n", yytext);}
{PA}                {printf("\nparentesis abre: %s\n", yytext);}
{PC}                {printf("\nparentesis cierra: %s\n", yytext);}
{WHILE}             {printf("\nwhile: %s\n", yytext);}
{MT}                {printf("\nmore than: %s\n", yytext);}
{LT}                {printf("\nless than: %s\n", yytext);}
{CBO}               {printf("\nllave abre: %s\n", yytext);}
{CBC}               {printf("\nllave cierra: %s\n", yytext);}
{OPEN_COMM}         {printf("\nopen comment: %s\n", yytext);}
{CLOSE_COMM}        {printf("\nclose comment: %s\n", yytext);}
{PUNTO_DECIMAL}     {printf("\npunto_decimal comment: %s\n", yytext);}
{COM}               {printf("\ncomillas: %s\n", yytext);}
{READ}              {printf("\nread: %s\n", yytext);}
{WRITE}             {printf("\nwrite: %s\n", yytext);}
{IF}                {printf("\nif: %s\n", yytext);}
{ELSE}              {printf("\nelse: %s\n", yytext);}
{CTE_INT}           {(sizeof(CTE_INT) <= 16) ? (printf("\ncte_int: %s\n", yytext)):(print("Error: cant de bytes superadas));}
{CTE_FLOAT}         {(sizeof(CTE_FLOAT) <= 32) ? (printf("\ncte_float: %s\n", yytext)):(print("Error: cant de bytes superadas));}
{CTE_STRING}        {strlen(CTE_STRING) <= 50 ? (printf("\ncte_string: %s\n", yytext)):(print("Error: tam_max de cadena superado));}


"\n"      		
"\t"
"\n\t"
" "             		
"\r\n"
.			 { printf( "ERROR LEXICO : Caracter no reconocido: %s\n", yytext ); exit (0);}

%%


int main(int argc, char *argv[])
{
    if((yyin = fopen(argv[1], "rt"))==NULL)
    {
        printf("\nNo se puede abrir el archivo de prueba: %s\n", argv[1]);
       
    }
    else
    { 
        
        yylex();
        
    }
	fclose(yyin);
        return 0;
}
int yyerror(void)
     {
       printf("Error Sintactico\n");
	 exit (1);
     }