#pragma once

#include <iostream>
#include <string>
#include <sstream>
#include <fstream>
#include <memory>
#include <vector>
#include <map>
#include <vector>
#include <optional>
#include <cstdio>
#include <cstdint>
#include <cstring>
#include <algorithm>
#include "args.hh"
#include "log.hh"

using i64 = std::int64_t;
using u64 = std::uint64_t;

struct Var {
    bool array = false, initialised = false;
    i64 from = 0, range = 0, cell = 0;
};

extern std::map<std::string, Var> var_tab;
extern std::vector<std::string> iter_tab;
extern i64 iter_max;
extern i64 cell;
extern struct IBlock code;

void declare_var(std::string name, bool array = false, i64 from = 0, i64 to = 0);