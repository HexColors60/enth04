\ SASM.F

\ Copyright (C) 2001, Sean Pringle
\ Use this Assembler as required in the Public Domain, just keep this intro text
\ and the above.

\ Be warned: It is not complete.

hex only forth definitions vocabulary sasm vocabulary easm
also sasm definitions

\ ------------- Assembler Stacks -----------------------------------------------

create do-stack 3 cells allot do-stack value do-point

: do-push  ( n - ) do-point dup cell+ to do-point ! ;
: do-pop   ( - n ) do-point cell- dup to do-point @ ;
: do-drop  ( - ) do-point cell- to do-point ;
: do-swap  ( - ) do-pop do-pop swap do-push do-push ;
: do-zero  ( - ) do-stack to do-point ;

create op-stack 3 cells allot op-stack value op-point

: op-push  ( n - ) op-point dup cell+ to op-point ! ;
: op-pop   ( - n ) op-point cell- dup to op-point @ ;
: op-depth ( - n ) op-point op-stack - 2/ 2/ ;
: op-tos   ( - n ) op-point cell- @ ;
: op-2nd   ( - n ) op-point cell- cell- @ ;
: op-drop  ( - ) op-point cell- to op-point ;
: op-swap  ( - ) op-pop op-pop swap op-push op-push ;
: op-zero  ( - ) op-stack to op-point ;

create bt-stack 3 cells allot bt-stack value bt-point

: bt-push  ( n - ) bt-point dup cell+ to bt-point ! ;
: bt-pop   ( - n ) bt-point cell- dup to bt-point @ ;
: bt-depth ( - n ) bt-point bt-stack - 2/ 2/ ;
: bt-tos   ( - n ) bt-point cell- @ ;
: bt-2nd   ( - n ) bt-point cell- cell- @ ;
: bt-drop  ( - ) bt-point cell- to bt-point ;
: bt-swap  ( - ) bt-pop bt-pop swap bt-push bt-push ;
: bt-zero  ( - ) bt-stack to bt-point ;

: zero-stacks ( - ) do-zero op-zero bt-zero ;

\ ------------- Useful Stuff ---------------------------------------------------

: xt: ( - ) ' , ;

: via ( a n - ) cells + @ execute ;

: viatable ( - ) create here cell+ , does> @ swap via ;

: ;then ( orig - ) s" exit then" evaluate ; immediate

create asm-dict here 100 allot 100 0 fill

asm-dict value asm-here

: .ad ( - ) asm-dict 100 dump ;

: asm-allot ( n - ) +to asm-here ;

' here defer shere is shere
' allot defer sallot is sallot

' asm-here is shere
' asm-allot is sallot

: b, ( n - ) shere 1 sallot c! ;
: w, ( n - ) shere 2 sallot w! ;
: d, ( n - ) shere 4 sallot  ! ;

: 8* ( n - ) 2* 2* 2* ;
: 0< 0 < ;   \ fix this!

: 0c, ( a - ) c@ b, ;
: 1c@ ( a - b ) 1+ c@ ;
: 1c, ( a - ) 1c@ b, ;
: 2c@ ( a - b ) 1+ 1+ c@ ;
: 2c, ( a - ) 2c@ b, ;
: 3c@ ( a - b ) 1+ 1+ 1+ c@ ;
: 3c, ( a - ) 3c@ b, ;



\ ------------- Addressing Mode ------------------------------------------------

0 value bt-mode 0 value 32bit 1 value 16bit 2 value 08bit

: 32bits ( - ) 32bit bt-push ;
: [32bit] ( - ) 32bit to bt-mode ;
: 16bits ( - ) 16bit bt-push ;
: [16bit] ( - ) 16bit to bt-mode ;
: 08bits ( - ) 08bit bt-push ;

: 32bit? ( - ) bt-mode 32bit = if 66 b, then ;
: 16bit? ( - ) bt-mode 16bit = if 66 b, then ;

: addr, ( a - ) bt-mode 32bit = if d, ;then w, ;
: lit,  ( n - ) bt-mode 32bit = if d, ;then w, ;

: mem-mode ( - n ) 5 bt-mode + ;

\ ------------- opers -------------------------------------------------------

true value sasmfix

: sasm-stacks ( - )
 cr ." Do-stack:   " do-point do-stack - 2/ 2/ .
 cr ." Op-stack:   " op-depth .
 cr ." bt-stack: " bt-depth ;

: sasm-mode ( - )
   cr sasmfix if ." Prefix Mode" ;then ." Postfix Mode" ;

: prefix  ( - ) true  to sasmfix ;
: postfix ( - ) false to sasmfix ;

: .sasm ( - ) sasm-mode sasm-stacks
 cr ." Sys-stack:  " depth . ;

: asm: ( - ) also easm ;
: asm; ( - ) previous ;

0 value opcoxt
0 value opers

