
#ifndef _MIGPG_H
#define _MIGPG_H

#include <stdio.h>
#include <stdlib.h>
#include <global.h>
#include "arrays.h"
#include "micommon.h"

#define OUTDATA

//#define PROTECT_SUBKEY

typedef struct _sig_stats {
    int inv_sigs;
    int no_key;
    int oth_err;
} sig_stats;


/*
ACTION: инициализация
    home - путь к директории для хранения ключей, !!! должна существовать

RESULT:
 */
int
mi_init(char *home);


/*
ACTION: генерация RSA-пары
    keylen - размер ключа, 2048 или 4096(оптимально)
    name_real - 
    name_comment - 
    name_email - 
    expiredate - истечение срока действия (unixtime), 0 - unlim
    passwd - пароль
    fpr - куда бедет помещен указатель на fpr

RESULT: 0 - все ок, иначе смотреть gnupg/include/errors.h
 */
int
mi_gen_rsa_key(int keylen, 
        char *name_real, char *name_comment, char *name_email,
        unsigned int expiredate, char *passwd, char **fpr);



/*
ACTION: список ключей
    a - указатель на хеш-массив, создается заранее
    secret - если 0, то список прубличных ключей, иначе - приватные

RESULT: 0 - все ок, иначе смотреть gnupg/include/errors.h
 */
int
mi_list_keys(list_key_t **a, int secret);

/*
ACTION: експорт ключей
    fpr - fpr ключа, если NULL будет експортирован весь список
    secret - если 0, то список прубличных ключей, иначе - приватные
    armor - если не 0 - вывод в виде base64
    outbuf - выходной буффер
    len - полученный размер выходного буффера

RESULT: 0 - все ок, иначе смотреть gnupg/include/errors.h
 */
int
mi_export(char *fpr, int secret, int armor, char **outbuf, int *len);
/*
ACTION: импорт ключей
    in - входной буффер
    len - размер входного буффера
    ilist - указатель на связанный список с результатом импорта

RESULT: 0 - все ок, иначе смотреть gnupg/include/errors.h
 */
int
mi_import(char *in, int len, mi_imported_t **ilist);

/*
ACTION: шифрование буффера
    inbuf - входной буффер
    inlen - размер входного буффера
    filename - имя файла которое будет помещено в пакет, можно ставить NULL
    fpr - и так понятно
    armor - если не 0 - вывод в виде base64
    outbuf - выходной буффер
    outlen - полученный размер выходного буффера

RESULT: 0 - все ок, иначе смотреть gnupg/include/errors.h
 */
int
mi_encrypt(char *inbuf, int inlen, char *filename, char *fpr, int armor, 
        char **outbuf, int *outlen);
int
mi_encrypt_file(char *infile, char *fpr, int armor, int overwrite);

/*
ACTION: расшифровка буффера
    inbuf - входной буффер
    inlen - размер входного буффера
    pass - пароль
    fpr - сюда будет помещен fpr ключа, которым было зашифровано
    outbuf - выходной буффер
    outlen - полученный размер выходного буффера
    fname - имя файла записанное в пакете

RESULT: 0 - все ок, иначе смотреть gnupg/include/errors.h
 */
int
mi_decrypt(char *inbuf, int inlen, char *pass, char **fpr,
        char **outbuf, int *outlen, char **fname);
int
mi_decrypt_file(char *infile, char *pass, char **fpr, char **fname, int overwrite);

/*
ACTION: удаление ключей
    fpr - ключ
    secret - если 0, удалить паблик ключ, иначе - приватный
    allow_both - если установлен, прибить оба ключа

RESULT: 0 - все ок, иначе смотреть gnupg/include/errors.h
        -1 - ключ не найден
 */
int
mi_delete_key(char *fpr, int secret, int allow_both);


int
mi_keyserver_recv(char *srv, char *fpr, char *options, mi_imported_t **ilist);
int
mi_keyserver_name(char *srv, char *search, char *options, mi_imported_t **ilist); 
int
mi_keyserver_send(char *srv, char *fpr, char *options); 
int
mi_keyserver_search(char *srv, char *search, char *options, list_key_t **lskeys); 


int
mi_change_passphrase(char *cfpr, char *old_pass, char *new_pass);

int 
mi_split(char *in, int len, char **out, int *olen);


#endif /* _MIGPG_H */
