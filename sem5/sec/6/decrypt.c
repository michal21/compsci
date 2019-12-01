#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <openssl/evp.h>
#define ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))
#define MAX_THRESH 32
typedef unsigned char byte;
#include "config.h"
static byte plain[512];
static EVP_CIPHER_CTX *ctx;
static int cipherlen;

void decrypt(int current_len, int len) {
    if (current_len == len) {
        int plainlen, flen;
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
            if (!((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == ' ' || c == '.' || c == ',') && thresh++ > MAX_THRESH) {
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
            decrypt(current_len + 1, len);
        }
    }
}

int main(int argc, char *argv[]) {
    if (argc < 3) {
        fprintf(stderr, "args\n");
        return 1;
    }

    int min = strtol(argv[1], NULL, 0), max = strtol(argv[2], NULL, 0);

    //printf("%d\n", ARRAY_SIZE(key));
    ctx = EVP_CIPHER_CTX_new();
    cipherlen = strlen(cipher);

    for (int i = min; i < max; i++) {
        //printf("prefix = %02x\n", i);
        key[0] = i;
        decrypt(1, IGNORE);
    }

    return 0;
}