: exec-opco ( - )
   sasmfix if op-depth opers = if opcoxt execute then then ;

: oper-does   ( - ) dup @ do-push cell+ @ op-push ;

: oper ( n n2 - ) create , , does> oper-does ;

0 value nr      \ Normal register
1 value amem    \ Memory reference
2 value alit    \ Immediate Literal
3 value ba      \ Register ba offset memory reference
4 value sr      \ Segment register - cs, ss, ds, es, fs, gs

5 value creg    \ Control register
6 value dreg    \ Debug register
7 value treg    \ Test register
8 value freg    \ Floating point register

: nr-oper-32 ( n - ) nr create , ,
   does> oper-does 32bits exec-opco ;
: nr-oper-16 ( n - ) nr create , ,
   does> oper-does 16bits exec-opco ;
: nr-oper-08 ( n - ) nr create , ,
   does> oper-does 08bits exec-opco ;
: sr-oper ( n - ) sr create , ,
   does> oper-does 16bits exec-opco ;

0 value ba-off

: ba-oper ( n - ) ba create , ,
   does> oper-does 32bits to ba-off exec-opco ;

\ ------------- Control Codes --------------------------------------------------

: control ( n - ) do-push op-push bt-mode bt-push exec-opco ;

: byte ( - ) bt-drop 08bits ;
: word ( - ) bt-drop 16bits ;
: cell ( - ) bt-drop 32bits ;

: byte? ( n - ) -80 80 within ;
: word? ( n - ) -8000 8000 within ;

: litsize ( n - n b )
   dup byte? if 08bit ;then dup word? if 16bit ;then 32bit ;

create litsize-options xt: lit, xt: lit, xt: b,

: litsize, ( n - ) litsize litsize-options swap via ;

: (<begin>) ( - orig ) shere ;
: (<until>) ( orig - ) dup shere 1+ - dup byte?
   if b, drop exit then drop
   -1 sallot shere c@ 0f and 80 or 0f b, b,
   shere 4 + - d, ;

\ ------------- Errors ---------------------------------------------------------

: err ( - ) cr ." Assembler Error!" zero-stacks ;

\ ------------- Register Based Offset Stuff ------------------------------------

0 value whatreg
: rb-esp-d, ( n - ) 4 = if ba-off if -4 sallot shere @ 24 b,
   d, ;then 24 b, then ;
: rb-ebp-d, ( n - ) 5 = if ba-off 0= if shere 1- dup c@ 40
   or swap c! 00 b, then then ;
: rb-esp-b, ( n - ) 4 = if ba-off if shere 1- c@ 24 shere 1-
   c! b, ;then 24 b, then ;
: rb-ebp-b, ( n - ) 5 = if ba-off 0= if shere 1- dup c@ 40 or
   swap c! 00 b, then then ;

: rb-d,     ( n - ) d, whatreg dup rb-esp-d, rb-ebp-d, ;
: rb-b,     ( n - ) b, whatreg dup rb-esp-b, rb-ebp-b, ;
: rb-d-off  ( n n2 - ) 80 or b, dup 0< if -80000000 or
   then rb-d, ;
: rb-b-off  ( n n2 - ) 40 or b, dup 0< if 80 or then rb-b, ;

: rb-d      ( n n2 - ) over 0<> if rb-d-off ;then rb-d, drop ;
: rb-b      ( n n2 - ) over 0<> if rb-b-off ;then rb-b, drop ;
: rb-sort1  ( - n n2 f ) ba-off op-pop op-pop 8* or over
   byte? ;
: rb-sort2  ( - n n2 f ) ba-off op-pop 8* op-pop or over
   byte? ;
: rb-nr-ba  ( - ) op-tos to whatreg rb-sort1 if rb-b
   ;then rb-d ;
: rb-ba-nr  ( - ) op-2nd to whatreg rb-sort2 if rb-b
   ;then rb-d ;

: rb-bit? ( n - ) bt-mode <> if 67 b, then ;

\ ------------- Jump Table Nav Words -------------------------------------------

: 08op  ( - ) create ' , does> @ execute ;
: 16op  ( - ) create ' , does> 32bit? @ execute ;
: 32op  ( - ) create ' , does> 16bit? @ execute ;

: 08op2 ( b - ) create c, ' ,
   does> dup c@ swap 1+ @ execute ;
: 16op2 ( b - ) create c, ' ,
   does> 32bit? dup c@ swap 1+ @ execute ;
: 32op2 ( b - ) create c, ' ,
   does> 16bit? dup c@ swap 1+ @ execute ;

: via-bp ( - ) create ' , ' , ' , does> bt-pop via ;
: via-b1 ( - ) create ' , ' , ' , does> bt-tos via ;
: via-b2 ( - ) create ' , ' , ' , does> bt-2nd via ;
: via-dp ( - ) create ' , ' , ' , ' , ' , does> do-pop via ;

