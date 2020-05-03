#pragma once

#include "main.hh"
#include "asm.hh"

extern i64 cur_lbl;
i64 getlbl();

struct Value {
    enum class Type {
        Number,
        Variable,
        ArrayN,
        ArrayV,
        Iter
    } type;
    std::string str, off_var;
    i64 num = 0, off_num = 0;

    void sanitize(bool lvalue = false) {
        if (type == Type::Variable && std::find(iter_tab.begin(), iter_tab.end(), str) != iter_tab.end()) {
            type = Type::Iter;
        }

        if (lvalue) {
            if (!is_lvalue()) {
                error("unexpected rvalue in assignment");
            } else {
                if (var_tab.find(str) != var_tab.end()) {
                    var_tab[str].initialised = true;
                }
            }
        }

        switch (type) {
            case Type::Number: {
                break;
            }

            case Type::Variable: {
                if (var_tab.find(str) == var_tab.end()) {
                    error(str, " is not declared");
                } else if (var_tab[str].array) {
                    error(str, " is an array");
                } else if (!var_tab[str].initialised) {
                    warning("use of possibly uninitialised variable ", str);
                    var_tab[str].initialised = true;
                }
                break;
            }

            case Type::ArrayN: {
                if (var_tab.find(str) == var_tab.end()) {
                    error(str, " is not declared");
                } else if (!var_tab[str].array) {
                    error(str, " is not an array");
                } else if (off_num < var_tab[str].from || off_num > var_tab[str].from + var_tab[str].range - 1) {
                    warning("array index out of range");
                }
                break;
            }

            case Type::ArrayV: {
                if (var_tab.find(str) == var_tab.end()) {
                    error(str, " is not declared");
                } else if (!var_tab[str].array) {
                    error(str, " is not an array");
                } else if (var_tab.find(off_var) != var_tab.end()) {
                    if (var_tab[off_var].array) {
                        error("array index ", off_var, " is an array");
                    } else if (!var_tab[off_var].initialised) {
                        warning("use of possibly uninitialised variable ", off_var);
                        var_tab[off_var].initialised = true;
                    }
                } else if (std::find(iter_tab.begin(), iter_tab.end(), off_var) == iter_tab.end()) {
                    error("array index ", off_var, " is not declared");
                }
                break;
            }

            case Type::Iter: {
                break;
            }
        }
    }

    bool is_array() const { return type == Type::ArrayN || type == Type::ArrayV; }

    bool is_lvalue() const { return type != Type::Number && type != Type::Iter; }
};

class Instr {
public:
    enum class Type {
        Null,
        Block,
        Expr,
        Assign,
        If,
        While,
        DoWhile,
        For
    };

    virtual ~Instr() = default;

    virtual Type type() const {
        return Type::Null;
    }

    virtual size_t assemble(std::vector<Symbol> &s, bool det) = 0;
};

struct Cond {
    enum class Op {
        Eq, Neq, Le, Ge, Leq, Geq
    };

    Value a, b;
    Op op;
};

namespace {
    bool iter_exists(const std::string &name) {
        return std::find(iter_tab.begin(), iter_tab.end(), name) != iter_tab.end();
    }

    i64 push_iter(const std::string &name) {
        if (var_tab.find(name) != var_tab.end() || iter_exists(name)) {
            error("redeclaration of ", name);
        }

        iter_tab.emplace_back(name);
        if (iter_tab.size() * 2 > iter_max) {
            iter_max = iter_tab.size() * 2;
        }
        return (iter_tab.size() - 1) * 2;
    }

    void pop_iter() {
        iter_tab.pop_back();
    }

    i64 iter_index(const std::string &name) {
        return (std::find(iter_tab.begin(), iter_tab.end(), name) - iter_tab.begin()) * 2;
    }

    Symbol symbol_for_array_offset(const Value &a) {
        if (a.type == Value::Type::ArrayN) {
            return { .opcode=Symbol::Opcode::Add, .arg=Symbol::Arg::Number, .num=a.off_num };
        } else if (iter_exists(a.off_var)) {
            return { .opcode=Symbol::Opcode::Add, .arg=Symbol::Arg::Iter, .num=iter_index(a.off_var) };
        } else {
            return { .opcode=Symbol::Opcode::Add, .arg=Symbol::Arg::Variable, .str=a.off_var };
        }
    }

