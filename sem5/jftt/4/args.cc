#include "args.hh"
#include "log.hh"

extern "C" {
#include <getopt.h>
}

void Args::parse(int argc, char *argv[]) {
    // named
    static const char short_opts[] = "Ww";
    for (;;) {
        int opt = getopt(argc, argv, short_opts);
        switch (opt) {
            case -1: goto break_named;

            case 'W': warnings = true;
                break;

            case 'w': warnings = false;
                break;
        }
    }
    break_named:;

    // unnamed
#define NEXTARG if (optind >= argc) goto break_unnamed

    NEXTARG;
    ifname = argv[optind++];
    NEXTARG;
    ofname = argv[optind++];

    break_unnamed:;

    // required
    if (ifname.empty()) {
        fatal("input filename required");
    }
}