\ ------------- Hardware Stack -------------------------------------------------

: (push-nr)  ( - ) 50 op-pop + b, ;
: (push-mem) ( - ) ff b, 35 b, op-pop addr, ;
: (push-lit) ( b - ) b, op-pop d, ;
: (push-ba)  ( - ) ff b, 6 op-push rb-ba-nr ;
: (pop-nr)   ( - ) 58 op-pop + b, ;
: (pop-mem)  ( - ) 8f b, 5 b, op-pop addr, ;
: (pop-ba)   ( - ) 8f b, 0 op-push rb-ba-nr ;

16op push-nr-16  (push-nr)  32op push-nr-32  (push-nr)
16op push-mem-16 (push-mem) 32op push-mem-32 (push-mem)
16op push-ba-16  (push-ba)  32op push-ba-32  (push-ba)
16op pop-nr-16   (pop-nr)   32op pop-nr-32   (pop-nr)
16op pop-mem-16  (pop-mem)  32op pop-mem-32  (pop-mem)
16op pop-ba-16   (pop-ba)   32op pop-ba-32   (pop-ba)

6a 08op2 push-lit-08 (push-lit)
68 16op2 push-lit-16 (push-lit)
68 32op2 push-lit-32 (push-lit)

via-bp push-nr  push-nr-32  push-nr-16  err
via-bp push-mem push-mem-32 push-mem-16 err
via-bp push-lit push-lit-32 push-lit-16 push-lit-08
via-bp push-ba  push-ba-32  push-ba-16  err
via-bp pop-nr   pop-nr-32   pop-nr-16   err
via-bp pop-mem  pop-mem-32  pop-mem-16  err
via-bp pop-ba   pop-ba-32   pop-ba-16   err

create push-sr-options 0e c, 0 c, 16 c, 0 c, 1e c, 0 c, 06 c,
   0 c, 0f c, a0 c, 0f c, a8 c,
create pop-sr-options 0 c, 0 c, 17 c, 0 c, 1f c, 0 c, 07 c,
   0 c, 0f c, a1 c, 0f c, a9 c,

: pushpop-sr ( a - ) bt-drop op-pop 2* + dup c@ b, 1+ c@
   dup if b, ;then drop ;

: push-sr ( - ) push-sr-options pushpop-sr ;
: pop-sr  ( - ) pop-sr-options pushpop-sr ;

create push-options xt: push-nr xt: push-mem xt: push-lit
   xt: push-ba xt: push-sr
create pop-options  xt: pop-nr  xt: pop-mem  xt: err
   xt: pop-ba  xt: pop-sr

\ ------------- Port I/O -------------------------------------------------------

: (i/o-acc/edx) ( b - ) b, op-drop op-drop ;
: (in-acc-lit)  ( b - ) b, op-pop b, op-drop ;
: (out-lit-acc) ( b - ) b, op-drop op-pop b, ;

ec 08op2 in-al-dx    (i/o-acc/edx)
0ed 16op2 in-ax-dx    (i/o-acc/edx) ( Win32for used 'ed' )
0ed 32op2 in-eax-dx   (i/o-acc/edx) ( Win32for used 'ed' )
e4 08op2 in-al-lit   (in-acc-lit)
e5 16op2 in-ax-lit   (in-acc-lit)
e5 32op2 in-eax-lit  (in-acc-lit)
ee 08op2 out-dx-al   (i/o-acc/edx)
ef 16op2 out-dx-ax   (i/o-acc/edx)
ef 32op2 out-dx-eax  (i/o-acc/edx)
e6 08op2 out-lit-al  (out-lit-acc)
e7 16op2 out-lit-ax  (out-lit-acc)
e7 32op2 out-lit-eax (out-lit-acc)

via-bp in-acc-edx  in-eax-dx   in-ax-dx   in-al-dx
via-bp in-acc-lit  in-eax-lit  in-ax-lit  in-al-lit
via-bp out-edx-acc out-dx-eax  out-dx-ax  out-dx-al
via-bp out-lit-acc out-lit-eax out-lit-ax out-lit-al

create in-options  xt: in-acc-edx  xt: err xt: in-acc-lit
create out-options xt: out-edx-acc xt: err xt: out-lit-acc

\ ------------- Inc and Dec ----------------------------------------------------

: inc-nr-08 ( - ) fe b, c0 op-pop or b, ;
: dec-nr-08 ( - ) fe b, c0 op-pop or b, ;

: (inc-nr)  ( - ) 40 op-pop + b, ;
: (inc-mem) ( - ) 5 b, op-pop addr, ;
: (inc-ba)  ( - ) ff b, 0 op-push rb-ba-nr ;
: (dec-nr)  ( - ) 48 op-pop + b, ;
: (dec-mem) ( - ) b, op-pop addr, ;
: (dec-ba)  ( - ) ff b, 1 op-push rb-ba-nr ;

