#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <sys/wait.h>
#include <openssl/evp.h>
#include <openssl/aes.h>
#include <openssl/err.h>
#include <openssl/sha.h>
#include <openssl/rand.h>

#define CHK(x) do { if (x) { goto cleanup; } } while (0)

enum {
    NPZLS = 1 << 22,
    BUFSZ = 64,
    CHLNG = 2
};

typedef unsigned char byte;

struct message {
    byte key[32];
    byte ident[32];
    byte verif[32];
};

struct enc_message {
    byte iv[16];
    byte tag[16];
    byte data[sizeof(struct message)];
};

struct puzzle {
    byte hash[32];
    struct enc_message enc_message;
};

struct enc_verif {
    byte iv[16];
    byte tag[16];
    byte data[32];
};

struct response {
    byte ident[32];
    struct enc_verif enc_verif;
};

int encrypt(void *ciphertext, void *plaintext, int plaintext_len, byte *key, byte *iv, byte *tag);
int decrypt(void *plaintext, void *ciphertext, int ciphertext_len, byte *key, byte *iv, byte *tag);
int wencrypt(void *ciphertext, void *plaintext, int plaintext_len, byte *iv, byte *tag);
int wbrute(void *plaintext, void *ciphertext, int ciphertext_len, byte *iv, byte *tag, byte *hash);

int sockfd;
struct puzzle puzzles[BUFSZ];

void simb(void) {
    size_t i, j = 0;
    byte secret_ident[64], super_secret[32];
    RAND_bytes(super_secret, 32);
    memcpy(secret_ident, super_secret, 32);

    puts("[B] starting gen");
    for (i = 0; i < NPZLS; i++) {
        struct message msg;
        RAND_bytes(secret_ident + 32, 32);
        SHA256(secret_ident, 64, msg.key);
        memcpy(msg.ident, secret_ident + 32, 32);
        memcpy(msg.verif, "OtherSideHasBeenProvenCorrect:)", 32);
        /*sprintf(msg.verif, "%llu", i);
        msg.verif[strlen(msg.verif)] = '+';*/
        SHA256((void *)&msg, sizeof(struct message), puzzles[j].hash);
        wencrypt(puzzles[j].enc_message.data, &msg, sizeof(struct message), puzzles[j].enc_message.iv, puzzles[j].enc_message.tag);
        if (++j >= BUFSZ) {
            int r = write(sockfd, puzzles, sizeof(puzzles));
            if (r != sizeof(puzzles)) {
                perror("write");
            }
            j = 0;
        }
    }
    puts("[B] finished gen");
    puts("[B] awaiting response");
    struct response response;
    int r = read(sockfd, &response, sizeof(struct response));
    if (r != sizeof(struct response)) {
        perror("read");
    }
    byte key[32], plain[32];
    memcpy(secret_ident + 32, response.ident, 32);
    SHA256(secret_ident, 64, key);
    decrypt(plain, response.enc_verif.data, 32, key, response.enc_verif.iv, response.enc_verif.tag);
    printf("[B] received verification: %s\n", plain);
}

void sima(void) {
    size_t rid, i = 0;
    struct puzzle puzzle;

    RAND_bytes((void *)&rid, sizeof(size_t));
    rid %= NPZLS;
    printf("[A] rid: %d\n", rid);

    puts("[A] accepting packets");
    while (i < NPZLS) {
        int r = read(sockfd, puzzles, sizeof(puzzles));     
        if (r != sizeof(puzzles)) {
            perror("read");
        }
        if (rid / BUFSZ == i / BUFSZ) {
            memcpy(&puzzle, &puzzles[rid % BUFSZ], sizeof(struct puzzle));
        }
        i += BUFSZ;
    }
    puts("[A] received all packets");

    struct message msg;
    puts("[A] starting decryption");
    int r = wbrute(&msg, puzzle.enc_message.data, sizeof(struct message), puzzle.enc_message.iv, puzzle.enc_message.tag, puzzle.hash);
    printf("[A] msg.verif: %s\n", msg.verif);
    
    puts("[A] sending verification");
    struct response response;
    memcpy(response.ident, msg.ident, 32);
    encrypt(response.enc_verif.data, msg.verif, 32, msg.key, response.enc_verif.iv, response.enc_verif.tag);
    r = write(sockfd, &response, sizeof(struct response));
    if (r != sizeof(response)) {
        perror("write");
    }
}

