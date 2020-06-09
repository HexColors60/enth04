\ META.F

\ A crude Meta Compiler to build the Enth kernel. Run successfully in
\ Win32forth 4.2 Build 0671. Implements some optimization inlining some code
\ words and control structures.

\ Be warned: It is not complete.

hex only forth definitions vocabulary meta also meta definitions

: ;then ( orig - ) postpone exit postpone then ; immediate

: taligned  ( n - n' ) 1- 4 2dup mod - + ;

30000 allocate drop taligned value fspace

10000 value torigin

variable a
: a! a ! ;
: a@ a @ ;
: !a a @ ! ;
: @a a @ @ ;
: !a+ a @ ! 4 a +! ;
: @a+ a @ @ 4 a +! ;

fspace torigin + value tspace
tspace 8000 + value hspace

tspace value there
hspace value hhere
variable enthlink 0 enthlink !
variable hidelink 0 hidelink !
variable fluxlink 0 fluxlink !
variable macrolink 0 macrolink !


variable inlineable

: tswap     ( - ) there hhere to there to hhere tspace hspace to tspace to hspace ;
: tallot    ( n - ) +to there ;
: tc,       ( n - ) there 1 tallot c! ;
: t,        ( n - ) there 4 tallot  ! ;
: tnops     ( n - ) dup if 0 do 90 tc, loop exit then drop ;
: talign-1  ( - ) there dup taligned swap - dup if 1- tnops else drop 3 tnops then ;
: talign    ( - ) there dup taligned swap - tnops ;
: tlink,    ( - ) enthlink @ t, there fspace - enthlink ! ;
: >uc       ( a - ) dup c@ dup 61 7b within if 20 - swap c! ;then 2drop ;
: >ucase    ( ca - ca ) dup dup c@ 0 do dup i + 1+ >uc loop drop ;
: tname,    ( - ) bl word >ucase dup c@ 1+ there swap dup tallot cmove talign ;
: tprec,    ( - ) 0 tc, ;
: theader,  ( - ) there fspace - tswap talign-1 tprec, tlink, tname, t, tswap ;
: tnfa>cfa  ( n - ) dup c@ 1+ taligned + @ ;
: tnfa>pfa  ( a - a' ) cell- 1- ;
: equ       ( n - ) value ;
: place     ( ca ca2 u2 - ) >r swap r@ over c! 1+ r> cmove ;
: append    ( ca ca2 u2 - ) 2 pick dup c@ swap 1+ + swap dup >r cmove r> over c@ + swap c! ;
: tcompile, ( a - ) e8 tc, there cell+ - t, ;

variable tstate 0 tstate !

: target-version ( - ) create , does> @ ;

create codebuffer 100 allot

: target-label ( - )
        codebuffer s" target-version " place
        codebuffer enthlink @ fspace + count append
        there codebuffer count evaluate
        \ enthlink @ fspace + count cr type
        ;

: .stack ( - ) cr ." sys-stack:  " depth . ;

also sasm

: code     ( - ) theader, target-label asm: ;
: icode    ( - ) there inlineable ! code ;
: c;       ( - ) asm; ;
: end-code ( - )
        inlineable @
        if      enthlink @ fspace + tnfa>pfa dup c@
                there 1- inlineable @ - or swap c!
                false inlineable !
        then    asm; \ .stack
        ;

: t: ( - ) theader, target-label true tstate ! ;
: (t;) ( - ) false tstate ! ; \ cr ." sys-stack:  " depth . ;
: t; ( - ) c3 tc, (t;) ;
: tt; ( - ) e9 there 5 - c! (t;) ;

previous

0 value fileid

: write-binary ( ca u - )
        r/w create-file drop to fileid
        tspace hhere over - fileid write-file drop
        fileid close-file drop ;

: tcast ( - a ) there 04 tallot ;
: tsnag ( a - ) there over - swap ! ;
: tbite ( a - a' ) tcast swap tsnag ;
: thook ( a - ) there - t, ;

: <snag> ( a - ) there over - swap ! ;

: <if> ( - orig ) 0fadc009 t, 84 tc, ;
: <else> ( orig - orig2 ) e9 tc, ;
: <then> ( orig - ) there over - cell- swap ! ;
: <mark> ( - orig ) there 4 tallot ;
: <resolve> ( dest - ) there cell+ - t, ;

: tliteral ( n - ) 83 tc, ee tc, 04 tc, 89 tc, 06 tc, b8 tc, t, ;

: { also forth ;
: } previous ;

hex only forth definitions also sasm also meta definitions

wordlist value ihostx
wordlist value ehostx
wordlist value ohostx
wordlist value enthx

: enth  ( - ) get-order >r drop enthx  r> set-order ;
: ehost ( - ) get-order >r drop ehostx r> set-order ;
: ihost ( - ) get-order >r drop ihostx r> set-order ;
: ohost ( - ) get-order >r drop ohostx r> set-order ;

' there is shere
' tallot is sallot

: .ms tspace 100 dump ;

also easm

: pushd ( - ) sub sp 4 # mov 0 [sp] t ;
: popd ( - ) lodsd ;

: tcb-var ( n - ) code   sub sp 4 #   mov 0 [sp] t   mov t up   add t #   ret end-code ;

previous

decimal

: hide noop ;

00
dup constant tcb>actlink  hide cell+    \ Active Tasks Ring Link Field
dup constant tcb>base     hide cell+    \ Numeric Radix
dup constant tcb>sp       hide cell+    \ Parameter Stack Pointer
                               256 +
dup constant tcb>sp0      hide          \ Parameter Stack Base
                               256 +
dup constant tcb>rp0      hide          \ Return Stack Base
dup constant tcb>rp       hide cell+    \ Return Stack Pointer
dup constant tcb>hand     hide cell+    \ Error Handler
dup constant tcb>areg     hide cell+    \ Address Register
dup constant tcb>dp       hide cell+    \ Dictionary Pointer
dup constant tcb>dp0      hide cell+    \ Dictionary Base
dup constant tcb>hp       hide cell+    \ Header Pointer
dup constant tcb>hp0      hide cell+    \ Header Base
dup constant tcb>enth     hide cell+    \ Forth Wordlist
dup constant tcb>flux     hide cell+    \ Flux Wordlist
dup constant tcb>macro    hide cell+    \ Macro Wordlist
dup constant tcb>state    hide cell+    \ Compiler State
dup constant tcb>blk      hide cell+    \ Block
dup constant tcb>sblk     hide cell+    \ Superblock Address
dup constant tcb>tib      hide cell+    \ Source Buffer
dup constant tcb>#tib     hide cell+    \ Source Buffer Length
dup constant tcb>in       hide cell+    \ Source Pointer
dup constant tcb>sid      hide cell+    \ Source ID
dup constant tcb>hist     hide cell+    \ History
dup constant tcb>hld      hide 40  +    \ Hold Pointer & Number Conversion Buffer (36 bytes)
dup constant tcb>spad     hide 256 +    \ Source String Buffer (256 bytes)
dup constant tcb>current  hide cell+    \ Definitions Wordlist
dup constant tcb>search   hide cell+    \ Search Length
dup constant tcb>swb      hide 64  +    \ Search Order (64 bytes = 16 wordlists)
dup constant tcb>mark     hide cell+    \ Dictionary Marker
dup constant tcb>finish   hide cell+
dup constant tcb>dropdup  hide cell+
dup constant tcb>nipdup   hide cell+
dup constant tcb>p        hide cell+
dup constant tcb>sib      hide cell+
dup constant tcb>children hide cell+
dup constant tcb>kid      hide cell+
dup constant tcb>memory   hide cell+

dup constant tcb>decision hide 64  +

drop

hex

only forth also meta definitions

variable last

create now 100 allot

: nextword ( - )
        bl word dup c@ 0=
        if      drop refill drop bl word
        then    >ucase count now 2dup c! 1+ swap cmove ;

: sign ( ca u - ca u m ) over c@ 2d = if 1- >r 1+ r> -1 else 1 then ;

: tinterpret ( - )
        begin   nextword \ now count type
                now count ihostx search-wordlist
                if      execute
                else    now count ohostx search-wordlist
                        if      execute
                        else    now count enthx search-wordlist
                                if      execute tcompile,
                                else    0 0 now count sign >r >number 0=
                                        if      drop d>s r> * tliteral
                                        else    now count type ."  - what?" abort
                                        then
                                then
                        then
                then
        \ cr now count type .stack
        tstate @ 0=
        until ;

: meta-order only forth also sasm also meta also ehost also enth definitions previous ;

: tcompile ( - ) only enth evaluate tcompile, meta-order ;

: t' ( - a ) bl word count enthx search-wordlist if execute fspace - then ;

: tcreate ( - )
        talign-1 t: s" dovar" tcompile
        only meta also enth also ehost definitions
        codebuffer s" target-version " place
        codebuffer enthlink @ fspace + count append
        there fspace - codebuffer count evaluate meta-order (t;) ;

: ts' ( - ) s" (s')" tcompile [char] " word dup c@ 1+ there swap dup tallot cmove ;

: drop,  ad tc, ;
: dup,   83 tc, ee tc, 04 tc, 89 tc, 06 tc, ;
: nip,   83 tc, c6 tc, 04 tc, ;

also ohost definitions previous

: 1+    40 tc, ;
: 1-    48 tc, ;
: drop  drop, ;
: dup   dup, ;
: swap  068bc289 t, 89 tc, 16 tc, ;
: @     8b tc, 00 tc, ;
: a!    89 tc, c7 tc, drop, ;
: a@    dup, 89 tc, f8 tc, ;
: !     1089168b t, drop, drop, ;
: c@    8ac03193 t, 03 tc, ;
: c!    1088168b t, drop, drop, ;
: +!    1001168b t, drop, drop, ;
: *     91 tc, drop, f7 tc, e1 tc, ;
: push  50 tc, drop, ;
: pop   dup, 58 tc, ;
: >r    50 tc, drop, ;
: r>    dup, 58 tc, ;
: +     03 tc, 06 tc, nip, ;
: -     29 tc, 06 tc, drop, ;
: cell- 2d tc, 4 t, ;
: cell+ 05 tc, 4 t, ;

also ehost definitions previous

also sasm
: asm: ( - ) asm: ;
: asm; ( - ) asm; ;
: call: ( a - ) asm; nextword now count tcompile asm: ;

previous

: allot     ( n - ) tallot ;
: here      ( - a ) there fspace - ;
: ,         ( n - ) t, ;
: c,        ( c - ) tc, ;
: !         ( n a - ) fspace + ! ;
: @         ( a - n ) fspace + @ ;
: c!        ( c a - ) fspace + c! ;
: c@        ( a - c ) fspace + c@ ;
: +         ( n n2 - n3 ) + ;
: -         ( n n2 - n3 ) - ;
: cells     ( n - n' ) 2* 2* ;
: constant  ( n - ) t: s" doval" tcompile t, (t;) ;
: value     ( n - ) t: s" doval" tcompile t, (t;) ;
: dovar       ( - ) t: s" dovar" tcompile (t;) ;
: defer     ( - ) t: s" noop" tcompile tt; ;
: immediate ( - ) enthlink @ fspace + 1- cell- dup c@ 80 or swap c! ;
: create    ( - ) tcreate ;
: stack     ( n - ) cells dup there cell+ + t, tallot ;
: variable  ( - ) tcreate 0 t, ;
: '         ( - xt ) t' ;
: ]         ( - ) true tstate ! tinterpret meta-order ;
: .(        ( - ) .( ;
: hex       ( - ) hex ;
: decimal   ( - ) decimal ;
: binary    ( - ) binary ;
: to        ( n - ) t' tstate @ if 1+ cell+ tliteral s" !" tcompile else fspace + 1+ cell+ ! then ;
: +to       ( n - ) t' tstate @ if 1+ cell+ tliteral s" +!" tcompile else fspace + 1+ cell+ +! then ;
: is        ( a - ) t' fspace + swap fspace + swap 1+ tuck cell+ - swap ! ;
: hide      ( - ) enthlink @ fspace + cell- dup @ enthlink ! hidelink @ over ! cell+ fspace - hidelink ! ;
: fhide      ( - ) enthlink @ fspace + cell- dup @ enthlink ! fluxlink @ over ! cell+ fspace - fluxlink ! ;
: mhide      ( - ) enthlink @ fspace + cell- dup @ enthlink ! macrolink @ over ! cell+ fspace - macrolink ! ;
: inline    ( - ) enthlink @ fspace + 1- cell- dup c@ 7e or swap c! ;
: user      ( n - ) tcb-var ;
: cell+     ( n - n' ) 4 + ;
: cell-     ( n - n' ) 4 - ;
: dup       ( n - n n ) dup ;
: drop      ( n - ) drop ;
: latest    ( - a ) enthlink fspace - ;

: :         ( - ) t: tinterpret meta-order ;

also ihost definitions previous

: if      ( - orig ) <if> <mark> ;
: then    ( orig - ) <then> ;
: else    ( orig - orig2 ) <else> <mark> swap <then> ;
: exit    ( - ) c3 tc, ;
: ;then   ( - ) c3 tc, <then> ;
: exit?   ( - ) <if> <mark> c3 tc, <then> ;
: leave?  ( - ) <if> <mark> s" leave" tcompile <then> ;
: begin   ( - dest ) there ;
: until   ( dest - ) <if> <resolve> ;
: again   ( dest - ) <else> <resolve> ;
: while   ( dest - orig dest ) <if> <mark> swap ;
: repeat  ( orig dest - ) <else> <resolve> <then> ;
: for     ( - dest ) 50 tc, drop, there ;
: next    ( dest - ) ff tc, 0c tc, 24 tc, 0f tc, 85 tc, <resolve> 83 tc, c4 tc, 04 tc, ;
: case    ( - case-sys ) false ;
: of      ( - of-sys ) s" (of)" tcompile <mark> ;
: endof   ( case-sys of-sys - case-sys2 ) s" (jmp)" tcompile <mark> swap <snag> swap 1+ ;
: endcase ( case-sys - ) s" drop" tcompile 0 ?do <snag> loop ;
: do      ( - orig orig2 ) s" (do)" tcompile tcast there ;
: ?do     ( - orig orig2 ) s" (?do)" tcompile tcast there ;
: loop    ( orig orig2 - ) s" (loop)" tcompile thook tsnag ;
: +loop   ( orig orig2 - ) s" (+loop)" tcompile thook tsnag ;
: [']     ( - ) t' tliteral ;
: to      ( n - ) t' tstate @ if 1+ cell+ tliteral s" !" tcompile else fspace + 1+ cell+ ! then ;
: +to     ( n - ) t' tstate @ if 1+ cell+ tliteral s" +!" tcompile else fspace + 1+ cell+ +! then ;
: does>   ( - ) s" (does>)" tcompile s" pop" tcompile ;
: literal ( - ) tliteral ;
: s"      ( - ) ts' ;
: ."      ( - ) ts' s" type" tcompile ;
: [       ( - ) false tstate ! meta-order ;
: [char]  ( - c ) char tliteral ;
: (       ( - ) postpone ( ;
: \       ( - ) postpone \ ;
: ;       ( - ) t; ;

: postpone ( - )
        nextword now count ihostx search-wordlist
        if      drop now count enthx search-wordlist
                if      execute tcompile,
                else    now count type ."  - what?" abort
                then
        else    now count enthx search-wordlist
                if      execute fspace - tliteral s" compile," tcompile
                else    now count type ."  - what?" abort
                then
        then    ;


meta-order

