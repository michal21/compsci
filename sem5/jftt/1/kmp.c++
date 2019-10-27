#include <iostream>
#include <string>
#include <string_view>
#include <vector>

namespace {
    auto compute_prefix_function(std::string_view pat) {
        std::vector<int> pi(pat.size());
        pi[0] = 0;
        int k = 0;
        for (int q = 1; q < pat.size(); q++) {
            while (k > 0 && pat[k] != pat[q]) {
                k = pi[k - 1];
            }
            if (pat[k] == pat[q]) {
                k++;
            }
            pi[q] = k;
        }
        return pi;
    }

    auto match_kmp(std::string_view txt, std::string_view pat) {
        std::vector<int> ret;
        auto pi = compute_prefix_function(pat);
        int q = 0;
        for (int i = 1; i <= txt.size(); i++) {
            while (q > 0 && pat[q] != txt[i - 1]) {
                q = pi[q - 1];
            }
            if (pat[q] == txt[i - 1]) {
                q++;
            }
            if (q == pat.size()) {
                ret.emplace_back(i - pat.size());
                q = pi[q - 1];
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
    std::string txt = argv[1], pat = argv[2];
    auto ret = match_kmp(txt, pat);
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
