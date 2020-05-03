%locations

%code requires {
#include "main.hh"
#include "input.hh"
#include "instr.hh"

#define M(x) std::move(x)
#define D1(a) delete a
#define D2(a, b) do { D1(a); D1(b); } while (0)
#define D3(a, b, c) do { D2(a, b); D1(c); } while (0)
#define D4(a, b, c, d) do { D3(a, b, c); D1(d); } while (0)

#define SP(x) input::setppos(x)
}

%union value {
    i64          num;
    std::string *str;

    Value       *val;
    Instr       *instr;
    Cond        *cond;
    IExpr       *expr;
    IBlock      *block;
}

%{
#undef YYERROR_VERBOSE
#define YYERROR_VERBOSE 1
int yylex(), yyerror(const char *s);
%}

%token T_DECLARE "DECLARE" T_BEGIN "BEGIN" T_END "END" T_ASSIGN "ASSIGN" T_IF "IF" T_THEN "THEN"
%token T_ELSE "ELSE" T_ENDIF "ENDIF" T_WHILE "WHILE" T_DO "DO" T_ENDWHILE "ENDWHILE" T_ENDDO "ENDDO"
%token T_FOR "FOR" T_FROM "FROM" T_TO "TO" T_ENDFOR "ENDFOR" T_DOWNTO "DOWNTO" T_READ "READ"
%token T_WRITE "WRITE" T_PLUS "PLUS" T_MINUS "MINUS" T_TIMES "TIMES" T_DIV "DIV" T_MOD "MOD" T_EQ "EQ"
%token T_NEQ "NEQ" T_LE "LE" T_GE "GE" T_LEQ "LEQ" T_GEQ "GEQ"
%token T_NUM "number" T_IDENTIFIER "identifier" ERROR

%type<num> T_NUM
%type<str> T_IDENTIFIER

%type<val> lvalue value
%type<cond> condition
%type<expr> expression

%type<instr> command
%type<block> commands

%%
program:      T_DECLARE declarations T_BEGIN commands T_END             { code = M(*$4); D1($4); }
              | T_BEGIN commands T_END                                  { code = M(*$2); D1($2); }
;
declarations: declarations ',' T_IDENTIFIER                             { SP(@3); declare_var(M(*$3));               D1($3); }
              | declarations ',' T_IDENTIFIER '(' T_NUM ':' T_NUM ')'   { SP(@3); declare_var(M(*$3), true, $5, $7); D1($3); }
              | T_IDENTIFIER                                            { SP(@1); declare_var(M(*$1));               D1($1); }
              | T_IDENTIFIER '(' T_NUM ':' T_NUM ')'                    { SP(@1); declare_var(M(*$1), true, $3, $5); D1($1); }
;
commands:     commands command                                          { $$ = $1; $$->append($2); }
              | command                                                 { $$ = new IBlock(); $$->append($1); }
;
command:      lvalue T_ASSIGN expression ';'                            { SP(@1); $1->sanitize(true); $$ = new IAssign(M(*$1), M(*$3)); D2($1, $3); }
              | T_IF condition T_THEN commands T_ELSE commands T_ENDIF  { $$ = new IIf(M(*$2), M(*$4), M(*$6)); D3($2, $4, $6); }
              | T_IF condition T_THEN commands T_ENDIF                  { $$ = new IIf(M(*$2), M(*$4));         D2($2, $4); }
              | T_WHILE condition T_DO commands T_ENDWHILE              { $$ = new IWhile(M(*$2), M(*$4));   D2($2, $4); }
              | T_DO commands T_WHILE condition T_ENDDO                 { $$ = new IDoWhile(M(*$4), M(*$2)); D2($2, $4); }
              | T_FOR T_IDENTIFIER T_FROM value                         { SP(@4); $4->sanitize(); }
                    T_TO value                                          { SP(@7); $7->sanitize(); SP(@2); push_iter(*$2); }
                    T_DO commands T_ENDFOR                              { $$ = new IFor(M(*$2), M(*$4), M(*$7), true,  M(*$10)); pop_iter(); D4($2, $4, $7, $10); }
              | T_FOR T_IDENTIFIER T_FROM value                         { SP(@4); $4->sanitize(); }
                    T_DOWNTO value                                      { SP(@7); $7->sanitize(); SP(@2); push_iter(*$2); }
                    T_DO commands T_ENDFOR                              { $$ = new IFor(M(*$2), M(*$4), M(*$7), false, M(*$10)); pop_iter(); D4($2, $4, $7, $10); }
              | T_READ lvalue ';'                                       { SP(@2); $2->sanitize(true); $$ = new IRead(M(*$2));  D1($2); }
              | T_WRITE value ';'                                       { SP(@2); $2->sanitize();     $$ = new IWrite(M(*$2)); D1($2); }
