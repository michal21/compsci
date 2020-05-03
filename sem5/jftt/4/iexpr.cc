#include "instr.hh"

size_t IExpr::assemble(std::vector<Symbol> &s, bool det) {
    size_t sz = 0;
    // If b is array access then bind it to temporary
    if (op != Op::Val && b.type == Value::Type::ArrayV) {
        s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Load, .arg=Symbol::Arg::Address, .str=b.str });
        s.emplace_back(symbol_for_array_offset(b));
        s.emplace_back(Symbol{ .opcode=Symbol::Opcode::LoadI, .arg=Symbol::Arg::Cell, .num=0 });
        s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Store, .arg=Symbol::Arg::Temp, .num=1 });
        sz += 4;
    }

    auto opcode_b = [&](Symbol::Opcode opcode) {
        switch (b.type) {
            case Value::Type::Number: {
                s.emplace_back(Symbol{ .opcode=opcode, .arg=Symbol::Arg::Number, .num =b.num });
                break;
            }
            case Value::Type::Variable: {
                s.emplace_back(Symbol{ .opcode=opcode, .arg=Symbol::Arg::Variable, .str=b.str });
                break;
            }
            case Value::Type::ArrayN: {
                s.emplace_back(Symbol{ .opcode=opcode, .arg=Symbol::Arg::Variable, .str=b.str, .offset=b.off_num });
                break;
            }
            case Value::Type::ArrayV: {
                s.emplace_back(Symbol{ .opcode=opcode, .arg=Symbol::Arg::Temp, .num=1 });
                break;
            }
            case Value::Type::Iter: {
                s.emplace_back(Symbol{ .opcode=opcode, .arg=Symbol::Arg::Iter, .num=iter_index(b.str) });
                break;
            }
        }
        sz++;
    };

    switch (op) {
        case Op::Val: {
            sz += access_gen_symbols(s, a);
            break;
        }

        case Op::Add: {
            auto add = [&](i64 num) {
                if (num >= 0 && num < 10) {
                    for (int i = 0; i < num; i++) {
                        s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Inc });
                        sz++;
                    }
                } else if (num < 0 && num > -10) {
                    for (int i = 0; i < -num; i++) {
                        s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Dec });
                        sz++;
                    }
                } else {
                    s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Add, .arg=Symbol::Arg::Number, .num=num });
                    sz++;
                }
            };

            if (a.type == Value::Type::Number && b.type == Value::Type::Number) {
                i64 res, sn = std::min(a.num, b.num), ln = std::max(a.num, b.num);
                if (__builtin_add_overflow(a.num, b.num, &res) == 0) {
                    s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Load, .arg=Symbol::Arg::Number, .num=res });
                } else {
                    s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Load, .arg=Symbol::Arg::Number, .num=ln });
                    add(sn);
                }
                sz++;
            } else if (a.type == Value::Type::Number && b.type != Value::Type::Number) {
                opcode_b(Symbol::Opcode::Load);
                add(a.num);
            } else if (a.type != Value::Type::Number && b.type == Value::Type::Number) {
                sz += access_gen_symbols(s, a);
                add(b.num);
            } else {
                sz += access_gen_symbols(s, a);
                opcode_b(Symbol::Opcode::Add);
            }
            break;
        }

        case Op::Sub: {
            auto sub = [&](i64 num) {
                if (num >= 0 && num < 10) {
                    for (int i = 0; i < num; i++) {
                        s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Dec });
                        sz++;
                    }
                } else if (num < 0 && num > -10) {
                    for (int i = 0; i < -num; i++) {
                        s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Inc });
                        sz++;
                    }
                } else {
                    s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Sub, .arg=Symbol::Arg::Number, .num=num });
                    sz++;
                }
            };

            if (a.type == Value::Type::Number && b.type == Value::Type::Number) {
                i64 res;
                if (__builtin_sub_overflow(a.num, b.num, &res) == 0) {
                    s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Load, .arg=Symbol::Arg::Number, .num=res });
                } else {
                    s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Load, .arg=Symbol::Arg::Number, .num=a.num });
                    sub(b.num);
                }
                sz++;
            } else if (a.type != Value::Type::Number && b.type == Value::Type::Number) {
                sz += access_gen_symbols(s, a);
                sub(b.num);
            } else {
                sz += access_gen_symbols(s, a);
                opcode_b(Symbol::Opcode::Sub);
            }
            break;
        }

        case Op::Mul: {

            /*if (i64 res; a.type == Value::Type::Number && b.type == Value::Type::Number &&
                         __builtin_mul_overflow(a.num, b.num, &res) == 0) {
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Load, .arg=Symbol::Arg::Number, .num=res });
                sz++;
            } else if (auto lga = std::log2(a.num); a.type == Value::Type::Number &&
                                                    b.type != Value::Type::Number && int(lga) == lga) {
                opcode_b(Symbol::Opcode::Load);
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Shift, .arg=Symbol::Arg::Number, .num=int(lga) });
                sz++;
            } else if (auto lgb = std::log2(a.num); a.type != Value::Type::Number
                                                    && b.type == Value::Type::Number && int(lgb) == lgb) {
                sz += access_gen_symbols(s, a);
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Shift, .arg=Symbol::Arg::Number, .num=int(lgb) });
                sz++;
            } else {*/
            i64 n = 2, m = 3, c = 4, r = 5, neg = 6;
            i64 lbl_rend = getlbl(), lbl_nneg = getlbl(), lbl_nposmneg = getlbl(), lbl_nnegmneg = getlbl();

            auto mulbody = [&](i64 m, i64 n) {
                i64 lbl_loop = getlbl(), lbl_bit0 = getlbl(), lbl_finished = getlbl();

                // c = r = 0;
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Sub, .arg=Symbol::Arg::Cell, .num=0 });
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Store, .arg=Symbol::Arg::Temp, .num=c });
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Store, .arg=Symbol::Arg::Temp, .num=r });

                // beg of mul.c

                // loop:
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::NoOp, .arg=Symbol::Arg::Label, .num=lbl_loop });
                // if (m == 0) goto finished;
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Load, .arg=Symbol::Arg::Temp, .num=m });
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::JZero, .arg=Symbol::Arg::Label, .num=lbl_finished });
                // t0 = m >> 1;
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Shift, .arg=Symbol::Arg::Number, .num=-1 });
                //s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Store, .arg=Symbol::Arg::Temp, .num=t });
                // t1 = t0 << 1;
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Shift, .arg=Symbol::Arg::Number, .num=1 });

                // t1 -= m;
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Sub, .arg=Symbol::Arg::Temp, .num=m });
                // if (t1 == 0) goto bit_0;

                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::JZero, .arg=Symbol::Arg::Label, .num=lbl_bit0 });
                // t2 = n;
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Load, .arg=Symbol::Arg::Temp, .num=n });
                // t2 <<= c;
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Shift, .arg=Symbol::Arg::Temp, .num=c });
                // r += t2;
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Add, .arg=Symbol::Arg::Temp, .num=r });
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Store, .arg=Symbol::Arg::Temp, .num=r });

                // bit_0:
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::NoOp, .arg=Symbol::Arg::Label, .num=lbl_bit0 });
                // c++
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Load, .arg=Symbol::Arg::Temp, .num=c });
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Inc });
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Store, .arg=Symbol::Arg::Temp, .num=c });
                // m = t0
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Load, .arg=Symbol::Arg::Temp, .num=m });
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Shift, .arg=Symbol::Arg::Number, .num=-1 });
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Store, .arg=Symbol::Arg::Temp, .num=m });
                // goto loop;
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Jump, .arg=Symbol::Arg::Label, .num=lbl_loop });
                // finished:
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::NoOp, .arg=Symbol::Arg::Label, .num=lbl_finished });

                // end of mul.c

                sz += 23;
            };

            auto outerbody = [&] {
                i64 lbl_mles = getlbl(), lbl_obend = getlbl();

                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Sub, .arg=Symbol::Arg::Temp, .num=n });
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::JNeg, .arg=Symbol::Arg::Label, .num=lbl_mles });
                mulbody(n, m);
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Jump, .arg=Symbol::Arg::Label, .num=lbl_obend });

                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::NoOp, .arg=Symbol::Arg::Label, .num=lbl_mles });
                mulbody(m, n);
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::NoOp, .arg=Symbol::Arg::Label, .num=lbl_obend });

                sz += 5;
            };

            sz += access_gen_symbols(s, a);

            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::JZero, .arg=Symbol::Arg::Label, .num=lbl_rend });
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Store, .arg=Symbol::Arg::Temp, .num=n });
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::JNeg, .arg=Symbol::Arg::Label, .num=lbl_nneg });

            // n > 0
            opcode_b(Symbol::Opcode::Load);
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::JZero, .arg=Symbol::Arg::Label, .num=lbl_rend });
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Store, .arg=Symbol::Arg::Temp, .num=m });
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::JNeg, .arg=Symbol::Arg::Label, .num=lbl_nposmneg });
            // n > 0, m > 0
            outerbody();
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Load, .arg=Symbol::Arg::Temp, .num=r });
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Jump, .arg=Symbol::Arg::Label, .num=lbl_rend });

            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::NoOp, .arg=Symbol::Arg::Label, .num=lbl_nposmneg });
            // n > 0, m < 0
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Sub, .arg=Symbol::Arg::Cell, .num=0 });
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Sub, .arg=Symbol::Arg::Temp, .num=m });
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Store, .arg=Symbol::Arg::Temp, .num=m });
            outerbody();
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Sub, .arg=Symbol::Arg::Cell, .num=0 });
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Sub, .arg=Symbol::Arg::Temp, .num=r });
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Jump, .arg=Symbol::Arg::Label, .num=lbl_rend });

            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::NoOp, .arg=Symbol::Arg::Label, .num=lbl_nneg });
            // n < 0
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Sub, .arg=Symbol::Arg::Cell, .num=0 });
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Sub, .arg=Symbol::Arg::Temp, .num=n });
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Store, .arg=Symbol::Arg::Temp, .num=n });

            opcode_b(Symbol::Opcode::Load);
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::JZero, .arg=Symbol::Arg::Label, .num=lbl_rend });
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Store, .arg=Symbol::Arg::Temp, .num=m });
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::JNeg, .arg=Symbol::Arg::Label, .num=lbl_nnegmneg });
            // n < 0, m > 0
            outerbody();
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Sub, .arg=Symbol::Arg::Cell, .num=0 });
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Sub, .arg=Symbol::Arg::Temp, .num=r });
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Jump, .arg=Symbol::Arg::Label, .num=lbl_rend });

            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::NoOp, .arg=Symbol::Arg::Label, .num=lbl_nnegmneg });
            // n < 0, m < 0
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Sub, .arg=Symbol::Arg::Cell, .num=0 });
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Sub, .arg=Symbol::Arg::Temp, .num=m });
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Store, .arg=Symbol::Arg::Temp, .num=m });
            outerbody();
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Load, .arg=Symbol::Arg::Temp, .num=r });
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::NoOp, .arg=Symbol::Arg::Label, .num=lbl_rend });

            sz += 89;
            //}
            break;
        }

        case Op::Div: { // y DIV x
            i64 y = 2, x = 3, pos = 4, r = 5;
            i64 lbl_rend = getlbl(), lbl_yneg = getlbl(), lbl_yposxneg = getlbl(), lbl_ynegxneg = getlbl();

            sz += access_gen_symbols(s, a);

            auto divbody = [&]() {
                i64 lbl_pos_loop_beg = getlbl(), lbl_pos_loop_end = getlbl(),
                        lbl_div_loop_beg = getlbl(), lbl_div_loop_end = getlbl(), lbl_skip = getlbl();

                // r = 0;
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Sub, .arg=Symbol::Arg::Cell, .num=0 });
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Store, .arg=Symbol::Arg::Temp, .num=r });
                // pos = -1
                //s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Dec });
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Store, .arg=Symbol::Arg::Temp, .num=pos });

                // beg of div.c

                // while (y > (x << pos)) {
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::NoOp, .arg=Symbol::Arg::Label, .num=lbl_pos_loop_beg });
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Load, .arg=Symbol::Arg::Temp, .num=x });
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Shift, .arg=Symbol::Arg::Temp, .num=pos });
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Sub, .arg=Symbol::Arg::Temp, .num=y });

                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::JPos, .arg=Symbol::Arg::Label, .num=lbl_pos_loop_end });

                // pos++;
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Load, .arg=Symbol::Arg::Temp, .num=pos });
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Inc });
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Store, .arg=Symbol::Arg::Temp, .num=pos });

                // }
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Jump, .arg=Symbol::Arg::Label, .num=lbl_pos_loop_beg });
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::NoOp, .arg=Symbol::Arg::Label, .num=lbl_pos_loop_end });

                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Load, .arg=Symbol::Arg::Temp, .num=pos });
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Dec });

                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Store, .arg=Symbol::Arg::Temp, .num=pos });

                // while (pos >= 0) {
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Load, .arg=Symbol::Arg::Temp, .num=pos });
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::NoOp, .arg=Symbol::Arg::Label, .num=lbl_div_loop_beg });
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::JNeg, .arg=Symbol::Arg::Label, .num=lbl_div_loop_end });

                // if (y >= (x << pos)) {
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Sub, .arg=Symbol::Arg::Cell, .num=0 });
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Sub, .arg=Symbol::Arg::Temp, .num=x });
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Shift, .arg=Symbol::Arg::Temp, .num=pos });
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Add, .arg=Symbol::Arg::Temp, .num=y });

                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::JNeg, .arg=Symbol::Arg::Label, .num=lbl_skip });

                // y -= x;
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Store, .arg=Symbol::Arg::Temp, .num=y });

                // r += (1 << pos);
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Load, .arg=Symbol::Arg::Number, .num=1 });
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Shift, .arg=Symbol::Arg::Temp, .num=pos });
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Add, .arg=Symbol::Arg::Temp, .num=r });
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Store, .arg=Symbol::Arg::Temp, .num=r });

                // }
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::NoOp, .arg=Symbol::Arg::Label, .num=lbl_skip });

                // pos--;
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Load, .arg=Symbol::Arg::Temp, .num=pos });
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Dec });
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Store, .arg=Symbol::Arg::Temp, .num=pos });

                // }
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Jump, .arg=Symbol::Arg::Label, .num=lbl_div_loop_beg });
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::NoOp, .arg=Symbol::Arg::Label, .num=lbl_div_loop_end });
                // end of div.c

                sz += 36;
            };

            auto invres = [&]() {
                i64 lbl_skipround = getlbl();
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Load, .arg=Symbol::Arg::Temp, .num=y });
                // beg of dirty hack to fix div - round r down if remainder != 0
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::JZero, .arg=Symbol::Arg::Label, .num=lbl_skipround });
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Sub, .arg=Symbol::Arg::Cell, .num=0 });
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Sub, .arg=Symbol::Arg::Temp, .num=r });
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Dec });
                //s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Store, .arg=Symbol::Arg::Temp, .num=r });
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Jump, .arg=Symbol::Arg::Label, .num=lbl_rend });
                // end of dirty hack to fix div

                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::NoOp, .arg=Symbol::Arg::Label, .num=lbl_skipround });
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Sub, .arg=Symbol::Arg::Cell, .num=0 });
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Sub, .arg=Symbol::Arg::Temp, .num=r });
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Jump, .arg=Symbol::Arg::Label, .num=lbl_rend });

                sz += 10;
            };

            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::JZero, .arg=Symbol::Arg::Label, .num=lbl_rend });
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Store, .arg=Symbol::Arg::Temp, .num=y });
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::JNeg, .arg=Symbol::Arg::Label, .num=lbl_yneg });

            // y > 0
            opcode_b(Symbol::Opcode::Load);
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::JZero, .arg=Symbol::Arg::Label, .num=lbl_rend });
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Store, .arg=Symbol::Arg::Temp, .num=x });
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::JNeg, .arg=Symbol::Arg::Label, .num=lbl_yposxneg });
            // y > 0, x > 0
            divbody();
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Load, .arg=Symbol::Arg::Temp, .num=r });
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Jump, .arg=Symbol::Arg::Label, .num=lbl_rend });

            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::NoOp, .arg=Symbol::Arg::Label, .num=lbl_yposxneg });
            // y > 0, x < 0
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Sub, .arg=Symbol::Arg::Cell, .num=0 });
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Sub, .arg=Symbol::Arg::Temp, .num=x });
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Store, .arg=Symbol::Arg::Temp, .num=x });
            divbody();
            invres();

            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::NoOp, .arg=Symbol::Arg::Label, .num=lbl_yneg });
            // y < 0
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Sub, .arg=Symbol::Arg::Cell, .num=0 });
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Sub, .arg=Symbol::Arg::Temp, .num=y });
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Store, .arg=Symbol::Arg::Temp, .num=y });

            opcode_b(Symbol::Opcode::Load);
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::JZero, .arg=Symbol::Arg::Label, .num=lbl_rend });
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Store, .arg=Symbol::Arg::Temp, .num=x });
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::JNeg, .arg=Symbol::Arg::Label, .num=lbl_ynegxneg });
            // y < 0, x > 0
            divbody();
            invres();

            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::NoOp, .arg=Symbol::Arg::Label, .num=lbl_ynegxneg });
            // y < 0, x < 0
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Sub, .arg=Symbol::Arg::Cell, .num=0 });
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Sub, .arg=Symbol::Arg::Temp, .num=x });
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Store, .arg=Symbol::Arg::Temp, .num=x });
            divbody();
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Load, .arg=Symbol::Arg::Temp, .num=r });
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::NoOp, .arg=Symbol::Arg::Label, .num=lbl_rend });

            sz += 21;
            break;
        }

        case Op::Mod: { // y MOD x
            i64 y = 2, x = 3, pos = 4;
            i64 lbl_rend = getlbl(), lbl_yneg = getlbl(), lbl_yposxneg = getlbl(), lbl_ynegxneg = getlbl();

            sz += access_gen_symbols(s, a);

            auto modbody = [&]() {
                i64 lbl_pos_loop_beg = getlbl(), lbl_pos_loop_end = getlbl(),
                        lbl_div_loop_beg = getlbl(), lbl_div_loop_end = getlbl(), lbl_skip = getlbl();

                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Sub, .arg=Symbol::Arg::Cell, .num=0 });
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Store, .arg=Symbol::Arg::Temp, .num=pos });

                // beg of div.c

                // while (y >= (x << pos)) {
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::NoOp, .arg=Symbol::Arg::Label, .num=lbl_pos_loop_beg });
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Load, .arg=Symbol::Arg::Temp, .num=x });
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Shift, .arg=Symbol::Arg::Temp, .num=pos });
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Sub, .arg=Symbol::Arg::Temp, .num=y });

                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::JPos, .arg=Symbol::Arg::Label, .num=lbl_pos_loop_end });

                // pos++;
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Load, .arg=Symbol::Arg::Temp, .num=pos });
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Inc });
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Store, .arg=Symbol::Arg::Temp, .num=pos });

                // }
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Jump, .arg=Symbol::Arg::Label, .num=lbl_pos_loop_beg });
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::NoOp, .arg=Symbol::Arg::Label, .num=lbl_pos_loop_end });

                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Load, .arg=Symbol::Arg::Temp, .num=pos });
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Dec });
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Store, .arg=Symbol::Arg::Temp, .num=pos });

                // while (pos >= 0) {
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Load, .arg=Symbol::Arg::Temp, .num=pos });
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::NoOp, .arg=Symbol::Arg::Label, .num=lbl_div_loop_beg });
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::JNeg, .arg=Symbol::Arg::Label, .num=lbl_div_loop_end });

                // if (y >= (x << pos)) {
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Sub, .arg=Symbol::Arg::Cell, .num=0 });
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Sub, .arg=Symbol::Arg::Temp, .num=x });
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Shift, .arg=Symbol::Arg::Temp, .num=pos });
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Add, .arg=Symbol::Arg::Temp, .num=y });
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::JNeg, .arg=Symbol::Arg::Label, .num=lbl_skip });

                // y -= x;
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Store, .arg=Symbol::Arg::Temp, .num=y });

                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::NoOp, .arg=Symbol::Arg::Label, .num=lbl_skip });

                // pos--;
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Load, .arg=Symbol::Arg::Temp, .num=pos });
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Dec });
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Store, .arg=Symbol::Arg::Temp, .num=pos });

                // }
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Jump, .arg=Symbol::Arg::Label, .num=lbl_div_loop_beg });
                s.emplace_back(Symbol{ .opcode=Symbol::Opcode::NoOp, .arg=Symbol::Arg::Label, .num=lbl_div_loop_end });

                // end of div.c
                sz += 30;
            };

            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::JZero, .arg=Symbol::Arg::Label, .num=lbl_rend });
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Store, .arg=Symbol::Arg::Temp, .num=y });
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::JNeg, .arg=Symbol::Arg::Label, .num=lbl_yneg });

            // y > 0
            opcode_b(Symbol::Opcode::Load);
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::JZero, .arg=Symbol::Arg::Label, .num=lbl_rend });
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Store, .arg=Symbol::Arg::Temp, .num=x });
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::JNeg, .arg=Symbol::Arg::Label, .num=lbl_yposxneg });
            // y > 0, x > 0
            modbody();
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Load, .arg=Symbol::Arg::Temp, .num=y });
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Jump, .arg=Symbol::Arg::Label, .num=lbl_rend });

            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::NoOp, .arg=Symbol::Arg::Label, .num=lbl_yposxneg });
            // y > 0, x < 0
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Sub, .arg=Symbol::Arg::Cell, .num=0 });
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Sub, .arg=Symbol::Arg::Temp, .num=x });
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Store, .arg=Symbol::Arg::Temp, .num=x });
            modbody();
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Load, .arg=Symbol::Arg::Temp, .num=y });
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::JZero, .arg=Symbol::Arg::Label, .num=lbl_rend });
            s.emplace_back(
                    Symbol{ .opcode=Symbol::Opcode::Sub, .arg=Symbol::Arg::Temp, .num=x }); // dirty hack to fix mod
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Jump, .arg=Symbol::Arg::Label, .num=lbl_rend });

            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::NoOp, .arg=Symbol::Arg::Label, .num=lbl_yneg });
            // y < 0
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Sub, .arg=Symbol::Arg::Cell, .num=0 });
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Sub, .arg=Symbol::Arg::Temp, .num=y });
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Store, .arg=Symbol::Arg::Temp, .num=y });

            opcode_b(Symbol::Opcode::Load);
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::JZero, .arg=Symbol::Arg::Label, .num=lbl_rend });
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Store, .arg=Symbol::Arg::Temp, .num=x });
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::JNeg, .arg=Symbol::Arg::Label, .num=lbl_ynegxneg });
            // y < 0, x > 0
            modbody();
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Sub, .arg=Symbol::Arg::Cell, .num=0 });
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Sub, .arg=Symbol::Arg::Temp, .num=y });
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::JZero, .arg=Symbol::Arg::Label, .num=lbl_rend });
            s.emplace_back(
                    Symbol{ .opcode=Symbol::Opcode::Add, .arg=Symbol::Arg::Temp, .num=x }); // dirty hack to fix mod
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Jump, .arg=Symbol::Arg::Label, .num=lbl_rend });

            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::NoOp, .arg=Symbol::Arg::Label, .num=lbl_ynegxneg });
            // y < 0, x < 0
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Sub, .arg=Symbol::Arg::Cell, .num=0 });
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Sub, .arg=Symbol::Arg::Temp, .num=x });
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Store, .arg=Symbol::Arg::Temp, .num=x });
            modbody();
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Sub, .arg=Symbol::Arg::Cell, .num=0 });
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::Sub, .arg=Symbol::Arg::Temp, .num=y });
            s.emplace_back(Symbol{ .opcode=Symbol::Opcode::NoOp, .arg=Symbol::Arg::Label, .num=lbl_rend });

            sz += 35;
            break;
        }
    }

    return sz;
}