int main(int argc, char *argv[]) {
    OpenSSL_add_all_algorithms();
    ERR_load_crypto_strings();
    //printf("sizeof(struct puzzle) = %d\n", sizeof(struct puzzle));
    printf("NPZLS: %llu\n", NPZLS);

    int fds[2];
    pid_t pid;

    socketpair(PF_LOCAL, SOCK_STREAM, 0, fds);
    if ((pid = fork()) < 0) {
        perror("fork");
    } else if (pid == 0) {
        sockfd = fds[0];
        close(fds[1]);
        sima();
    } else {
        sockfd = fds[1];
        close(fds[0]);
        simb();
        wait(NULL);
    }

    ERR_free_strings();

    return 0;
}

int encrypt(void *ciphertext, void *plaintext, int plaintext_len, byte *key, byte *iv, byte *tag) {
    int len = 0, ciphertext_len = -1;
    EVP_CIPHER_CTX *ctx = NULL;

    CHK((ctx = EVP_CIPHER_CTX_new()) == NULL);
    CHK(!EVP_EncryptInit_ex(ctx, EVP_aes_256_gcm(), NULL, NULL, NULL));
    CHK(!EVP_CIPHER_CTX_ctrl(ctx, EVP_CTRL_GCM_SET_IVLEN, 16, NULL));
    RAND_bytes(iv, 16);
    CHK(!EVP_EncryptInit_ex(ctx, NULL, NULL, key, iv));
    CHK(!EVP_EncryptUpdate(ctx, ciphertext, &len, plaintext, plaintext_len));
    ciphertext_len = len;
    CHK(!EVP_EncryptFinal_ex(ctx, ciphertext + len, &len));
    ciphertext_len += len;
    CHK(!EVP_CIPHER_CTX_ctrl(ctx, EVP_CTRL_GCM_GET_TAG, 16, tag));

cleanup:
    if (ctx != NULL) {
        EVP_CIPHER_CTX_free(ctx);
    }
    if (ciphertext_len < 0) {
        ERR_print_errors_fp(stderr);
    }
    return ciphertext_len;
}

int decrypt(void *plaintext, void *ciphertext, int ciphertext_len, byte *key, byte *iv, byte *tag) {
    int len = 0, plaintext_len = 0, ret;
    EVP_CIPHER_CTX *ctx = NULL;

    CHK((ctx = EVP_CIPHER_CTX_new()) == NULL);
    CHK(!EVP_DecryptInit_ex(ctx, EVP_aes_256_gcm(), NULL, NULL, NULL));
    CHK(!EVP_CIPHER_CTX_ctrl(ctx, EVP_CTRL_GCM_SET_IVLEN, 16, NULL));
    CHK(!EVP_DecryptInit_ex(ctx, NULL, NULL, key, iv));
    CHK(!EVP_DecryptUpdate(ctx, plaintext, &len, ciphertext, ciphertext_len));
    plaintext_len = len;
    CHK(!EVP_CIPHER_CTX_ctrl(ctx, EVP_CTRL_GCM_SET_TAG, 16, tag));
    ret = EVP_DecryptFinal_ex(ctx, plaintext + len, &len);

cleanup:
    if (ctx != NULL) {
        EVP_CIPHER_CTX_free(ctx);
    }
    if (ret > 0) {
        plaintext_len += len;
        return plaintext_len;
    } else {
        ERR_print_errors_fp(stderr);
        return -1;
    }
}

int wencrypt(void *ciphertext, void *plaintext, int plaintext_len, byte *iv, byte *tag) {
    byte key[32];
    memset(key, 0, 32);
    RAND_bytes(key, CHLNG);
    //BIO_dump_fp(stdout, key, CHLNG);
    return encrypt(ciphertext, plaintext, plaintext_len, key, iv, tag);
}

int wbrute(void *plaintext, void *ciphertext, int ciphertext_len, byte *iv, byte *tag, byte *hash) {
    unsigned long long i = 0;
    int r;
    byte key[32], nhash[32];
    memset(key, 0, 32);
    do {
        memcpy(key, &i, CHLNG);
        //BIO_dump_fp(stdout, key, CHLNG);
        if ((r = decrypt(plaintext, ciphertext, ciphertext_len, key, iv, tag)) < 0) {
            i++;
            continue;
        }
        SHA256(plaintext, r, nhash);
    } while (memcmp(nhash, hash, 32) != 0);
    return r;
}
