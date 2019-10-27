#include <iostream>
#include <string>
#include <string_view>
#include <cstring>
#include <vector>
#include <map>
#include <algorithm>

namespace {
    using TransitionMap = std::map<std::pair<int, char>, int>;

    template<class W, class X>
    bool suf(W w, X x) {
        if (x.size() < w.size()) {
            return false;
        }
        return x.compare(x.size() - w.size(), w.size(), w) == 0;
    }

    auto compute_transition_function(std::string pat, std::string dct) {
        TransitionMap ret;
        int m = pat.size();

        for (int q = 0; q <= m; q++) {
            for (char a : dct) {
                int k = std::min(q + 2, m + 1);
                do {
                    k--;
                } while (!suf(pat.substr(0, k), pat.substr(0, q) + a));
                ret[{q, a}] = k;
                //std::cout << "ret[{" << q << ", " << a << "}] = " << k << '\n';
            }
        }
        return ret;
    }

    auto match_fam(std::string_view txt, TransitionMap del, int m) {
        std::vector<int> ret;
        int q = 0;
        for (int i = 0; i < txt.size(); i++) {
            q = del[{q, txt.at(i)}];
            if (q == m) {
                ret.emplace_back(i - m + 1);
            }
        }
        return ret;
    }
}

int main(int argc, char *argv[]) {
    if (argc != 3) {
        std::cerr << "Invalid parameters\n";
        return 1;
    }
    std::string txt = argv[1], pat = argv[2], dct = argv[2];
    dct.erase(std::unique(dct.begin(), dct.end()), dct.end());
    auto del = compute_transition_function(pat, dct);
    auto ret = match_fam(txt, del, pat.size());
    if (ret.size() == 0) {
        return 1;
    }
#ifndef PRETTY_OUTPUT
    for (int r : ret) {
        std::cout << "Matched pattern at offset: " << r << std::endl;
    }
#else
    try {
        std::cout << txt << '\n';
        int n = 0;
        for (int i = 0; i < txt.size(); i++) {
            if (i == ret.at(n)) {
                std::cout << '^';
                n++;
            } else {
                std::cout << ' ';
            }
        }
        std::cout << std::endl;
    } catch (const std::out_of_range &e) {
        std::cout << std::endl;
    }
#endif /* PRETTY_OUTPUT */
    return 0;
}
