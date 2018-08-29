/*
 *
 *  среда, 16 сентября 2015 г. 14:06:27 (EEST)
 *
 */

#ifndef _MEM_POOL_H_
#define _MEM_POOL_H_

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define MALIGN(s, a) (s + a - 1) & ~(a - 1)
#define BLOCK_ALIGN sizeof(void *)
#define CACHE_ALIGN 64

#ifndef FREE
# define FREE(a) if (a) {free(a); a = NULL;}
#endif

typedef struct _mem_pool_t {
    struct _mem_pool_t  *next;
    void                *pos;
    unsigned int        size;
} *pmem_pool_t, mem_pool_t;

void *mem_pool_init(int size);
void *mem_pool_alloc(mem_pool_t *p, int size);
void *mem_pool_free(mem_pool_t *p);
void mem_pool_clean(mem_pool_t *p);

#endif /* _MEM_POOL_H_ */
