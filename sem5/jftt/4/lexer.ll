%option noyywrap
%{
#include "tokens.hh"
#include "input.hh"
#include "log.hh"
int yylex();

#define YY_INPUT(buf, result, max_size) do { \
    result = input::getchars(buf, max_size); \
    if (result <= 0) {                       \
        result = YY_NULL;                    \
    }                                        \
} while (0)

#define YY_USER_ACTION input::offset(yyleng);

%}

%x COM

%%
"["                { BEGIN(COM); }
<COM>"]"           { BEGIN(INITIAL); }
<COM>.             { }
<COM>\n            { }

[ \t\v\r\n]+       { }
-?(0|[1-9][0-9]*)  { try { yylval.num = std::stoll(yytext); return T_NUM; } catch (std::out_of_range &e) { syntaxerror("number too large"); } }
[_a-z]+            { yylval.str = new std::string(yytext); return T_IDENTIFIER; }

"DECLARE"          { return T_DECLARE; }
"BEGIN"            { return T_BEGIN; }
"END"              { return T_END; }
"ASSIGN"           { return T_ASSIGN; }
"IF"               { return T_IF; }
"THEN"             { return T_THEN; }
"ELSE"             { return T_ELSE; }
"ENDIF"            { return T_ENDIF; }
"WHILE"            { return T_WHILE; }
"DO"               { return T_DO; }
"ENDWHILE"         { return T_ENDWHILE; }
"ENDDO"            { return T_ENDDO; }
"FOR"              { return T_FOR; }
"FROM"             { return T_FROM; }
"TO"               { return T_TO; }
"ENDFOR"           { return T_ENDFOR; }
"DOWNTO"           { return T_DOWNTO; }
"READ"             { return T_READ; }
"WRITE"            { return T_WRITE ; }
"PLUS"             { return T_PLUS; }
"MINUS"            { return T_MINUS; }
"TIMES"            { return T_TIMES; }
"DIV"              { return T_DIV; }
"MOD"              { return T_MOD; }
"EQ"               { return T_EQ; }
"NEQ"              { return T_NEQ; }
"LE"               { return T_LE; }
"GE"               { return T_GE; }
"LEQ"              { return T_LEQ; }
"GEQ"              { return T_GEQ; }

.	               { return yytext[0]; }
%%
