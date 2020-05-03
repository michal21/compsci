#pragma once

#include <string>
#include <optional>

struct YYLTYPE;

namespace input {
    void open();
    int getchars(char *buf, int buflen);
    void offset(int off);
    std::pair<int, int> textpos();
    std::pair<int, int> ptextpos();
    void setppos(const YYLTYPE &yyltype);
    void invalppos();
    std::optional<std::string> linefornum(int lno);
}
