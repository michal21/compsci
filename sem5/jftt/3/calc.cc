#include <iostream>
#include <string>
#include <sstream>
#include <cstdio>
extern "C" {
#include <readline/readline.h>
#include <readline/history.h>
}
#define YY_NULL (0)
extern FILE *yyin;
int yyparse();
extern std::stringstream repr;
extern bool err;

void fin(int v) {
    if (!err) {
        std::cout << "»" << repr.str() << "\n= " << v << '\n'
                  << std::endl;
    } else {
        std::cerr << "! Input error\n\n";
    }
    repr.str("");
    err = false;
}

int mygetinput(char *buf, int size) {
    char *line = NULL, *prompt = "> ";
    int len = 0;
    if (feof(yyin)) {
        return YY_NULL;
    }
    do {
        if (line != NULL) {
            free(line);
        }
        if ((line = readline(prompt)) == NULL) {
            return YY_NULL;
        }
        if (len + strlen(line) > size - 2) {
            std::cerr << "! Input too long\n\n";
            free(line);
            buf[0] = '\n';
            buf[1] = '\0';
            return 1;
        }
        std::sprintf(buf + len, "%s\n", line);
        len += strlen(line) - 1;
        prompt = "^ ";
    } while (line[strlen(line) - 1] == '\\');
    buf[len + 1] = '\0';
    add_history(buf);
    buf[len + 1] = '\n';
    return strlen(buf);
}

int yyerror(char *s) {
    return 0;
}

int main() {
    yyparse();
    return 0;
}