16op inc-nr-16 (inc-nr) 32op inc-nr-32 (inc-nr)
16op inc-ba-16 (inc-ba) 32op inc-ba-32 (inc-ba)
16op dec-nr-16 (dec-nr) 32op dec-nr-32 (dec-nr)
16op dec-ba-16 (dec-ba) 32op dec-ba-32 (dec-ba)

fe 08op2 inc-mem-08 (inc-mem)
ff 16op2 inc-mem-16 (inc-mem)
ff 32op2 inc-mem-32 (inc-mem)
fe 08op2 dec-mem-08 (dec-mem)
ff 16op2 dec-mem-16 (dec-mem)
ff 32op2 dec-mem-32 (dec-mem)

via-bp inc-nr  inc-nr-32  inc-nr-16  inc-nr-08
via-bp inc-mem inc-mem-32 inc-mem-16 inc-mem-08
via-bp inc-ba  inc-ba-32  inc-ba-16  err
via-bp dec-nr  dec-nr-32  dec-nr-16  dec-nr-08
via-bp dec-mem dec-mem-32 dec-mem-16 dec-mem-08
via-bp dec-ba  dec-ba-32  dec-ba-16  err

create inc-options xt: inc-nr xt: inc-mem xt: err xt: inc-ba
create dec-options xt: dec-nr xt: dec-mem xt: err xt: dec-ba

\ ------------- log2----------------------------------------------------------

: (log2-nr)   ( a - ) b, c@ 8* c0 or op-pop or b, ;
: log2-mem-32 ( a - ) f7 b, c@ 8* 5 or b, op-pop d, ;
: log2-ba-32  ( a - ) f7 b, drop 3 op-push rb-ba-nr ;

f6 08op2 log2-nr-08 (log2-nr)
f7 16op2 log2-nr-16 (log2-nr)
f7 32op2 log2-nr-32 (log2-nr)

via-bp log2-nr  log2-nr-32  log2-nr-16 log2-nr-08
via-bp log2-mem log2-mem-32 err        err
via-bp log2-ba  log2-ba-32  err        err

create log2-options xt: log2-nr xt: log2-mem xt: err
   xt: log2-ba

: log2-opco ( - ) create c, does> log2-options do-pop via ;

\ ------------- Logic1 ---------------------------------------------------------

: log-nr-nr    ( a - ) 0c, c0 op-pop 8* or op-pop or b, ;
: log-nr-mem   ( a - ) 1c, op-pop op-pop 8* 5 or b, d, ;
: log-eax-lit  ( a - ) 2c, op-pop lit, op-drop ;
: log-nr-lit-1 ( - n ) op-pop litsize 08bit = if 83 b,
   ;then 81 b, ;
: log-nr-lit-2 ( a - ) 3c@ 8* c0 or op-pop or b, ;
: log-nr-lit-0 ( a - ) log-nr-lit-1 swap log-nr-lit-2
   litsize, ;
: log-nr-lit   ( a - ) op-2nd if log-nr-lit-0
   ;then log-eax-lit ;
: log-nr-ba    ( a - ) 1c, rb-nr-ba ;
: log-mem-nr   ( a - ) 0c, op-pop op-pop swap 8* 5 or b, d, ;
: log-mem-lit  ( a - ) 81 b, 2c, op-pop op-pop d, d, ;
: log-ba-nr    ( a - ) 0c, rb-ba-nr ;
: log-ba-lit   ( a - ) ;

via-dp log-nr-? log-nr-nr log-nr-mem log-nr-lit log-nr-ba err
via-dp log-mem-? log-mem-nr err log-mem-lit err err
via-dp log-ba-? log-ba-nr  err log-ba-lit  err err

create log-options xt: log-nr-? xt: log-mem-? xt: err
   xt: log-ba-?

: log-opco ( n n2 n3 n4 - ) create c, c, c, c,
   does> log-options do-swap do-pop via bt-drop bt-drop ;

\ ------------- Bit Shifting ---------------------------------------------------

: (bits-nr)      ( a - ) b, op-drop c@ 8* e0 or op-pop or b, ;
: bits-nr-cl     ( a - ) d3 (bits-nr) ;
: bits-nr-1      ( a - ) d1 (bits-nr) ;

: (bits-nr-lit)  ( a - ) c1 b, op-pop swap c@ 8* e0 or
   op-pop or b, b, ;
: bits-nr-lit    ( a - ) op-tos 1 = if bits-nr-1
   ;then (bits-nr-lit) ;

: (bits-mem)     ( a - ) b, c@ 8* 5 or b, op-drop op-pop d, ;

: bits-mem-cl    ( a - ) d3 (bits-mem) ;
: bits-mem-1     ( a - ) d1 (bits-mem) ;
: (bits-mem-lit) ( a - ) c1 b, c@ 8* 5 or b, op-pop
   op-pop d, b, ;
