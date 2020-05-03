%{
#include <iostream>
#include <string>

extern "C" int yywrap(), yylex();

bool com;
std::string combuf;

%} 

%x STRING
%x CDATA

%%
\"                 { if (!com) { ECHO; BEGIN(STRING); } else { combuf.append(yytext); } }
<STRING>\"         { if (!com) { ECHO; BEGIN(INITIAL); } }
<STRING>[^"]*      { if (!com) { ECHO; } else { combuf.append(yytext); } }

"<![CDATA["        { if (!com) { ECHO; BEGIN(CDATA); } else { combuf.append(yytext); } }
<CDATA>"]]>"       { if (!com) { ECHO; BEGIN(INITIAL); } }
<CDATA>[^(\]\]>)]* { if (!com) { ECHO; } else { combuf.append(yytext); } }

"<!--"             { com = true; combuf = yytext; }
"-->"              { if (!com) { ECHO; } com = false; }
"--"               { if (com) { std::cout << combuf; ECHO; com = false; } }

.                  { if (!com) { ECHO; } else { combuf.append(yytext); } }
%%

int yywrap() {
    return 1;
}

int main() {
    return yylex();
}
