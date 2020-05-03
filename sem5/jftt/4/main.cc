#include "main.hh"
#include "asm.hh"
#include "instr.hh"
#include "input.hh"

int yyparse();

Args args;

std::map<std::string, Var> var_tab;
std::vector<std::string> iter_tab;
i64 iter_max = 0;
i64 cell = 2;

IBlock code;

void declare_var(std::string name, bool array, i64 from, i64 to) {
    if (var_tab.find(name) != var_tab.end()) {
        error("redeclaration of ", name);
    }

    if (!array) {
        var_tab[name] = {};
        //log("declaring var: ", name);
    } else {
        i64 rng = to - from + 1;
        if (rng < 1) {
            error("invalid range for array ", name);
        }
        var_tab[name] = { .array=true, .from=from, .range=rng };
        //log("ceclaring array: ", name, ", from = ", from, ", range = ", rng);
    }
}

void assign_var_mem_cells() {
    for (auto &v:var_tab) {
        if (v.second.array) {
            continue;
        }

        v.second.cell = cell++;
    }

    for (auto &v:var_tab) {
        if (!v.second.array) {
            continue;
        }

        v.second.cell = cell - v.second.from;
        cell += v.second.range;
    }
}

void dump_var_tab(std::ostream &os) {
    os << "# [Variables]\n";
    for (const auto &v:var_tab) {
        if (v.second.array) {
            continue;
        }
        os << "#  \'" << v.first << "\': cell = " << v.second.cell << '\n';
    }

    for (auto &v:var_tab) {
        if (!v.second.array) {
            continue;
        }
        os << "#  \'" << v.first << "\': [" << v.second.from << "; " << v.second.range <<
           "]: cells = " << (v.second.cell + v.second.from) << ".."
           << (v.second.cell + v.second.range + v.second.from - 1)
           << ", start = " << v.second.cell << '\n';
    }
}

i64 curlbl = 0;

i64 getlbl() {
    return curlbl++;
}

int yyerror(const char *s) {
    syntaxerror(s + 14);
    return 1;
}

int main(int argc, char *argv[]) {


    args.parse(argc, argv);
    //std::cout << "Hello, World!" << std::endl;
    std::cerr << std::boolalpha;

    input::open();
    yyparse();

    std::vector<Symbol> sasm;
    size_t sz = code.assemble(sasm, false);

    input::invalppos();
    for (const auto&[k, v]:var_tab) {
        if (!v.array && !v.initialised) {
            warning("unused variable ", k);
        }
    }

    //std::cerr << "sasm.size(): " << sasm.size() << ", sz: " << sz << '\n';
    //dump_assembler(sasm);

    std::ofstream outf(args.ofname);
    if (!outf.is_open()) {
        fatal("cannot open output file: ", args.ofname, '\n');
    }

    outf << "# -*- mgasm -*- \n";
    assign_var_mem_cells();
    dump_var_tab(outf);
    outf << "# [Program]\n";
    process(outf, sasm);

    return 0;
}
