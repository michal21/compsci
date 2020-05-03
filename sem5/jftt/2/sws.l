%{
#include <cstdio> 

extern "C" int yywrap(), yylex();

int nls = 0, nws = 0, cnws = 0;

%} 

%%
[ \t]+    { std::putchar(' '); }
[^ \t\n]+ { ECHO; nws++; }
\n        { if (nws != cnws) { std::putchar('\n'); nls++; cnws = nws; } }
%%

int yywrap() {
    std::printf("\nws: %d, ls: %d\n", nws, nls);
    return 1;
}

int main() {
    return yylex();
}
