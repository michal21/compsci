%option noyywrap
%{
#include "calc.yy.hh"
#include <string>
#include <stdexcept>
#include <cstdio>
#define YY_INPUT(buf,result,max_size) result = mygetinput(buf, max_size);
int yylex();
int mygetinput(char *buf, int size);
%}

%x COM

%%
^#       { BEGIN(COM); return END; }
<COM>\n  { BEGIN(INITIAL); }
<COM>.   { }
[ \t]+   { }
[0-9]+ 	 { try { yylval = std::stoi(yytext); return VAL; } catch (std::out_of_range &e) { return ERROR; } }
\n	     { return END; }
.	     { return yytext[0]; }
%%
