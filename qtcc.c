#include <stdlib.h>
#include <stdio.h>

#define KXVER 3
#include "libtcc.h"
#include "k.h"

// compile a string. cf: compile flags, p: C code.
K cc(K cf, K p){
 TCCState * ts;
 K f, c, r;C z='\0';
 f=r1(cf); c=r1(p);
 ja(&f,&z); c=ja(&c,&z); // terminate with '\0' options and code, just in case...

 ts=tcc_new();
 if(!ts){ r=krr("tcc_state"); goto CLEAN; }

 tcc_set_output_type(ts,TCC_OUTPUT_MEMORY);
 tcc_set_options(ts,(S)kG(f));
 if(-1==tcc_compile_string(ts,(S)kG(c))){ r=krr("tcc_compile"); goto CLEAN_TS; }

 if(-1==tcc_relocate(ts)){ r=krr("tcc_relocate"); goto CLEAN_TS; }

 r=kj((J)ts);goto CLEAN;

CLEAN_TS:
 tcc_delete(ts);
CLEAN:
 r0(f);r0(c);
 R r;
}


// bind a function symbol to code (K type 112)
K bs(K ts, K s, K n){
 V* f; f=tcc_get_symbol((TCCState*)ts->j,s->s);
 R f? dl(f,n->j): krr(s->s);}
