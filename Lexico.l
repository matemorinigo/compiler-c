%{
#include <stdio.h>
#include <stdlib.h>

#include "y.tab.h"
FILE  *yyin;
int yylval;
char *yyltext;


int yyerror(void);

%}

%option noyywrap  
%option yylineno


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

%%

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