;
expression:   value                                                     { SP(@1); $1->sanitize();                         $$ = new IExpr(M(*$1),     {}, IExpr::Op::Val); D1($1); }
              | value T_PLUS value                                      { SP(@1); $1->sanitize(); SP(@3); $3->sanitize(); $$ = new IExpr(M(*$1), M(*$3), IExpr::Op::Add); D2($1, $3); }
              | value T_MINUS value                                     { SP(@1); $1->sanitize(); SP(@3); $3->sanitize(); $$ = new IExpr(M(*$1), M(*$3), IExpr::Op::Sub); D2($1, $3); }
              | value T_TIMES value                                     { SP(@1); $1->sanitize(); SP(@3); $3->sanitize(); $$ = new IExpr(M(*$1), M(*$3), IExpr::Op::Mul); D2($1, $3); }
              | value T_DIV value                                       { SP(@1); $1->sanitize(); SP(@3); $3->sanitize(); $$ = new IExpr(M(*$1), M(*$3), IExpr::Op::Div); D2($1, $3); }
              | value T_MOD value                                       { SP(@1); $1->sanitize(); SP(@3); $3->sanitize(); $$ = new IExpr(M(*$1), M(*$3), IExpr::Op::Mod); D2($1, $3); }
;
condition:    value T_EQ value                                          { SP(@1); $1->sanitize(); SP(@3); $3->sanitize(); $$ = new Cond{ .a=M(*$1), .b=M(*$3), .op=Cond::Op::Eq  }; D2($1, $3); }
              | value T_NEQ value                                       { SP(@1); $1->sanitize(); SP(@3); $3->sanitize(); $$ = new Cond{ .a=M(*$1), .b=M(*$3), .op=Cond::Op::Neq }; D2($1, $3); }
              | value T_LE value                                        { SP(@1); $1->sanitize(); SP(@3); $3->sanitize(); $$ = new Cond{ .a=M(*$1), .b=M(*$3), .op=Cond::Op::Le  }; D2($1, $3); }
              | value T_GE value                                        { SP(@1); $1->sanitize(); SP(@3); $3->sanitize(); $$ = new Cond{ .a=M(*$1), .b=M(*$3), .op=Cond::Op::Ge  }; D2($1, $3); }
              | value T_LEQ value                                       { SP(@1); $1->sanitize(); SP(@3); $3->sanitize(); $$ = new Cond{ .a=M(*$1), .b=M(*$3), .op=Cond::Op::Leq }; D2($1, $3); }
              | value T_GEQ value                                       { SP(@1); $1->sanitize(); SP(@3); $3->sanitize(); $$ = new Cond{ .a=M(*$1), .b=M(*$3), .op=Cond::Op::Geq }; D2($1, $3); }
;
value:        T_NUM                                                     { $$ = new Value{ .type=Value::Type::Number, .num=$1}; }
              | lvalue                                                  { $$ = $1; }
;
lvalue:       T_IDENTIFIER                                              { $$ = new Value{ .type=Value::Type::Variable, .str=M(*$1) };                D1($1); }
              | T_IDENTIFIER '(' T_IDENTIFIER ')'                       { $$ = new Value{ .type=Value::Type::ArrayV, .str=M(*$1), .off_var=M(*$3) }; D2($1, $3); }
              | T_IDENTIFIER '(' T_NUM ')'                              { $$ = new Value{ .type=Value::Type::ArrayN, .str=M(*$1), .off_num=$3 };     D1($1); }
;
%%
