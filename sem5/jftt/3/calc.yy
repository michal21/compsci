%{
#include <iostream>
#include <string>
#include <sstream>
#include <vector>
#include <cstdio>
#include <cmath>
#define YYSTYPE int
int yylex(), yyerror(char *s);
void fin(int v);
std::stringstream repr;
bool err;
%}

%token VAL END ERROR
%left  '+' '-'
%left  '*' '/' '%'
%right '^'
%left  '('

%precedence NEG

%%
input: input line
     | %empty;
;

line: END
    | expr END  { fin($$); }
    | error END	{ err = true; fin(0); }
;

expr: VAL                 { repr << " " << $1; $$ = $1; }
    | %prec NEG '-' expr  { repr << " ~"; $$ = -$2; }
    | expr '+' expr       { repr << " +"; $$ = $1 + $3; }
    | expr '-' expr       { repr << " -"; $$ = $1 - $3; }
    | expr '*' expr       { repr << " *"; $$ = $1 * $3; }
    | expr '/' expr       { repr << " /"; if ($3 == 0) { err = true; } $$ = std::floor(1. * $1 / $3); }
    | expr '%' expr       { repr << " %"; if ($3 == 0) { err = true; } $$ = $1 - std::floor(1. * $1 / $3) * $3; }
    | expr '^' expr       { repr << " ^"; $$ = std::pow($1, $3); }
    | '(' expr ')'        { $$ = $2; }

;

%%
