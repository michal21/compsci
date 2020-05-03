#include "asm.hh"

static std::map<Symbol::Opcode, std::string> sym_names = {
        { Symbol::Opcode::NoOp,   "NOOP   " },
        { Symbol::Opcode::Get,    "GET    " },
        { Symbol::Opcode::Put,    "PUT    " },
        { Symbol::Opcode::Load,   "LOAD   " },
        { Symbol::Opcode::Store,  "STORE  " },
        { Symbol::Opcode::LoadI,  "LOADI  " },
        { Symbol::Opcode::StoreI, "STOREI " },
        { Symbol::Opcode::Add,    "ADD    " },
        { Symbol::Opcode::Sub,    "SUB    " },
        { Symbol::Opcode::Shift,  "SHIFT  " },
        { Symbol::Opcode::Inc,    "INC    " },
        { Symbol::Opcode::Dec,    "DEC    " },
        { Symbol::Opcode::Jump,   "JUMP   " },
        { Symbol::Opcode::JPos,   "JPOS   " },
        { Symbol::Opcode::JZero,  "JZERO  " },
        { Symbol::Opcode::JNeg,   "JNEG   " },
        { Symbol::Opcode::Halt,   "HALT   " }
};

void dump_assembler(const std::vector<Symbol> &sq) {
    for (const auto &s:sq) {
        if (s.opcode == Symbol::Opcode::NoOp) {
            if (s.arg == Symbol::Arg::Label) {
                // Label decl.
                std::cout << "# " << s.num << ":\n";
            }
            continue;
        }

        std::cout << sym_names[s.opcode];
        if (s.arg != Symbol::Arg::None) {
            switch (s.arg) {
                case Symbol::Arg::Cell:std::cout << s.num;
                    break;
                case Symbol::Arg::Number:std::cout << "Num[" << s.num;
                    break;
                case Symbol::Arg::Variable:std::cout << "Var[" << s.str;
                    break;
                case Symbol::Arg::Address:std::cout << "Adr[" << s.str;
                    break;
                case Symbol::Arg::Iter:std::cout << "Itr[" << s.num;
                    break;
                case Symbol::Arg::Temp:std::cout << "Tmp[" << s.num;
                    break;
                case Symbol::Arg::Label:std::cout << "Lbl[" << s.num;
                    break;
            }
            if (s.offset != 0) {
                std::cout << " + " << s.offset;
            }
            if (s.arg != Symbol::Arg::Cell) {
                std::cout << ']';
            }
        }
        std::cout << '\n';
    }
}

void process(std::ostream &os, std::vector<Symbol> sq) {
    std::map<i64, i64> num_literals;

    std::map<i64, i64> labels;
    std::vector<i64> jlist;
    i64 instr_cnt = 0;

    for (auto &s:sq) {
        if (s.opcode == Symbol::Opcode::NoOp) {
            if (s.arg == Symbol::Arg::Label) {
                // Label decl.
                labels[s.num] = instr_cnt;
                jlist.emplace_back(instr_cnt);
            }
            continue;
        }

        if (s.opcode == Symbol::Opcode::Load && s.arg == Symbol::Arg::Number && s.num == 0) {
            s = Symbol{ .opcode = Symbol::Opcode::Sub, s.arg = Symbol::Arg::Cell, .num = 0 };
        }

        if (s.arg != Symbol::Arg::None) {
            switch (s.arg) {
                case Symbol::Arg::Number:num_literals[s.num] = 0;
                    break;
                case Symbol::Arg::Address:num_literals[var_tab[s.str].cell] = 0;
                    break;
            }
        }
        instr_cnt++;
    }

    // Hackish solution to fix the 'STORE n, LOAD n' nonsense
    instr_cnt = 0;
    Symbol prev_instr;
    for (auto &s:sq) {
        if (s.opcode != Symbol::Opcode::NoOp) {
            if (std::find(jlist.begin(), jlist.end(), instr_cnt) == jlist.end()
                && prev_instr.opcode == Symbol::Opcode::Store
                && s.opcode == Symbol::Opcode::Load
                && s.mem_index_equal(prev_instr)) {
                s.opcode = Symbol::Opcode::NoOp;
                s.arg = Symbol::Arg::None;
            } else {
                prev_instr = s;
            }
            instr_cnt++;
        }
    }

    // Repair instr counts
    instr_cnt = 0;
    for (const auto &s:sq) {
        if (s.opcode == Symbol::Opcode::NoOp) {
            if (s.arg == Symbol::Arg::Label) {
                labels[s.num] = instr_cnt;
            }
            continue;
        }
        instr_cnt++;
    }

    instr_cnt = 3;
    os << "SUB    0\n"
       << "INC\n"
       << "STORE  1 # =1\n"
       << "# [Literal gen]\n";

    i64 cell_num = cell;
    for (auto &nl:num_literals) {
        if (nl.first == 1) {
            nl.second = 1;
            continue;
        }

        os << "SUB    0\n";
        instr_cnt++;
        i64 n = nl.first;
        if (n < 0) {
            n = -n;
        }
        bool b = false;
        for (i64 i = 62; i >= 0; i--) {
            if (b) {
                os << "SHIFT  1\n";
                instr_cnt++;
            }
            if (((n >> i) & 1) == 1) {
                os << "INC\n";
                instr_cnt++;
                b = true;
            }
        }
        num_literals[nl.first] = cell_num;
        if (nl.first >= 0) {
            os << "STORE  " << cell_num++ << " # =" << n << '\n';
            instr_cnt++;
        } else {
            os << "STORE  " << cell_num << " # =" << n << '\n';
            os << "SUB    0\n";
            os << "SUB    " << cell_num << '\n';
            os << "STORE  " << cell_num++ << " # =" << -n << '\n';
            instr_cnt += 4;
        }
    }
    //os << "# Instr count: " << instr_cnt << '\n';
    os << "# [Code]\n";

    // Reserve block for iterators
    i64 iter_base = cell_num;
    cell_num += iter_max;

    for (auto &lbl:labels) {
        lbl.second += instr_cnt;
    }

    for (const auto &s:sq) {
        if (s.opcode == Symbol::Opcode::NoOp) {
            if (s.arg == Symbol::Arg::Label) {
                os << "# " << s.num << ":\n";
            }
            continue;
        }

        os << sym_names[s.opcode];
        if (s.arg != Symbol::Arg::None) {
            switch (s.arg) {
                case Symbol::Arg::Cell: os << (s.num + s.offset);
                    break;
                case Symbol::Arg::Number: os << (num_literals[s.num] + s.offset) << " # " << s.num;
                    break;
                case Symbol::Arg::Variable: os << (var_tab[s.str].cell + s.offset) << " # " << s.str;
                    break;
                case Symbol::Arg::Address: os << (num_literals[var_tab[s.str].cell] + s.offset) << " # &" << s.str;
                    break;
                case Symbol::Arg::Iter: os << (iter_base + s.num + s.offset) << " # i" << s.num;
                    break;
                case Symbol::Arg::Temp: os << (cell_num + s.num + s.offset) << " # $" << s.num;
                    break;
                case Symbol::Arg::Label: os << (labels[s.num] + s.offset) << " # " << s.num << ':';
                    break;
            }
            if (s.offset != 0) {
                if (s.arg == Symbol::Arg::Cell) {
                    os << " #";
                }
                if (s.offset > 0) {
                    os << " + " << s.offset;
                } else {
                    os << " - " << (-s.offset);
                }
            }
        }
        os << '\n';
    }

    os << "HALT\n";
}
