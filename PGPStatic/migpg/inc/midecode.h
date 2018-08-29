
#ifndef _MIDECODE_H
#define _MIDECODE_H

#include <stdio.h>
#include <stdlib.h>
#include "global.h"
#include "arrays.h"
#include "micommon.h"

int
mi_handle_plaintext( PKT_plaintext *pt, md_filter_context_t *mfx,
		  int nooutput, int clearsig, MICTX *mctx );

int
mi_handle_compressed( void *procctx, PKT_compressed *cd,
		   int (*callback)(IOBUF, void *, MICTX *), void *passthru,
           MICTX *mctx );

int
mi_proc_packets( void *anchor, IOBUF a, MICTX *mctx );

int
mi_proc_encryption_packets( void *anchor, IOBUF a, MICTX *mctx );


int
mi_decrypt_data( void *procctx, PKT_encrypted *ed, DEK *dek, 
        MICTX *mctx );



#endif /* _MIDECODE_H */