    size_t gen_comp_jumps(std::vector<Symbol> &s, Cond::Op op, i64 lbl, bool invert = true) {
        size_t sz = 0;

        auto jeq = [&]() {
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::JZero, .arg=Symbol::Arg::Label, .num=lbl });
            sz++;
        };

        auto jneq = [&]() {
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::JPos, .arg=Symbol::Arg::Label, .num=lbl });
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::JNeg, .arg=Symbol::Arg::Label, .num=lbl });
            sz += 2;
        };

        auto jge = [&]() {
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::JPos, .arg=Symbol::Arg::Label, .num=lbl });
            sz++;
        };

        auto jle = [&]() {
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::JNeg, .arg=Symbol::Arg::Label, .num=lbl });
            sz++;
        };

        auto jgeq = [&]() {
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::JPos, .arg=Symbol::Arg::Label, .num=lbl });
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::JZero, .arg=Symbol::Arg::Label, .num=lbl });
            sz += 2;
        };

        auto jleq = [&]() {
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::JNeg, .arg=Symbol::Arg::Label, .num=lbl });
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::JZero, .arg=Symbol::Arg::Label, .num=lbl });
            sz += 2;
        };

        if (!invert) {
            switch (op) {
                case Cond::Op::Eq: jeq();
                    break;
                case Cond::Op::Neq: jneq();
                    break;
                case Cond::Op::Le: jle();
                    break;
                case Cond::Op::Ge: jge();
                    break;
                case Cond::Op::Leq: jleq();
                    break;
                case Cond::Op::Geq: jgeq();
                    break;
            }
        } else {
            switch (op) {
                case Cond::Op::Eq: jneq();
                    break;
                case Cond::Op::Neq: jeq();
                    break;
                case Cond::Op::Le: jgeq();
                    break;
                case Cond::Op::Ge: jleq();
                    break;
                case Cond::Op::Leq: jge();
                    break;
                case Cond::Op::Geq: jle();
                    break;
            }
        }

        return sz;
    }

    size_t assignment_gen_symbols_pre(std::vector<Symbol> &s, const Value &lvalue) {
        if (lvalue.type == Value::Type::ArrayV) {
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Load, .arg=Symbol::Arg::Address, .str=lvalue.str });
            s.emplace_back(symbol_for_array_offset(lvalue));
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Store, .arg=Symbol::Arg::Temp, .num=0 });
            return 3;
        } else {
            return 0;
        }
    }

    size_t assignment_gen_symbols_post(std::vector<Symbol> &s, const Value &lvalue) {
        if (!lvalue.is_array()) {
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Store, .arg=Symbol::Arg::Variable, .str=lvalue.str });
        } else if (lvalue.type == Value::Type::ArrayN) {
            s.emplace_back(Symbol{
                    .opcode=Symbol::Opcode::Store, .arg=Symbol::Arg::Variable, .str=lvalue.str, .offset=lvalue.off_num
            });
        } else {
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::StoreI, .arg=Symbol::Arg::Temp, .num=0 });
        }
        return 1;
    }

    size_t access_gen_symbols(std::vector<Symbol> &s, const Value &v) {
        size_t sz = 0;
        switch (v.type) {
            case Value::Type::Number: {
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Load, .arg=Symbol::Arg::Number, .num =v.num });
                sz++;
                break;
            }
            case Value::Type::Variable: {
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Load, .arg=Symbol::Arg::Variable, .str=v.str });
                sz++;
                break;
            }
            case Value::Type::ArrayN: {
                s.emplace_back(Symbol{
                        .opcode=Symbol::Opcode::Load, .arg=Symbol::Arg::Variable, .str=v.str, .offset=v.off_num
                });
                sz++;
                break;
            };
            case Value::Type::ArrayV: {
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Load, .arg=Symbol::Arg::Address, .str=v.str });
                s.emplace_back(symbol_for_array_offset(v));
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::LoadI, .arg=Symbol::Arg::Cell, .num=0 });
                sz += 3;
                break;
            }
            case Value::Type::Iter: {
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Load, .arg=Symbol::Arg::Iter, .num=iter_index(v.str) });
                sz++;
                break;
            }
        }
        return sz;
    }
}