: bits-mem-lit   ( a - ) op-tos 1 = if bits-mem-1
   ;then (bits-mem-lit) ;
: bits-b      ( n - ) ba-off swap over byte? if rb-b
   ;then rb-d ;

via-dp bits-nr-?  bits-nr-cl  err bits-nr-lit  err err
via-dp bits-mem-? bits-mem-cl err bits-mem-lit err err

: (bits-ba)      ( a - ) b, op-drop c@ 8* op-pop or bits-b ;

: bits-ba-cl     ( a - ) d3 (bits-ba) ;
: bits-ba-1      ( a - ) d1 (bits-ba) ;
: (bits-ba-lit)  ( a - ) c1 b, op-pop swap c@ 8*
   op-pop or bits-b b, ;
: bits-ba-lit    ( a - ) op-tos 1 = if bits-ba-1
   ;then (bits-ba-lit) ;

create bits-ba-options
 xt: bits-ba-cl
 xt: err
 xt: bits-ba-lit
 xt: err

: bits-ba-? ( a - ) op-2nd to whatreg
   bits-ba-options do-pop via ;

create bits-options xt: bits-nr-? xt: bits-mem-? xt: err
   xt: bits-ba-?

: bits-opco ( n - ) create c,
   does> bits-options do-swap do-pop via bt-drop bt-drop ;

\ ------------- Xchg -----------------------------------------------------------

: xchg-eax-nr  ( - ) 90 op-pop + op-pop + b, ;
: (xchg-nr-nr) ( - ) 87 b, op-pop op-pop 8* or c0 or b, ;
: xchg-nr-nr   ( - ) op-tos 0= op-2nd 0= or if xchg-eax-nr
   ;then (xchg-nr-nr) ;
: xchg-nr-mem  ( - ) 87 b, op-pop op-pop 8* 5 or b, d, ;
: xchg-nr-ba   ( - ) 87 b, rb-nr-ba ;
: xchg-mem-nr  ( - ) 87 b, op-pop 8* 5 or b, op-pop d, ;
: xchg-ba-nr   ( - ) 87 b, rb-ba-nr ;

via-dp xchg-nr-?  xchg-nr-nr  xchg-nr-mem err xchg-nr-ba err
via-dp xchg-mem-? xchg-mem-nr err err err err
via-dp xchg-ba-?  xchg-ba-nr  err err err err

create xchg-options xt: xchg-nr-? xt: xchg-mem-? xt: err
   xt: xchg-ba-?

\ ------------- Mov ------------------------------------------------------------

: (mov-nr-nr)   ( b - ) b, c0 op-pop 8* or op-pop or b, ;
: (_mov-nr-mem) ( b - ) b, op-pop op-pop 8* mem-mode or b,
   addr, ;
: (mov-acc-mem) ( b - ) b, op-pop addr, op-drop ;
: (mov-nr-lit)  ( b - ) op-pop swap op-pop or b, d, ;
: (mov-nr-sr)   ( - ) 8c b, c0 op-pop 8* or op-pop or b, ;
: (_mov-mem-nr) ( b - ) b, op-pop 8* mem-mode or b, op-pop
   addr, ;
: (mov-mem-acc) ( b - ) b, op-drop op-pop addr, ;
: (mov-mem-lit) ( b - ) b, mem-mode b, op-pop op-pop addr,
   lit, ;
: (mov-mem-sr)  ( - ) 8c b, op-pop 8* mem-mode or b, op-pop
   addr, ;
: (mov-sr-nr)   ( - ) 8e b, c0 op-pop or op-pop 8* or b, ;
: (mov-sr-mem)  ( - ) 8e b, op-pop op-pop 8* mem-mode or b,
   addr, ;
: (mov-ba-nr)   ( - ) bt-2nd rb-bit? 89 b, rb-ba-nr ;

88 08op2 mov-nr-nr-08 (mov-nr-nr)
89 16op2 mov-nr-nr-16 (mov-nr-nr)
89 32op2 mov-nr-nr-32 (mov-nr-nr)

via-b1 mov-nr-nr mov-nr-nr-32 mov-nr-nr-16 mov-nr-nr-08

8a 08op2 mov-nr-mem-08 (_mov-nr-mem)
8b 16op2 mov-nr-mem-16 (_mov-nr-mem)
8b 32op2 mov-nr-mem-32 (_mov-nr-mem)

via-b2 (mov-nr-mem) mov-nr-mem-32 mov-nr-mem-16 mov-nr-mem-08

a0 08op2 mov-acc-mem-08 (mov-acc-mem)
a1 16op2 mov-acc-mem-16 (mov-acc-mem)
a1 32op2 mov-acc-mem-32 (mov-acc-mem)
b0 08op2 mov-nr-lit-08 (mov-nr-lit)
b8 16op2 mov-nr-lit-16 (mov-nr-lit)
b8 32op2 mov-nr-lit-32 (mov-nr-lit)

