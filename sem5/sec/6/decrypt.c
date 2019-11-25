#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <openssl/evp.h>
#define ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))
#define MAX_THRESH 10
typedef unsigned char byte;
#include "config.h"
static byte plain[512];
static EVP_CIPHER_CTX *ctx;
static int cipherlen;

void print_string(int current_len, int len) {
    if (current_len == len) {
        int plainlen, flen;
        /*printf("%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x\n",
          key[0], key[1], key[2], key[3],
          key[4], key[5], key[6], key[7],
          key[8], key[9], key[10], key[11],
          key[12], key[13], key[14], key[15]);*/
        EVP_CIPHER_CTX_init(ctx);
        if (EVP_DecryptInit_ex(ctx, EVP_aes_256_cbc(), NULL, key, iv) != 1) {
            return;
        }
        if (EVP_DecryptUpdate(ctx, plain, &plainlen, cipher, cipherlen) != 1) {
            return;
        }
        if (EVP_DecryptFinal_ex(ctx, plain + plainlen, &flen) != 1) {
            return;
        }
        plainlen += flen;

        int thresh = 0;
        for (int i = 0; i < plainlen; i++) {
            char c = plain[i];
            if (!((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z')) && thresh++ > MAX_THRESH) {
                return;
            }
        }

        putchar('\n');
        for (int i = 0; i < 32; i++) {
            printf("%02x", key[i]);
        }
        putchar('\n');
        puts(plain);
        return;
    } else {
        for (int i = 0; i < 256; i++) {
            key[current_len] = i;
            print_string(current_len + 1, len);
        }
    }
}

int main(int argc, char *argv[]) {
    if (argc < 3) {
        fprintf(stderr, "args\n");
        return 1;
    }

    int min = strtol(argv[1], NULL, 0), max = strtol(argv[2], NULL, 0);

    printf("%d\n", ARRAY_SIZE(key));
    ctx = EVP_CIPHER_CTX_new();
    cipherlen = strlen(cipher);

    for (int i = min; i < max; i++) {
        key[0] = i;
        print_string(1, IGNORE);
    }
    return 0;

    cipherlen = strlen(cipher);
    int plainlen, flen;
    ctx = EVP_CIPHER_CTX_new();
    EVP_CIPHER_CTX_init(ctx);
    EVP_DecryptInit_ex(ctx, EVP_aes_256_cbc(), NULL, key, iv);
    EVP_DecryptUpdate(ctx, plain, &plainlen, cipher, cipherlen);
    EVP_DecryptFinal_ex(ctx, plain + plainlen, &flen);
    plainlen += flen;
    puts(plain);
    return 0;
}
