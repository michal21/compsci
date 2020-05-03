%{
#include <iostream>
#include <string>
#include <stack>
#include <cmath>
#include <stdexcept>

#define IMPL_OP(o) if (stk.size() >= 2) { auto a = stkpop(), b = stkpop(); stk.push(b o a); } else { PERR("too few args"); }
#define IMPL_DOP(o) if (stk.size() >= 2) { auto a = stkpop(), b = stkpop(); if (a == 0) { PERR("div by 0"); } else { stk.push(b o a); } } else { PERR("too few args"); }
#define PERR(es) do { std::cout << "err: " << es << '\n'; stk = std::stack<int>(); BEGIN(ERR); } while (0);

extern "C" int yywrap(), yylex();

std::stack<int> stk;

extern "C++" auto stkpop() {
    auto r = stk.top();
    stk.pop();
    return r;
}

%}
%x ERR
%%
-?(0|[1-9][0-9]*) { try { stk.push(std::stoi(yytext)); } catch (std::out_of_range &e) { PERR("out of range"); } }
"+"               { IMPL_OP(+) }
"-"               { IMPL_OP(-) }
"*"               { IMPL_OP(*) }
"/"               { IMPL_DOP(/) }
"%"               { IMPL_DOP(%) }
"^"               { if (stk.size() >= 2) { auto a = stkpop(), b = stkpop(); stk.push(std::pow(b, a)); } else { PERR("too few args"); } }
\n                { if (stk.size() == 1) { std::cout << "= " << stkpop() << '\n'; } else { std::cout << "err: too few ops" << '\n'; stk = std::stack<int>(); } }
[ \t]             {}
.                 { PERR("unexpected '" << yytext << '\''); }

<ERR>\n           { BEGIN(INITIAL); }
<ERR>.            {}
%%

int yywrap() {
    return 1;
}

int main() {
    return yylex();
}