via-b2 mov-acc-mem mov-acc-mem-32 mov-acc-mem-16 mov-acc-mem-08

: mov-nr-mem ( - ) op-2nd if (mov-nr-mem) ;then mov-acc-mem ;

via-b1 mov-nr-lit mov-nr-lit-32 mov-nr-lit-16 mov-nr-lit-08

: mov-nr-ba-08 ( - ) 8a b, rb-nr-ba ;
: mov-nr-ba-16 ( - ) 32bit? bt-tos rb-bit? 8b b, rb-nr-ba ;
: mov-nr-ba-32 ( - ) 16bit? bt-tos rb-bit? 8b b, rb-nr-ba ;

via-b2 mov-nr-ba mov-nr-ba-32 mov-nr-ba-16 mov-nr-ba-08

16op mov-nr-sr-16 (mov-nr-sr)
32op mov-nr-sr-32 (mov-nr-sr)

via-b2 mov-nr-sr mov-nr-sr-32 mov-nr-sr-16 err
via-dp mov-nr-? mov-nr-nr mov-nr-mem mov-nr-lit mov-nr-ba mov-nr-sr

88 08op2 mov-mem-nr-08 (_mov-mem-nr)
89 16op2 mov-mem-nr-16 (_mov-mem-nr)
89 32op2 mov-mem-nr-32 (_mov-mem-nr)

via-b1 (mov-mem-nr) mov-mem-nr-32 mov-mem-nr-16 mov-mem-nr-08

a2 08op2 mov-mem-acc-08 (mov-mem-acc)
a3 16op2 mov-mem-acc-16 (mov-mem-acc)
a3 32op2 mov-mem-acc-32 (mov-mem-acc)

via-b1 mov-mem-acc mov-mem-acc-32 mov-mem-acc-16 mov-mem-acc-08

: mov-mem-nr   ( - ) op-tos if (mov-mem-nr)
   ;then mov-mem-acc ;

c6 08op2 mov-mem-lit-08 (mov-mem-lit)
c7 16op2 mov-mem-lit-16 (mov-mem-lit)
c7 32op2 mov-mem-lit-32 (mov-mem-lit)

via-b2 mov-mem-lit mov-mem-lit-32 mov-mem-lit-16 mov-mem-lit-08

16op mov-mem-sr-16 (mov-mem-sr)
32op mov-mem-sr-32 (mov-mem-sr)

via-b1 mov-mem-sr mov-mem-sr-32 mov-mem-sr-16 err
via-dp mov-mem-? mov-mem-nr err mov-mem-lit err mov-mem-sr

16op mov-sr-nr-16 (mov-sr-nr)
32op mov-sr-nr-32 (mov-sr-nr)

via-b1 mov-sr-nr mov-sr-nr-32 mov-sr-nr-16 err

16op mov-sr-mem-16 (mov-sr-mem)
32op mov-sr-mem-32 (mov-sr-mem)
: mov-sr-ba ( - ) ;

via-b1 mov-sr-mem mov-sr-mem-32 mov-sr-mem-16 err
via-dp mov-sr-? mov-sr-nr mov-sr-mem err mov-sr-ba err

: mov-ba-nr-08 ( - ) 88 b, rb-ba-nr ;

16op mov-ba-nr-16 (mov-ba-nr)
32op mov-ba-nr-32 (mov-ba-nr)

via-b1 mov-ba-nr mov-ba-nr-32 mov-ba-nr-16 mov-ba-nr-08

: mov-ba-sr ( - ) ;
: mov-ba-lit ( - ) ;

via-dp mov-ba-? mov-ba-nr err mov-ba-lit err mov-ba-sr

create mov-options
 xt: mov-nr-?         \ nr mem lit ba sr
 xt: mov-mem-?          \ nr     lit       sr
 xt: err
 xt: mov-ba-?        \ nr               ????
 xt: mov-sr-?         \ nr mem     ?????

\ ------------- Individual opcos ---------------------------------------------

: solo-opco ( n - ) create c, does> 0c, ;
: tool-opco ( a - ) create , does> @ do-pop via ;

\ ------------- Threading ------------------------------------------------------

: thread-nr ( a - ) ff b, c@ 8* c0 or op-pop or b, ;
: thread-mem  ( a - ) 1c, op-pop shere cell+ - d, ;

create thread-options xt: thread-nr xt: thread-mem

: thread-opco ( n - ) create c, c,
   does> thread-options do-pop via bt-drop ;

\ ------------------------------------------------------------------------------

: prefix-opco ( a - ) dup cell+ @ swap @
   dup to opers if to opcoxt ;then execute ;

: postfix-opco ( a - ) dup @ 2 = if do-swap op-swap bt-swap
   then cell+ @ execute ;

