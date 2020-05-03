#pragma once

#include <string>

extern struct Args {
    std::string ifname, ofname = "a.mr";
    bool warnings = true;
    void parse(int argc, char *argv[]);
} args;