class IBlock : public Instr {
    std::vector<std::unique_ptr<Instr>> code;

public:
    IBlock() = default;

    explicit IBlock(std::vector<std::unique_ptr<Instr>> code) : code{ std::move(code) } {}

    Type type() const override {
        return Type::Block;
    }

    size_t assemble(std::vector<Symbol> &s, bool det) override {
        size_t sz = 0;
        for (auto &c:code) {
            sz += c->assemble(s, det);
        }
        return sz;
    };

    void append(std::unique_ptr<Instr> i) {
        code.emplace_back(std::move(i));
    }

    void append(Instr *i) {
        std::unique_ptr<Instr> p(i);
        code.emplace_back(std::move(p));
    }

    bool is_empty() const { return code.empty(); }
};

class IExpr : public Instr {
public:
    enum class Op {
        Val, Add, Sub, Mul, Div, Mod
    };

private:
    Op op;
    Value a, b;

public:
    IExpr(Value a, Value b, Op op) : a{ std::move(a) }, b{ std::move(b) }, op{ op } {}

    Type type() const override {
        return Type::Expr;
    }

    size_t assemble(std::vector<Symbol> &s, bool det) override;

};

class IAssign : public Instr {
    Value lvalue;
    IExpr rvalue;

public:
    IAssign(Value lvalue, IExpr rvalue) : lvalue{ std::move(lvalue) }, rvalue{ std::move(rvalue) } {}

    Type type() const override {
        return Type::Assign;
    }

    size_t assemble(std::vector<Symbol> &s, bool det) override {
        size_t sz = 0;
        sz += assignment_gen_symbols_pre(s, lvalue);
        sz += rvalue.assemble(s, det);
        sz += assignment_gen_symbols_post(s, lvalue);
        return sz;
    };

};

class IIf : public Instr {
public:
    Cond cond;
    IBlock on_true, on_false;

public:
    IIf(Cond cond, IBlock on_true, IBlock on_false = {})
            : cond{ std::move(cond) }, on_true{ std::move(on_true) }, on_false{ std::move(on_false) } {}

    Type type() const override {
        return Type::If;
    }

    size_t assemble(std::vector<Symbol> &s, bool det) override {
        size_t sz = 0;
        i64 lbl_else = getlbl(), lbl_endif = getlbl();

        sz += IExpr(cond.a, cond.b, IExpr::Op::Sub).assemble(s, det);
        sz += gen_comp_jumps(s, cond.op, lbl_else);

        sz += on_true.assemble(s, false);
        if (!on_false.is_empty()) {
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Jump, .arg=Symbol::Arg::Label, .num=lbl_endif });
            sz++;
        }
        s.emplace_back(Symbol{ .opcode=Symbol::Opcode::NoOp, .arg=Symbol::Arg::Label, .num=lbl_else });
        if (!on_false.is_empty()) {
            sz += on_false.assemble(s, false);
        }
        s.emplace_back(Symbol{ .opcode=Symbol::Opcode::NoOp, .arg=Symbol::Arg::Label, .num=lbl_endif });
        return sz + 2;
    };
};

class IRead : public Instr {
    Value v;

public:
    IRead(Value v) : v{ std::move(v) } {}

    Type type() const override {
        return Type::Assign;
    }

    size_t assemble(std::vector<Symbol> &s, bool det) override {
        size_t sz = 0;
        sz += assignment_gen_symbols_pre(s, v);
        s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Get });
        sz += assignment_gen_symbols_post(s, v);
        return sz + 1;
    };

};

class IWrite : public Instr {
    Value v;

public:
    IWrite(Value v) : v{ std::move(v) } {}

    Type type() const override {
        return Type::Assign;
    }

    size_t assemble(std::vector<Symbol> &s, bool det) override {
        size_t sz = 0;
        sz += access_gen_symbols(s, v);
        s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Put });
        return sz + 1;
    };

};