: opcode ( xt ops - ) create , , does> sasmfix if prefix-opco
   ;then postfix-opco ;

\ ------------- Labels ---------------------------------------------------------

create lx 10 cells allot

: ln ( - ) create , does> @ lx + shere swap ! 0 b, ;
: ln: ( - ) create , does> @ lx + @ shere over - 1- swap c! ;

\ ------------- opco Primitives ----------------------------------------------

02 15 13 11 log-opco (adc)
00 05 03 01 log-opco (add)
04 25 23 21 log-opco (and)
07 3d 3b 39 log-opco (cmp)
01 0d 0b 09 log-opco (or)
03 1d 1b 19 log-opco (sbb)
05 2d 2b 29 log-opco (sub)
06 35 33 31 log-opco (xor)
        04 log2-opco (mul)
        06 log2-opco (div)
        03 log2-opco (neg)
        02 log2-opco (not)
        07 log2-opco (idiv)
        05 log2-opco (imul)
        04 bits-opco (shl)
        05 bits-opco (shr)
        07 bits-opco (sar)
   e9 04 thread-opco (jmp)
   e8 02 thread-opco (call)
        c3 solo-opco (ret)
        fa solo-opco (cli)
        fb solo-opco (sti)
        fc solo-opco (cld)
        fd solo-opco (std)
        ad solo-opco (lodsd)
        ac solo-opco (lodsb)
        ab solo-opco (stosd)
        aa solo-opco (stosb)
        ae solo-opco (scasb)
        a6 solo-opco (cmpsb)
        f2 solo-opco (repne)
        f3 solo-opco (repe)
        99 solo-opco (cdq)
        60 solo-opco (pushad)
        61 solo-opco (popad)
        f3 solo-opco (rep)
        a5 solo-opco (movsd)
        a4 solo-opco (movsb)

77 solo-opco (ja)
73 solo-opco (jae)
72 solo-opco (jb)
76 solo-opco (jbe)
72 solo-opco (jc)
e3 solo-opco (jcxz)
e3 solo-opco (jecxz)
74 solo-opco (je)
74 solo-opco (jz)
7f solo-opco (jg)
7d solo-opco (jge)
7c solo-opco (jl)
7e solo-opco (jle)
76 solo-opco (jna)
72 solo-opco (jnae)
73 solo-opco (jnb)
77 solo-opco (jnbe)
73 solo-opco (jnc)
75 solo-opco (jne)
7e solo-opco (jng)
7c solo-opco (jnge)
7d solo-opco (jnl)
7f solo-opco (jnle)
71 solo-opco (jno)
7b solo-opco (jnp)
79 solo-opco (jns)
75 solo-opco (jnz)
70 solo-opco (jo)
7a solo-opco (jp)
7a solo-opco (jpe)
7b solo-opco (jpo)
78 solo-opco (js)

push-options tool-opco (push)
 pop-options tool-opco (pop)
 inc-options tool-opco (inc)
 dec-options tool-opco (dec)

: (mov)  mov-options do-swap do-pop via bt-drop bt-drop ;
: (xchg) xchg-options do-swap do-pop via bt-drop bt-drop ;
: (in)   in-options do-pop do-drop bt-drop via ;
: (out)  out-options do-drop do-pop via bt-drop ;


\ ------------- opcos --------------------------------------------------------

also easm definitions

: [32bit] ( - ) 32bit to bt-mode ;
: [16bit] ( - ) 16bit to bt-mode ;

: # ( n - ) alit control ;
: & ( a - ) amem control ;


0 nr-oper-32 eax 0 nr-oper-16 ax 0 nr-oper-08 al
1 nr-oper-32 ecx 1 nr-oper-16 cx 1 nr-oper-08 cl
2 nr-oper-32 edx 2 nr-oper-16 dx 2 nr-oper-08 dl
3 nr-oper-32 ebx 3 nr-oper-16 bx 3 nr-oper-08 bl
4 nr-oper-32 esp 4 nr-oper-16 sp
5 nr-oper-32 ebp 5 nr-oper-16 bp
6 nr-oper-32 esi 6 nr-oper-16 si
7 nr-oper-32 edi 7 nr-oper-16 di

0 sr-oper es
1 sr-oper cs
2 sr-oper ss
3 sr-oper ds
4 sr-oper fs
5 sr-oper gs

0 ba-oper [eax]
1 ba-oper [ecx]
2 ba-oper [edx]
3 ba-oper [ebx]
4 ba-oper [esp]
5 ba-oper [ebp]
6 ba-oper [esi]
7 ba-oper [edi]

: [eax*4] ( - ) shere 1- c@ dup f0 and 4 or shere 1- c!
   0f and 80 or shere c! 1 sallot ;

\ ------------------------------------------------------------------------------

