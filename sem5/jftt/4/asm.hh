#pragma once

#include "main.hh"

struct Symbol {
    enum class Opcode {
        NoOp,
        Get, Put,
        Load, Store,
        LoadI, StoreI,
        Add, Sub, Shift,
        Inc, Dec,
        Jump,
        JPos, JZero, JNeg,
        Halt
    } opcode = Opcode::NoOp;

    enum class Arg {
        None,
        Cell,
        Number,
        Variable,
        Address,
        Iter,
        Temp,
        Label
    } arg = Arg::None;
    std::string str;
    i64 num = 0, offset = 0;

    bool mem_index_equal(const Symbol &o) {
        if (arg != o.arg) {
            return false;
        }

        switch (arg) {
            case Symbol::Arg::Cell: return num + offset == o.num + o.offset;
            case Symbol::Arg::Number: return num == o.num && offset == o.offset;
            case Symbol::Arg::Variable: return str == o.str && offset == o.offset;
            case Symbol::Arg::Address: return str == o.str && offset == o.offset;
            case Symbol::Arg::Iter: return num + offset == o.num + o.offset;
            case Symbol::Arg::Temp: return num + offset == o.num + o.offset;
            case Symbol::Arg::Label: return num + offset == o.num + o.offset;
            default: return false;
        }
    }
};

void dump_assembler(const std::vector<Symbol> &sq);
void process(std::ostream &os, std::vector<Symbol> sq);