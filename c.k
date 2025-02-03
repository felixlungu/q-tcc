\d .c / C "scripting" in q/kdb+. see bellow \ for more info

KH:"#define KXVER ",($`int$.z.K),"\n#include \"",$[#f:getenv`QHOME;f;getenv[`HOME],"/q"],"/c/c/k.h\"\n"
C:""
TS:`long$()

CF:CF1:"-Wall"

/ .c.e: eval function called by q for foreign language interpreters.
/ it appends to TS, no compilation is triggered.
e:{C,::"\n",x;}


/ alocate tcc context, compile and relocate.
/ don't call directly! use dl[] to triger the compilation of accumulated code in TS
/ cc[flg;code]
cc:`cc 2:(`cc;2);

/ bind a symbol from the current compiled context to a k object
/ bs:{[ts;s;n] ts: tcc state, s: symbol, n: number of args
bs:`cc 2:(`bs;3)

/ add compiler and liker flags for libtcc
cf:{CF,::" ",x}


/ cut code at the last open unmatched open comment "/*"
ct:{r:(0,$[(#i:x ss "[/][*]")=#x ss "[*][/]";0;last i]) _ x;$[""~r 0;r[1 0];r]}

/ compile the accumulated code in C and dynamic link a function from compiled code.
/ if .c.dl is called from a C comment, it checks for previous compilations (C should not start with "/*")  and just link with the last compilation TS
/ clear CF flags and set C to the uncompiled code. beware, all definitions in the compiled code are lost but not the compiled symbols
dl:{[f;n] if[(#C) & ~"/*"~2#C;c:ct C;TS,::cc[CF;KH,"\n",c 0];CF::CF1;C::c 1];bs[last TS;f;n]}

\




N.B. :
- .c.e is called by q when a ".c"  file is loaded ( \l file.c ) or by "c)...". it will just append to .c.C global
- the compilation (if there is code in .c.C) and binding of a C symbol to a K object is triggered by calling .c.dl using the last compilation 
  context stored in .c.TS
- .c.cf and .c.dl can be called from an C multiline comment in the C file if a line starts with "k)" or "q)". q will not pass these lines to .c.e for processing

ex1: define an "add" function in C and link the compiled symbol into q as "add"

 q)c)K add(K x,K y){R ki(x->i+x->i);}
 q)add:.c.dl[`add;2]

ex2: load a C file and trigger the compilation and linking into a q function.

---   hypot.c  ---
------------------
#include <math.h>
K hypotenuse(K c1,K c2){if(-9!=c1->t||-9!=c2->t)R krr("type");R kf(hypot(c1->f,c2->f));}

/*
add options for compilation. this should be done before any calls to .c.dl
these lines are not intercepted as code by the C compiler since they are in a comment.
kdb+ will intercept the lines that starts with a letter or followed by ")". in the case of "q)", this line is
passed to the q interpreter.

k).c.cf"-Lm"
k)hypot:.c.dl[`hypotenuse;2]
q)-1"calling hypot[2;3]";
q)hypot[2f;3f]

*/
-----------------
/ load the C file and run the commands in the multiline comment at the end of the file
q)\l hypot.c

