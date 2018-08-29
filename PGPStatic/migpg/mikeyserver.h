
#ifndef _MIKEYSERVER_H
#define _MIKEYSERVER_H

#include "micommon.h"

#define MAX_LINE       (6+1+1024+1)

#define MAX_COMMAND    7
#define MAX_OPTION   256
#define MAX_SCHEME    20
#define MAX_OPAQUE  1024
#define MAX_AUTH     128
#define MAX_HOST      80
#define MAX_PORT      10
#define URLMAX_PATH 1024
#define MAX_PROXY    128
#define MAX_URL     (MAX_SCHEME+1+3+MAX_AUTH+1+1+MAX_HOST+1+1 \
                     +MAX_PORT+1+1+URLMAX_PATH+1+50)

#define STRINGIFY(x) #x
#define MKSTRING(x) STRINGIFY(x)

#define BEGIN "-----BEGIN PGP PUBLIC KEY BLOCK-----"
#define END   "-----END PGP PUBLIC KEY BLOCK-----"

#ifdef __riscos__
#define HTTP_PROXY_ENV           "GnuPG$HttpProxy"
#else
#define HTTP_PROXY_ENV           "http_proxy"
#endif

/* 2 minutes seems reasonable */
#define DEFAULT_KEYSERVER_TIMEOUT 120

enum ks_search_type {KS_SEARCH_SUBSTR,KS_SEARCH_EXACT,
    KS_SEARCH_MAIL,KS_SEARCH_MAILSUB,
    KS_SEARCH_KEYID_LONG,KS_SEARCH_KEYID_SHORT};

struct keylist {
    char str[MAX_LINE];
    struct keylist *next;
};

struct ks_options {
    enum ks_action action;
    char *host;
    char *port;
    char *scheme;
    char *auth;
    char *path;
    char *opaque;
    struct {
        unsigned int include_disabled: 1;
        unsigned int include_revoked: 1;
        unsigned int include_subkeys: 1;
        unsigned int check_cert: 1;
    } flags;
    unsigned int verbose;
    unsigned int debug;
    unsigned int timeout;
    char *ca_cert_file;
};

struct curl_writer_ctx {
    struct {
        unsigned int initialized:1;
        unsigned int begun:1;
        unsigned int done:1;
        unsigned int armor:1;
    } flags;

    int armor_remaining;
    unsigned char armor_ctx[3];
    int markeridx,linelen;
    const char *marker;
    char *stream;
};

struct curl_mrindex_writer_ctx {
    int checked;
    int swallow;
    char *stream;
};

int
mi_keyserver_work(enum ks_action action, char *server, char *in, char *options,
        void **ilist);




#endif /* _MIKEYSERVER_H */
