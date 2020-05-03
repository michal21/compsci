#include "input.hh"
#include "tokens.hh"

namespace input {
    std::ifstream inf;
    std::string line, pline;
    int linepos = -1;

    int lineno = 0, lineoff = 0, plineno = 0, ylineno = 0, ylineoff = 0;

    void open() {
        inf = std::ifstream(args.ifname);
        if (!inf.is_open()) {
            fatal("cannot open output file: ", args.ifname, '\n');
        }
    }

    int getchars(char *buf, int buflen) {
        pline = line;
        plineno = lineno;
        if (linepos == -1 || linepos == line.length()) {
            do {
                if (inf.eof()) {
                    return 0;
                }
                std::getline(inf, line);
                lineno++;
            } while (line.empty());

            size_t pos;
            while ((pos = line.find('\t')) != std::string::npos) {
                line.replace(pos, 1, "    ");
            }

            linepos = 0;
            ylineoff = lineoff;
            lineoff = 0;

            yylloc.first_column = 0;
            yylloc.first_line = lineno;
        }

        int len = std::min(static_cast<int>(line.length()) - linepos, buflen);
        std::memcpy(buf, line.c_str() + linepos, static_cast<size_t>(len));
        linepos += len;
        return len;
    }

    void offset(int off) {
        //std::cerr << "offset(" << off << ", \"" << str << "\")\n";
        yylloc.first_column = lineoff;
        lineoff += off;
    }

    std::pair<int, int> textpos() {
        return { lineno, lineoff };
    }

    std::pair<int, int> ptextpos() {
        return { ylineno, ylineoff };
    }

    void setppos(const YYLTYPE &yyltype) {
        ylineno = yyltype.first_line;
        ylineoff = yyltype.first_column + 1;
    }

    void invalppos() {
        ylineno = -1;
        ylineoff = -1;
    }

    std::optional<std::string> linefornum(int lno) {
        if (lno == lineno) {
            return line;
        } else if (lno == plineno) {
            return pline;
        } else {
            return {};
        }
    }
}
