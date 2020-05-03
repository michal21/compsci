%{
#include <iostream>
#include <string>

#define CECHO(c) if (c) { ECHO; }

extern "C" int yywrap(), yylex();

bool wrt = true, wdoc = false, bsl = false;
%}

%x STRING
%x LCOM
%x BCOM

ws [ \t]*
en (\\\n)?

%%

^{ws}#{ws}include{ws}<.*> { ECHO; }

\"                        { ECHO; BEGIN(STRING); }
<STRING>\"                { ECHO; if (!bsl) { BEGIN(INITIAL); } bsl = false; }
<STRING>\\                { ECHO; bsl = !bsl; }
<STRING>\n                { ECHO; if (!bsl) { BEGIN(INITIAL); } bsl = false; }
<STRING>[^"]              { ECHO; bsl = false; }

<BCOM>"*"{en}"/"          { CECHO(wrt) else { std::putchar(' '); } BEGIN(INITIAL); wrt = true; }
<BCOM>.                   { CECHO(wrt) }
"/"{en}"*"{en}"*"         { CECHO(wdoc) BEGIN(BCOM); wrt = wdoc; }
"/"{en}"*"{en}"!"         { CECHO(wdoc) BEGIN(BCOM); wrt = wdoc; }
"/"{en}"*"                { BEGIN(BCOM); wrt = false; }

<LCOM>\\                  { CECHO(wrt) bsl = true; }
<LCOM>\n                  { ECHO; if (!bsl) { BEGIN(INITIAL); wrt = true; } bsl = false; }
<LCOM>[^ \t\\\n]          { CECHO(wrt) bsl = false; }
<LCOM>[ \t]               { CECHO(wrt) }
"/"{en}"/"{en}"/"         { CECHO(wdoc) BEGIN(LCOM); wrt = wdoc; }
"/"{en}"/"{en}"!"         { CECHO(wdoc) BEGIN(LCOM); wrt = wdoc; }
"/"{en}"/"                { BEGIN(LCOM); wrt = false; }

.                         { CECHO(wrt) }
%%

int yywrap() {
    return 1;
}

int main(int argc) {
    if (argc > 1) {
        wdoc = true;
    }
    return yylex();
}