0 nr-oper-32 t
1 nr-oper-32 x
2 nr-oper-32 w
3 nr-oper-32 y
4 nr-oper-32 rp
5 nr-oper-32 up
6 nr-oper-32 sp
7 nr-oper-32 ap

0 ba-oper [t]
1 ba-oper [x]
2 ba-oper [w]
3 ba-oper [y]
4 ba-oper [rp]
5 ba-oper [up]
6 ba-oper [sp]
7 ba-oper [ap]

: [t*4] [eax*4] ;

\ ------------------------------------------------------------------------------

' (adc)   2 opcode adc
' (add)   2 opcode add
' (and)   2 opcode and
' (cmp)   2 opcode cmp
' (or)    2 opcode or
' (sbb)   2 opcode sbb
' (sub)   2 opcode sub
' (xor)   2 opcode xor

' (mul)   1 opcode mul
' (div)   1 opcode div
' (neg)   1 opcode neg
' (not)   1 opcode not
' (idiv)  1 opcode idiv
' (imul)  1 opcode imul

' (shl)   2 opcode shl
' (shr)   2 opcode shr
' (sar)   2 opcode sar
' (jmp)   1 opcode jmp
' (call)  1 opcode call
' (ret)   0 opcode ret
' (cli)   0 opcode cli
' (sti)   0 opcode sti
' (cld)   0 opcode cld
' (std)   0 opcode std
' (pushad) 0 opcode pushad
' (popad) 0 opcode popad
' (lodsd) 0 opcode lodsd
' (lodsb) 0 opcode lodsb
' (stosd) 0 opcode stosd
' (stosb) 0 opcode stosb
' (scasb) 0 opcode scasb
' (cmpsb) 0 opcode cmpsb
' (repne) 0 opcode repne
' (repne) 0 opcode repnz
' (repe)  0 opcode repe
' (cdq)   0 opcode cdq
' (rep)   0 opcode rep
' (movsd) 0 opcode movsd
' (movsb) 0 opcode movsb

' (ja)    0 opcode ja
' (jae)   0 opcode jae
' (jb)    0 opcode jb
' (jbe)   0 opcode jbe
' (jc)    0 opcode jc
' (jcxz)  0 opcode jcxz
' (jecxz) 0 opcode jecxz
' (je)    0 opcode je
' (jz)    0 opcode jz
' (jg)    0 opcode jg
' (jge)   0 opcode jge
' (jl)    0 opcode jl
' (jle)   0 opcode jle
' (jna)   0 opcode jna
' (jnae)  0 opcode jnae
' (jnb)   0 opcode jnb
' (jnbe)  0 opcode jnbe
' (jnc)   0 opcode jnc
' (jne)   0 opcode jne
' (jng)   0 opcode jng
' (jnge)  0 opcode jnge
' (jnl)   0 opcode jnl
' (jnle)  0 opcode jnle
' (jno)   0 opcode jno
' (jnp)   0 opcode jnp
' (jns)   0 opcode jns
' (jnz)   0 opcode jnz
' (jo)    0 opcode jo
' (jp)    0 opcode jp
' (jpe)   0 opcode jpe
' (jpo)   0 opcode jpo
' (js)    0 opcode js

' (push)  1 opcode push
' (pop)   1 opcode pop
' (inc)   1 opcode inc
' (dec)   1 opcode dec

' (mov)   2 opcode mov
' (xchg)  2 opcode xchg
' (in)    2 opcode in
' (out)   2 opcode out

: insb 6c b, ;
: insw 66 b, 6d b, ;
: insd 6d b, ;
: outsb 6e b, ;
: outsw 66 b, 6f b, ;
: outsd 6f b, ;

\ ------------- Forth-like Control Structures ----------------------------------

: =,   ( - ) jne ;
: <>,  ( - ) je  ;
: <,   ( - ) jg  ;
: <=,  ( - ) jge ;
: >,   ( - ) jl  ;
: >=,  ( - ) jle ;
: 0=,  ( - ) jnz ;
: 0<>, ( - ) jz  ;
: 0<,  ( - ) jns ;
: 0>,  ( - ) js  ;


hex

: <if>   ( - orig ) shere 0 b, ;
: <else> ( orig - orig2 ) eb b, shere over - swap c!
   shere 0 b, ;
: <then> ( orig - ) shere over - 1- swap c! ;

: <begin> ( - orig ) (<begin>) ;
: <until> ( orig - ) (<until>) ;

: &call call & ;
: &jmp  jmp & ;

0 ln l1 0 ln: l1:
4 ln l2 4 ln: l2:
8 ln l3 8 ln: l3:

\ only forth definitions also sasm
\
\ : code     ( - ) header, also assembler ;
\ : end-code ( - ) previous ;
\ ' prefix defer prefix is prefix
\ ' postfix defer postfix is postfix
\ ' here is shere
\ ' allot is sallot


