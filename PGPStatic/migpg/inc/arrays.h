/*
 *
 *  среда, 16 сентября 2015 г. 17:23:24 (EEST)
 *
 */

#ifndef _ARRAYS_H_
#define _ARRAYS_H_

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include "mem_pool.h"


unsigned int hash32(char *key);

/*
 *
 *  arrays by key
 *
 */

typedef struct _array_key_node_t {
    struct _array_key_node_t    *next;
    char                        *key;
    int                         type;
    void                        *val;
    int                         len;
    int                         flag;
} *parray_key_node_t, array_key_node_t;

typedef struct _array_key_t {
    struct _mem_pool_t          *pool;
    struct _array_key_node_t    **nodes;
    int                         size;
    int                         count;
    char                        *info;
    int                         flags;
} *parray_key_t, array_key_t;

array_key_t *array_key_init(size_t size);
void *array_key_free(array_key_t *a);

array_key_node_t *array_key_exist(array_key_t *a, char *key);
void array_key_del(array_key_t *a, char *key);
array_key_node_t *
    array_key_set(array_key_t *a, char *key, void *val, int type, int size);


/*
 *
 *  arrays by queue
 *
 */

typedef struct _array_queue_node_t {
    struct _array_queue_node_t  *prev; 
    struct _array_queue_node_t  *next;
    int                         type;
    void                        *val;
    int                         len;
    int                         flag;
} *parray_quiue_node_t, array_queue_node_t;

typedef struct _array_queue_t {
    struct _mem_pool_t          *pool;
    struct _array_queue_node_t  *first; 
    struct _array_queue_node_t  *last;
    int                         count;
    char                        *info;
    int                         flags;
} *parray_quiue_t, array_queue_t;

array_queue_t *array_queue_init(void);
void *array_queue_free(array_queue_t *a);

array_queue_node_t *
    array_queue_push(array_queue_t *a, void *val, int type, int size);
array_queue_node_t *array_queue_pop(array_queue_t *a);
array_queue_node_t *
    array_queue_unshift(array_queue_t *a, void *val, int type, int size);
array_queue_node_t *array_queue_shift(array_queue_t *a);


/* упаковка double в int64 */
void *FLP(double a);
/* распаковка int64 в double */
double FLU(void *a);

#define EXP_ERROR_LEN   255
#define PREV_ASIZE  20  // массив предыдущих значений
typedef struct _exp_data_t {
    array_key_t     *current;
    array_key_t     *prev[PREV_ASIZE];
    /* run-time variables */
    array_queue_t   *code;
    array_key_t     *local;
    array_queue_t   *blocks_markers;
    array_queue_t   *msg;
    int             line;
    int             err;
    char            error[EXP_ERROR_LEN + 1];
} exp_data_t;

#endif /* _ARRAYS_H_ */