class IWhile : public Instr {
public:
    Cond cond;
    IBlock code;

public:
    IWhile(Cond cond, IBlock code) : cond{ std::move(cond) }, code{ std::move(code) } {}

    Type type() const override {
        return Type::While;
    }

    size_t assemble(std::vector<Symbol> &s, bool det) override {
        size_t sz = 0;
        i64 lbl_start = getlbl(), lbl_end = getlbl();
        s.emplace_back(Symbol{ .opcode=Symbol::Opcode::NoOp, .arg=Symbol::Arg::Label, .num=lbl_start });
        sz += IExpr(cond.a, cond.b, IExpr::Op::Sub).assemble(s, det);

        sz += gen_comp_jumps(s, cond.op, lbl_end);

        sz += code.assemble(s, false);
        s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Jump, .arg=Symbol::Arg::Label, .num=lbl_start });
        s.emplace_back(Symbol{ .opcode=Symbol::Opcode::NoOp, .arg=Symbol::Arg::Label, .num=lbl_end });
        return sz + 3;
    };
};

class IDoWhile : public Instr {
public:
    Cond cond;
    IBlock code;

public:
    IDoWhile(Cond cond, IBlock code) : cond{ std::move(cond) }, code{ std::move(code) } {}

    Type type() const override {
        return Type::DoWhile;
    }

    size_t assemble(std::vector<Symbol> &s, bool det) override {
        size_t sz = 0;
        i64 lbl_start = getlbl();
        s.emplace_back(Symbol{ .opcode=Symbol::Opcode::NoOp, .arg=Symbol::Arg::Label, .num=lbl_start });
        sz += code.assemble(s, false);
        sz += IExpr(cond.a, cond.b, IExpr::Op::Sub).assemble(s, det);

        sz += gen_comp_jumps(s, cond.op, lbl_start, false);

        return sz + 1;
    };
};

class IFor : public Instr {
public:
    std::string iter_name;
    Value from, to;
    bool incr;
    IBlock code;

public:
    IFor(std::string iter_name, Value from, Value to, bool incr, IBlock code) :
            iter_name{ std::move(iter_name) }, from{ std::move(from) }, to{ std::move(to) },
            incr{ incr }, code{ std::move(code) } {}

    Type type() const override {
        return Type::For;
    }

    size_t assemble(std::vector<Symbol> &s, bool det) override {
        size_t sz = 0;
        i64 lbl_start = getlbl(), lbl_end = getlbl();
        i64 iter_idx = push_iter(iter_name);
        Value iter = { .type=Value::Type::Iter, .str=iter_name };

        sz += access_gen_symbols(s, to);
        s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Store, .arg=Symbol::Arg::Iter, .num=iter_idx + 1 });
        sz++;

        sz += access_gen_symbols(s, from);
        s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Store, .arg=Symbol::Arg::Iter, .num=iter_idx });
        sz++;

        s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Load, .arg=Symbol::Arg::Iter, .num=iter_idx });
        s.emplace_back(Symbol{ .opcode=Symbol::Opcode::NoOp, .arg=Symbol::Arg::Label, .num=lbl_start });
        s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Sub, .arg=Symbol::Arg::Iter, .num=iter_idx + 1 });

        if (incr) {
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::JPos, .arg=Symbol::Arg::Label, .num=lbl_end });
        } else {
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::JNeg, .arg=Symbol::Arg::Label, .num=lbl_end });
        }

        sz += 4;

        sz += code.assemble(s, false);
        s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Load, .arg=Symbol::Arg::Iter, .num=iter_idx });
        if (incr) {
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Inc });
        } else {
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Dec });
        }
        s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Store, .arg=Symbol::Arg::Iter, .num=iter_idx });
        s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Jump, .arg=Symbol::Arg::Label, .num=lbl_start });
        s.emplace_back(Symbol{ .opcode=Symbol::Opcode::NoOp, .arg=Symbol::Arg::Label, .num=lbl_end });
        sz += 5;
        pop_iter();
        return sz;
    };
};