
#ifndef _MICOMMON_H
#define _MICOMMON_H

#include <config.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <errno.h>
#include <assert.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/sem.h>
#include <unistd.h>
#include "util.h"
#include "main.h"
#include "memory.h"
#include "packet.h"
#include "cipher.h"
#include "ttyio.h"
#include "options.h"
#include "keydb.h"
#include "trustdb.h"
#include "status.h"
#include "i18n.h"
#include "cardglue.h"
#include "keyserver-internal.h"
#include "host2net.h"
#include "global.h"


#define DEFAULT_KEYSERVER "keyserver.ubuntu.com"

#define MAX_PREFS 30

#define IOBUF_BUFFER_SIZE  8192

#ifndef FREE
# define FREE(a) if (a) {free(a); a = NULL;}
#endif

#define MI_PUB_KEY      0
#define MI_SEC_KEY      1

/* кол-во разрещенных потоков */
#define _MI_LOCK_THREADS 10

#define MI_LOCK_THREAD      0
#define MI_LOCK_KEYS_DB     1

#define MI_LOCK             2
#define MI_LOCK_H           3

typedef struct _list_key_t {
    struct _list_key_t *next;
    char        key[64];
    int         secret;
    char        status;
    int         nbits;
    int         algo;
    uint32_t    keyid[2];
    unsigned int    timestamp;
    unsigned int    expiredate;
    char        ownertrust;
    int         mode;
    char        fpr[MAX_FINGERPRINT_LEN * 2 + 1];
    struct {
        unsigned char   attr;
        char        stat;
        char        hash[32 * 2 + 1];
        int         len;
        char        name[1];
    } uid;
} list_key_t;

enum ks_action {KS_UNKNOWN=0,KS_GET,KS_GETNAME,KS_SEND,KS_SEARCH};

int slock_init(void);
void slock(int c);
void sunlock(int c);

/*
ACTION: очитска списка результатов импорта
    mm - указатель на список

RESULT:
 */
void mi_import_free(mi_imported_t *mm);
void mi_list_keys_free(list_key_t *mm); 

void 
start_tree(KBNODE *tree);
void
hash_passphrase(DEK *dek, char *pw, STRING2KEY *s2k, int create);
int
gen_rsa(int algo, unsigned nbits, KBNODE pub_root, KBNODE sec_root, DEK *dek,
        STRING2KEY *s2k, PKT_secret_key **ret_sk, u32 timestamp,
        u32 expireval, int is_subkey);

void
write_uid( KBNODE root, const char *s );
int
write_selfsigs (KBNODE sec_root, KBNODE pub_root, PKT_secret_key *sk,
		unsigned int use, u32 timestamp);

int
do_export_stream( IOBUF out, STRLIST users, int secret,
		  KBNODE *keyblock_out, unsigned int options, int *any );


typedef struct {
    int fp;
    int keep_open;
    int no_cache;
    int eof_seen;
    int  print_only_name; /* flags indicating that fname is not a real file*/
    struct {
        char    *buf;
        char    *p;
        size_t  size_buf;
        size_t  size;
    } d;
    char fname[1]; /* name of the file */
 } mi_file_filter_ctx_t ;

IOBUF
mi_iobuf_open(char *in, int size);

int
mi_filter( void *opaque, int control,
	     IOBUF a, byte *buf, size_t *ret_len);

int
use_mdc(PK_LIST pk_list,int algo);
int
write_pubkey_enc_from_list( PK_LIST pk_list, DEK *dek, IOBUF out );

DEK *
mi_passphrase_to_dek(char *pass, int pubkey_algo, int cipher_algo, 
        STRING2KEY *s2k, int mode, const char *tryagain_text, 
        int *canceled);

int
mi_do_check( PKT_secret_key *sk, const char *tryagain_text, int mode,
          int *canceled, char *pass);

int
mi_get_session_key( PKT_pubkey_enc *k, DEK *dek, char *pass );

/****************
 * Delete a public or secret key from a keyring.
 */
int
mi_delete_keys( char *name, int secret, int allow_both );


/****************
 * Make an output filename for the inputfile INAME.
 * Returns an IOBUF and an errorcode
 * Mode 0 = use ".gpg"
 *	1 = use ".asc"
 *	2 = use ".sig"
 */
int
mi_open_outfile(const char *iname, int mode, IOBUF *a, int overwrite);


#endif /* _MICOMMON_H */
