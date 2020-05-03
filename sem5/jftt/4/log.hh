#pragma once

#include <iostream>
#include <iomanip>
#include <string>
#include <cstdio>
#include "args.hh"
#include "input.hh"

extern "C" {
#include <unistd.h>
}

namespace intlog {
    enum class LogLevel {
        Debug,
        Warning,
        Error,
        SyntaxError,
        Fatal
    };

    static bool usecolors() {
        return static_cast<bool>(isatty(2));
    }

    template<typename T>
    void print(T t) {
        std::cerr << t;
    }

    static void write() {}

    template<typename Arg, typename ...Rest>
    void write(Arg arg, Rest... rest) {
        print(arg);
        write(rest...);
    }

    template<typename ...Args>
    void log(LogLevel lvl, Args... args) {
        using namespace std::string_literals;
        if (lvl != LogLevel::Fatal) {
            auto pos = (lvl == LogLevel::SyntaxError) ? input::textpos() : input::ptextpos();
            auto oline = input::linefornum(pos.first);
            write(::args.ifname, ':');
            if (pos.first != -1) {
                write(pos.first, ':', pos.second, ':');
            }
            write(' ', args...);
            if (oline.has_value()) {
                std::string line = *oline,
                        arrow = usecolors() ? (lvl == LogLevel::Warning ? "\033[1;33m"s : "\033[1;31m"s) + "^\033[m\n"s
                                            : "^\n";
                write("\n ", std::setfill(' '), std::setw(4), pos.first, " | ", line,
                      "\n      |", std::string(static_cast<unsigned long>(pos.second), ' '), arrow);
            }
        } else {
            write(args...);
        }
        std::cerr << std::endl;

        if (lvl == LogLevel::Error || lvl == LogLevel::SyntaxError || lvl == LogLevel::Fatal) {
            std::exit(1);
        }
    }
}

template<typename ...Args>
void log(Args... args) {
    intlog::log(intlog::LogLevel::Debug, args...);
}

template<typename ...Args>
void warning(Args... args) {
    std::string l = intlog::usecolors() ? "\033[1;33mwarning:\033[m " : "warning: ";
    if (::args.warnings) {
        intlog::log(intlog::LogLevel::Warning, l, args...);
    }
}

template<typename ...Args>
void error(Args... args) {
    std::string l = intlog::usecolors() ? "\033[1;31merror:\033[m " : "error: ";
    intlog::log(intlog::LogLevel::Error, l, args...);
}

template<typename ...Args>
void syntaxerror(Args... args) {
    std::string l = intlog::usecolors() ? "\033[1;31msyntax error:\033[m " : "syntax error: ";
    intlog::log(intlog::LogLevel::SyntaxError, l, args...);
}

template<typename ...Args>
void fatal(Args... args) {
    std::string l = intlog::usecolors() ? "\033[1;31mfatal error:\033[m " : "fatal error: ";
    intlog::log(intlog::LogLevel::Fatal, l, args...);
}
