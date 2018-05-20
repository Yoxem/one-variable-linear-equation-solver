%option yylineno
%{
#include "y.tab.h"
int yycharno = 0;
%}


str     \"([^\n]|\\\")+\"
ws      [ \t]+
newline [\n]
alpha   [a-zA-Z]
dig     [0-9]
float1  {dig}+[.]{dig}+
int     {dig}+
float2  {float1}[eE][-+]?{dig}+
float   {float1}|{float2}
number  {int}|{float}
var     ([_]|{alpha})([_]|{alpha}|{dig})*
%%

{newline}  {yylineno  = yylineno + 1;return T_NEWLINE;}
{ws}     {yycharno = yycharno + yyleng;}
{var}    {yylval.strVal = strdup(yytext);
          yycharno = yycharno + yyleng;
          printf("yyval.strVal = %s",yylval.strVal);
          return T_VAR;}
{number} {yylval.floatVal = atof(yytext);
          yycharno = yycharno + yyleng;
          return T_NUM;}
"-"      {yycharno += 1;return T_SUB;}
"+"      {yycharno += 1;return T_ADD;}
"*"      {yycharno += 1;return T_MUL;}
"/"      {yycharno += 1; return T_DIV;}
"("      {yycharno += 1; return T_LPATH;}
")"      {yycharno += 1; return T_RPATH;}
.        {yycharno += 1;}

%%
int yywrap(void){
  return 1;
}
