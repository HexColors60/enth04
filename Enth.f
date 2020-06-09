\ ENTH.F

[32bit] prefix decimal

0 ,

code DOVAR ( - a )
        sub esi 4 #
        mov 0 [esi] eax
        pop eax
        ret end-code hide

code DOVAL ( - n )
        sub esi 4 #
        mov 0 [esi] eax
        pop eax
        mov eax 0 [eax]
        ret end-code hide

code SP@ ( - a )
        sub esi 4 #
        mov 0 [esi] eax
        mov eax esi
        ret end-code hide

code RP@ ( - a )
        sub esi 4 #
        mov 0 [esi] eax
        mov eax esp
        add eax 4 #
        ret end-code hide

code SP! ( a - )
        mov esi eax
        mov eax 0 [esi]
        add esi 4 #
        ret end-code hide

code RP! ( a - )
        pop edx
        mov esp eax
        mov eax 0 [esi]
        add esi 4 #
        jmp edx end-code hide

code EXECUTE ( xt - )
        mov edx eax
        lodsd
        jmp edx end-code

code CALL ( xt - )
        mov edx eax
        lodsd
        jmp edx end-code

icode NOOP ( - )
        ret end-code

\ ------------- Data Stack -----------------------------------------------------

icode DUP ( n - n n )
        sub esi 4 #
        mov 0 [esi] eax
        ret end-code

code ?DUP ( x - x | x x )
        or eax eax
        jz <if>
           sub esi 4 #
           mov 0 [esi] eax
        <then>
        ret end-code

code 2DUP ( n n2 - n n2 n n2 )
        sub esi 8 #
        mov 4 [esi] eax
        mov edx 8 [esi]
        mov 0 [esi] edx
        ret end-code

icode DROP ( n - )
        lodsd
        ret end-code

icode 2DROP ( n n2 - )
        lodsd
        lodsd
        ret end-code

code OVER ( n n1 - n n1 n )
        sub esi 4 #
        mov 0 [esi] eax
        mov eax 4 [esi]
        ret end-code

code 2OVER
        sub esi 8 #
        mov 4 [esi] eax
        mov edx 16 [esi]
        mov 0 [esi] edx
        mov eax 12 [esi]
        ret end-code

icode NIP ( n n2 - n2 )
        add esi 4 #
        ret end-code

icode SWAP ( n n1 - n1 n )
        mov edx eax
        mov eax 0 [esi]
        mov 0 [esi] edx
        ret end-code

code 2SWAP ( n n2 n3 n4 - n3 n4 n n2 )
        xchg eax 4 [esi]
        mov edx 0 [esi]
        xchg edx 8 [esi]
        mov 0 [esi] edx
        ret end-code

code TUCK ( n n2 - n2 n n2 )
        mov edx 0 [esi]
        sub esi 4 #
        mov 4 [esi] eax
        mov 0 [esi] edx
        ret end-code

code ROT ( n n1 n2 - n2 n3 n )
        mov edx 4 [esi]
        mov ecx 0 [esi]
        mov 0 [esi] eax
        mov 4 [esi] ecx
        mov eax edx
        ret end-code

icode PICK
        mov eax 0 [esi] [eax*4]
        ret end-code

\ ------------- Return Stack ---------------------------------------------------

code PUSH ( n - )
        pop edx
        push eax
        mov eax 0 [esi]
        add esi 4 #
        jmp edx end-code

code POP ( - n )
        sub esi 4 #
        mov 0 [esi] eax
        pop edx
        pop eax
        jmp edx end-code

code R@ ( - n )
        sub esi 4 #
        mov 0 [esi] eax
        mov eax 4 [esp]
        ret end-code

code 2PUSH ( n n2 - ) ( r: - n n2 )
        pop edx
        push 0 [esi]
        push eax
        mov eax 4 [esi]
        add esi 8 #
        jmp edx end-code

code 2POP ( - n n2 ) ( r: n n2 - )
        pop edx
        sub esi 8 #
        mov 4 [esi] eax
        pop eax
        pop 0 [esi]
        jmp edx end-code

code @R+ ( - n )
        sub esi 4 #
        mov 0 [esi] eax
        mov edx 4 [esp]
        mov eax 0 [edx]
        add edx 4 #
        mov 4 [esp] edx
        ret end-code

code !R+ ( n - )
        mov edx 4 [esp]
        mov 0 [edx] eax
        add edx 4 #
        mov 4 [esp] edx
        mov eax 0 [esi]
        add esi 4 #
        ret end-code

code R+ ( n - )
        add 4 [esp] eax
        lodsd
        ret end-code

\ ------------- Address Register -----------------------------------------------

hex

icode A! ( n - )
        mov edi eax
        lodsd
        ret end-code

icode A@ ( - n )
        sub esi 4 #
        mov 0 [esi] eax
        mov eax edi
        ret end-code

icode !A ( n - )
        mov 0 [edi] eax
        lodsd
        ret end-code

icode @A ( - n )
        sub esi 4 #
        mov 0 [esi] eax
        mov eax 0 [edi]
        ret end-code

icode A+ ( n - )
        add edi eax
        lodsd
        ret end-code

code @A+ ( - n )
        sub esi 4 #
        mov 0 [esi] eax
        mov eax 0 [edi]
        add edi 4 #
        ret end-code

icode !A+ ( n - )
        stosd
        lodsd
        ret end-code

decimal

\ ------------- Conditionals ---------------------------------------------------

code = ( n n2 - f )
        cmp eax 0 [esi]
        mov eax 0 #
        jne <if>
           dec eax
        <then>
        add esi 4 #
        ret end-code

code <> ( n n2 - f )
        cmp eax 0 [esi]
        mov eax 0 #
        je <if>
           dec eax
        <then>
        add esi 4 #
        ret end-code

code 0= ( n - f )
        neg eax
        sbb eax eax
        not eax
        ret end-code

code 0<> ( n - f )
        neg eax
        sbb eax eax
        ret end-code

code < ( n n2 - f )
        cmp eax 0 [esi]
        mov eax 0 #
        jle <if>
           dec eax
        <then>
        add esi 4 #
        ret end-code

code > ( n n2 - f )
        cmp eax 0 [esi]
        mov eax 0 #
        jge <if>
           dec eax
        <then>
        add esi 4 #
        ret end-code

code U< ( u1 u2 - f )
        cmp 0 [esi] eax
        sbb eax eax
        add esi 4 #
        ret end-code

code U> ( u1 u2 - f )
        cmp eax 0 [esi]
        sbb eax eax
        add esi 4 #
        ret end-code

code 0> ( n - f )
        cmp eax 0 #
        mov eax 0 #
        jle <if>
           dec eax
        <then> ret end-code

code 0< ( n - f )
        cmp eax 0 #
        mov eax 0 #
        jge <if>
           dec eax
        <then> ret end-code

\ ------------- Memory ---------------------------------------------------------

hex

icode CELLS ( n - n' )
        shl eax 2 #
        ret end-code

icode CELL+ ( n - n' )
        add eax 4 #
        ret end-code

icode CELL- ( n - n' )
        sub eax 4 #
        ret end-code

icode @ ( a - n )
        mov eax 0 [eax]
        ret end-code

icode ! ( n a - )
        mov edx 0 [esi]
        mov 0 [eax] edx
        lodsd
        lodsd
        ret end-code

icode C@ ( ca - n )
        xchg eax edx
        xor eax eax
        mov al 0 [edx]
        ret end-code

icode C! ( n a - )
        mov edx 0 [esi]
        mov 0 [eax] dl
        lodsd
        lodsd
        ret end-code

icode W@ ( a - n )
        mov ax 0 [eax]
        and eax ffff #
        ret end-code

icode W! ( n a - )
        mov edx 0 [esi]
        mov 0 [eax] dx
        lodsd
        lodsd
        ret end-code

icode +! ( n a - )
        mov edx 0 [esi]
        add 0 [eax] edx
        lodsd
        lodsd
        ret end-code

\ ------------- Arithmatic -----------------------------------------------------

decimal

icode + ( n n2 - n3 )
        add eax 0 [esi]
        add esi 4 #
        ret end-code

icode - ( n n2 - n3 )
        sub 0 [esi] eax
        lodsd
        ret end-code

icode 1+ ( n - n' )
        inc eax
        ret end-code

icode 1- ( n - n' )
        dec eax
        ret end-code

icode u+ ( n n2 n3 - n4 )
        add 4 [esi] eax
        lodsd
        ret end-code

icode * ( n n2 - n3 )
        mov ecx eax
        lodsd
        mul ecx
        ret end-code

icode / ( n n2 - n3 )
        mov ecx eax
        lodsd
        cdq
        idiv ecx
        ret end-code

code /MOD ( n n2 - n3 n4 )
        mov ecx eax
        mov eax 0 [esi]
        cdq
        idiv ecx
        mov 0 [esi] edx
        ret end-code

icode 2* ( n - n' )
        shl eax 1 #
        ret end-code

icode 2/ ( n - n' )
        sar eax 1 #
        ret end-code

code MOD ( n n2 - n3 )
        mov ecx eax
        lodsd
        cdq
        idiv ecx
        mov eax edx
        ret end-code

code */MOD ( n1 n2 n3 -- n4 n5 )
        mov ecx eax
        mov ebx 0 [esi]
        mov eax 4 [esi]
        imul ebx
        add esi 4 #
        idiv ecx
        mov 0 [esi] edx
        ret end-code

code */ ( n1 n2 n3 -- n4 )
        mov ecx eax
        mov ebx 0 [esi]
        mov eax 4 [esi]
        imul ebx
        add esi 8 #
        idiv ecx
        ret end-code

code M* ( n1 n2 -- d )
        mov ecx eax
        mov eax 0 [esi]
        imul ecx
        mov 0 [esi] eax
        mov eax edx
        ret end-code

code UM* ( u1 u2 - ud )
        mov ecx eax
        mov eax 0 [esi]
        mul ecx
        mov 0 [esi] eax
        mov eax edx
        ret end-code

code D+ ( d1 d2 - d3 )
        mov edx 0 [esi]
        mov ecx 4 [esi]
        add esi 8 #
        add 0 [esi] edx
        adc eax ecx
        ret end-code

code D- ( d1 d2 - d3 )
        mov edx 0 [esi]
        mov ecx 4 [esi]
        add esi 8 #
        sub 0 [esi] edx
        sbb ecx eax
        mov eax ecx
        ret end-code

code UM/MOD ( ud u1 - u2 u3 )
        mov edx 0 [esi]
        mov ecx eax
        mov eax 4 [esi]
        add esi 4 #
        div ecx
        mov 0 [esi] edx
        ret end-code

icode AND ( n n2 - n3 )
        and eax 0 [esi]
        add esi 4 #
        ret end-code

icode OR ( n n2 - n3 )
        or eax 0 [esi]
        add esi 4 #
        ret end-code

icode XOR ( n n2 - n3 )
        xor eax 0 [esi]
        add esi 4 #
        ret end-code

icode INV ( n - n2 )
        not eax
        ret end-code

icode NEG ( n - n2 )
        neg eax
        ret end-code

code ABS ( n - |n| )
        or eax eax
        jns <if>
           neg eax
        <then>
        ret end-code

icode SHR ( n - )
        mov ecx eax
        lodsd
        shr eax cl
        ret end-code

icode SHL ( n - )
        mov ecx eax
        lodsd
        shl eax cl
        ret end-code

code MAX ( n n2 - max )
        mov edx 0 [esi]
        cmp eax edx
        jge <if>
           mov eax edx
        <then>
        add esi 4 #
        ret end-code

code MIN ( n n2 - max )
        mov edx 0 [esi]
        cmp eax edx
        jle <if>
           mov eax edx
        <then>
        add esi 4 #
        ret end-code

code WITHIN ( n n2 n3 - f )
        mov edx 0 [esi]
        mov ecx 4 [esi]
        add esi 8 #
        sub eax edx
        sub ecx edx
        sub ecx eax
        sbb eax eax
        ret end-code

code DABS ( d - ud )
        or eax eax
        jns <if>
           neg 0 [esi]
           neg eax
           sbb eax 0 #
        <then>
        ret end-code

code S>D ( u - ud )
        sub esi 4 #
        mov 0 [esi] eax
        shl eax 1 #
        sbb eax eax
        ret end-code

code D>S ( ud - u )
        mov eax 0 [esi]
        add esi 4 #
        ret end-code

\ ------------- Strings --------------------------------------------------------

decimal

code (S') ( - ca u )
        sub esi 8 #
        mov 4 [esi] eax
        pop edx
        mov ecx edx
        inc ecx
        mov 0 [esi] ecx
        xor eax eax
        mov al 0 [edx]
        mov ecx eax
        inc ecx
        add ecx edx
        jmp ecx end-code hide

code (C') ( - ca )
        sub esi 4 #
        mov 0 [esi] eax
        xor ecx ecx
        pop eax
        mov cl 0 [eax]
        inc ecx
        add ecx eax
        jmp ecx end-code hide

code MOVE ( a a2 u2 - )
        or eax eax
        jz <if>
           push edi
           push esi
           mov ecx eax
           mov edi 0 [esi]
           mov esi 4 [esi]
           rep movsd
           pop esi
           pop edi
        <then>
        add esi 8 #
        lodsd
        ret end-code

code MOVE> ( a a2 u2 - )
        or eax eax
        jz <if>
           push edi
           push esi
           mov ecx eax
           sub eax 4 #
           mov edi 0 [esi]
           mov esi 4 [esi]
           add edi eax
           add esi eax
           std
           repnz movsd
           cld
           pop esi
           pop edi
        <then>
        add esi 8 #
        lodsd
        ret end-code

code CMOVE ( ca ca2 u2 - )
        or eax eax
        jz <if>
           push edi
           push esi
           mov ecx eax
           mov edi 0 [esi]
           mov esi 4 [esi]
           rep movsb
           pop esi
           pop edi
        <then>
        add esi 8 #
        lodsd
        ret end-code

code CMOVE> ( ca ca2 u2 - )
        or eax eax
        jz <if>
           push edi
           push esi
           mov ecx eax
           dec eax
           mov edi 0 [esi]
           mov esi 4 [esi]
           add edi eax
           add esi eax
           std
           repnz movsb
           cld
           pop esi
           pop edi
        <then>
        add esi 8 #
        lodsd
        ret end-code

code SCAN ( ca u char -- ca' u' )
        push edi
        mov ecx 0 [esi]
        or ecx ecx
        jz <if>
           mov edi 4 [esi]
           repne scasb
           jnz <if>
              inc ecx
              dec edi
           <then>
           mov 4 [esi] edi
        <then>
        mov eax ecx
        add esi 4 #
        pop edi
        ret end-code

code SKIP ( ca u char -- ca' u' )
        push edi
        mov ecx 0 [esi]
        or ecx ecx
        jz <if>
           mov edi 4 [esi]
           repe scasb
           jz <if>
              inc ecx
              dec edi
           <then>
           mov 4 [esi] edi
        <then>
        mov eax ecx
        add esi 4 #
        pop edi
        ret end-code

code COMPARE ( ca u ca2 u2 -- n )
        cmp eax 4 [esi]
        jne <if>
           mov edx esi
           mov ecx eax
           push edi
           mov edi 0 [edx]
           mov esi 8 [edx]
           repe cmpsb
           jz <if>
              jns <if>
                 mov eax -1 #
              <else>
                 mov eax 1 #
              <then>
           <else>
              mov eax 0 #
           <then>
           mov esi edx
           pop edi
        <else>
           mov eax -1 #
        <then>
        add esi 12 #
        ret end-code

code /STRING ( ca u n - ca+n u-n )
        mov edx 0 [esi]
        mov ecx 4 [esi]
        add ecx eax
        sub edx eax
        mov 4 [esi] ecx
        mov eax edx
        add esi 4 #
        ret end-code

code COUNT ( ca - ca+1 u )
        xor edx edx
        mov dl 0 [eax]
        inc eax
        sub esi 4 #
        mov 0 [esi] eax
        mov eax edx
        ret end-code

code FILL ( ca u c - )
        mov ecx 0 [esi]
        cmp ecx 0 #
        je <if>
           mov edx 4 [esi]
           <begin>
              mov 0 [edx] al
              inc edx
              dec ecx
              jnz
           <until>
        <then>
        mov eax 8 [esi]
        add esi 12 #
        ret end-code

code FLOOD ( a u n - )
        mov ecx 0 [esi]
        cmp ecx 0 #
        je <if>
           mov edx 4 [esi]
           <begin>
              mov 0 [edx] eax
              add edx 4 #
              dec ecx
              jnz
           <until>
        <then>
        mov eax 8 [esi]
        add esi 12 #
        ret end-code

: place  ( ca u ca2 - ) 2dup c! 1+ swap cmove ;

: append ( ca u ca2 - )
   2dup 2push dup c@ + 1+ swap cmove
   2pop swap over c@ + swap c! ;

\ ------------- Loops ----------------------------------------------------------

decimal

code (DO) ( n n2 - ) ( r: - leave index count )
        pop edx
        mov ecx edx
        add ecx 0 [edx]
        add edx 4 #
        push ecx
        mov ecx 0 [esi]
        push ecx
        sub ecx eax
        neg ecx
        push ecx
        mov eax 4 [esi]
        add esi 8 #
        jmp edx
        end-code hide

code (?DO) ( n n2 - ) ( r: - loop-sys | )
        pop edx
        mov ecx edx
        add ecx 0 [edx]
        cmp eax 0 [esi]
        je <if>
           add edx 4 #
           push ecx
           mov ecx 0 [esi]
           push ecx
           sub ecx eax
           neg ecx
           push ecx
           mov eax 4 [esi]
           add esi 8 #
           jmp edx
        <then>
        mov eax 4 [esi]
        add esi 8 #
        jmp ecx
        end-code hide

code (LOOP) ( - ) ( r: loop-sys - | loop-sys2 )
        pop edx
        inc 0 [esp]
        js <if>
           add edx 4 #
           add esp 12 #
           jmp edx
        <then>
        add edx 0 [edx]
        jmp edx
        end-code hide

code (+LOOP) ( n - ) ( r: loop-sys - | loop-sys2 )
        pop edx
        add 0 [esp] eax
        js <if>
           add edx 4 #
           add esp 12 #
           mov eax 0 [esi]
           add esi 4 #
           jmp edx
        <then>
        add edx 0 [edx]
        mov eax 0 [esi]
        add esi 4 #
        jmp edx
        end-code hide

code I ( - n ) ( r:  loop-sys - loop-sys )
        sub esi 4 #
        mov 0 [esi] eax
        mov eax 4 [esp]
        add eax 8 [esp]
        ret end-code

code J ( - n ) ( r: loop-sys1 loop-sys2 - loop-sys1 loop-sys2 )
        sub esi 4 #
        mov 0 [esi] eax
        mov eax 16 [esp]
        add eax 20 [esp]
        ret end-code

code UNLOOP ( - ) ( r: loop-sys - )
        mov edx 0 [esp]
        add esp 16 #
        jmp edx
        end-code

code LEAVE ( - ) ( r: loop-sys - )
        mov edx 12 [esp]
        add esp 16 #
        jmp edx
        end-code

\ ------------- Control Structures ---------------------------------------------

decimal

code (JMP) ( - )
        pop edx
        add edx 0 [edx]
        jmp edx
        end-code hide

code (OF) ( n n2 - n | )
        cmp eax 0 [esi]
        jne <if>
           mov eax 4 [esi]
           add esi 8 #
           pop edx
           add edx 4 #
           jmp edx
        <then>
        mov eax 0 [esi]
        add esi 4 #
        pop edx
        add edx 0 [edx]
        jmp edx
        end-code hide

\ ------------- Tasks ----------------------------------------------------------

decimal

code self ( - a )
        sub esi 4 #
        mov 0 [esi] eax
        mov eax ebp
        ret end-code

( Task Context Block Layout )

00
cell+                                   \ Active Tasks Ring Link Field
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
dup constant tcb>hist     hide cell+    \ Compilation History
dup constant tcb>hld      hide 40  +    \ Hold Pointer & Number Conversion Buffer (36 bytes)
dup constant tcb>spad     hide 256 +    \ Source String Buffer (256 bytes)
dup constant tcb>current  hide cell+    \ Definitions Wordlist
dup constant tcb>search   hide cell+    \ Search Length
dup constant tcb>swb      hide 64  +    \ Search Order (64 bytes = 16 wordlists)
dup constant tcb>mark     hide cell+    \ Dictionary Marker
dup constant tcb>finish   hide cell+    \ Colour Compilation Terminus
dup constant tcb>dropdup  hide cell+    \ Stack Optimization
dup constant tcb>nipdup   hide cell+    \ Stack Optimization
dup constant tcb>p        hide cell+    \ Colour Compilation Pointer
dup constant tcb>sib      hide cell+    \ Next Sibling Task
dup constant tcb>children hide cell+    \ First Child Task
dup constant tcb>kid      hide cell+    \ Current Target Task
dup constant tcb>memory   hide cell+    \ First Allocated Memory Entry
dup constant tcb>decision hide 64  +    \ Colour Compilation Jump Table

drop

( Accessable User Variables )

tcb>base     user base
tcb>sp       user sp         hide
tcb>rp       user rp         hide
tcb>sp0      user sp0        hide
tcb>rp0      user rp0        hide
tcb>hand     user hand
tcb>areg     user ap         hide
tcb>dp       user dp         hide
tcb>dp0      user dp0        hide
tcb>hp       user hp         hide
tcb>hp0      user hp0        hide
tcb>enth     user enth
tcb>flux     user flux
tcb>macro    user macro
tcb>state    user state
tcb>blk      user blk        hide
tcb>sblk     user superblock
tcb>tib      user 'tib       hide
tcb>#tib     user #tib       hide
tcb>in       user >in
tcb>sid      user sid        hide
tcb>hist     user history    hide
tcb>hld      user hld        hide
tcb>spad     user spad
tcb>current  user current
tcb>search   user searching  hide
tcb>swb      user swb        hide
tcb>mark     user mark
tcb>finish   user finish     hide
tcb>dropdup  user dropdup    hide
tcb>nipdup   user nipdup     hide
tcb>p        user p          hide
tcb>sib      user sibling    hide
tcb>children user children   hide
tcb>kid      user kid        hide
tcb>memory   user memory     hide
tcb>decision user decision   hide

defer pause
defer behavior               hide

\ ------------- Dictionary -----------------------------------------------------

-1 constant TRUE
 0 constant FALSE

: ON ( a - ) true swap ! ;
: OFF ( a - ) false swap ! ;

: end finish on ;

icode cflag ( n - )
   or eax eax
   lodsd
   ret end-code hide

: depth ( - n ) sp@ sp0 swap - 2/ 2/ ;
: ..    ( - ) sp0 sp! ;
: ..r   ( - ) pop rp0 rp! push ;

hex

defer ACCEPT
defer QUIT

: ABORT  ( - ) .. 0 hand ! quit ;

: CATCH  ( xt - f )
   sp@ push hand @ push rp@ hand ! execute pop hand ! pop drop false ;

: THROW  ( n - | n )
        ?dup
        if      hand @ 0=
                if      abort
                else    hand @ rp! pop hand ! pop swap push sp! drop pop
                then
        then ;

: HERE      ( - a ) dp @ ;                                    ' here is behavior
: ALLOT     ( n - ) dp +! ;
: ALIGNED   ( a - a' ) 1- 4 2dup mod - + ;
: SOURCE-ID ( - n ) sid @ ;
: NFA>CFA   ( a - a' ) dup c@ 1+ aligned + @ ;                         hide
: NFA>PFA   ( a - a' ) cell- 1- ;                                      hide
: ,         ( n - ) here  ! 4 allot ;
: C,        ( c - ) here c! 1 allot ;
: EXIT      ( - ) c3 c, ;                                              immediate

: 1, ( c - ) c, ;
: 2, ( w - ) dup 8 shr c, c, ;
: 3, ( n - ) dup 10 shr c, 2, ;
: 4, ( n - ) dup 18 shr c, 3, ;

: reset dropdup off nipdup off history off ;

: drop? here dropdup @ = ; hide
: nip? ( - ) here nipdup @ = ; hide
: pushd, drop? if -1 allot exit then nip? if -3 allot 8906 2,
   exit then 8D76FC 3, 8906 2, ; hide
: dup, pushd, reset ; hide
: drop, AD 1, here dropdup ! ;  hide
: nip, 8D7604 3, here nipdup ! ; hide

: +hist     ( n - ) history @ 4 shl or history ! ;                     hide
: @hist     ( - n ) history @ 0f and ;                                 hide
: -hist     ( - ) history @ 4 shr history ! ;                          hide

: LITERAL ( n - ) pushd, b8 1, , 3 +hist ;                             immediate
: COMPILE,  ( xt - ) e8 c, here cell+ - , 1 +hist ;
: PAD       ( - a ) here aligned 100 + ;

: TIMES ( xt n - ) 0 ?do dup compile, loop drop reset ;

: cry ( a u - ) spad append 1 throw ; hide
: /num s"  number?" cry ; hide
: /word s"  word?" cry ; hide
: /size s"  Oversize Branch" cry ; hide

\ ------------- Control Structures ---------------------------------------------

hex

: <IF>      ( - orig ) 0fadc009 , 84 c, ;                              hide
: <ELSE>    ( orig - orig2 ) e9 c, ;                                   hide
: <THEN>    ( orig - ) here over - cell- swap ! ;                      hide
: <MARK>    ( - orig ) here 4 allot ;                                  hide
: <RESOLVE> ( dest - ) here cell+ - , ;                                hide

: IF     ( - orig ) <if> <mark> ;                                      immediate
: THEN   ( orig - ) <then> ;                                           immediate
: ELSE   ( orig - orig2 ) <else> <mark> swap <then> ;                  immediate
: BEGIN  ( - dest ) here ;                                             immediate
: UNTIL  ( dest - ) <if> <resolve> ;                                   immediate
: AGAIN  ( dest - ) <else> <resolve> ;                                 immediate
: WHILE  ( dest - orig dest ) <if> <mark> swap ;                       immediate
: REPEAT ( orig dest - ) <else> <resolve> <then> ;                     immediate
: FOR    ( - dest ) 50ad 2, here ;                                     immediate
: NEXT   ( dest - ) ff0c24 3, 0f85 2, <resolve> 83c404 3, ;            immediate

: <SNAG> ( orig - ) here over - swap ! ;                               hide

: CASE    ( - cs ) false ;                                             immediate
: OF      ( - os ) postpone (of) <mark> ;                              immediate
: ENDOF   ( cs os - cs2 ) postpone (jmp) <mark> swap <snag> swap 1+ ;  immediate
: ENDCASE ( cs - ) postpone drop 0 ?do <snag> loop ;                   immediate
: DO      ( - orig dest ) postpone (do) <mark> here ;                  immediate
: ?DO     ( - orig dest ) postpone (?do) <mark> here ;                 immediate
: LOOP    ( orig dest - ) postpone (loop) here - , <snag> ;            immediate
: +LOOP   ( orig dest - ) postpone (+loop) here - , <snag> ;           immediate

code JUMP ( n - )
   pop edx
   add edx eax
   shl eax 2 #
   add edx eax
   add edx 5 #
   add edx -4 [edx]
   lodsd
   jmp edx

code INDEX ( n - )
   pop edx
   add edx eax
   shl eax 2 #
   add edx eax
   lodsd
   jmp edx

\ ------------- Input Stream ---------------------------------------------------

hex

20 constant BL

: SOURCE  ( - ca u ) 'tib @ #tib @ ;
: source> ( - ca u ) source >in @ /string ; hide

: PARSE ( char "ccc<chapop" - ca u  )
        push source> 2dup pop scan nip dup 0<>
        if     - dup 1+
        else   - dup
        then >in +! ;

: >UCASE ( ca - ca )
        dup count 0
        ?do     dup i + dup c@ dup 61 7b within if bl - then swap c!
        loop drop ; hide

: WORD ( char "<chars>ccc<chapop" -- ca )
        source> 2 pick skip drop 'tib @ - dup >in ! #tib @ <>
        if     parse dup spad c! spad 1+ swap cmove
        else   drop 0 spad c!
        then spad ;

code fparse ( c - a u )
   mov edx eax
   mov eax tcb>p [ebp]
   inc eax
   sub esi 4 #
   mov 0 [esi] eax
   mov ebx eax
   xor ecx ecx
   <begin>
      mov cl 0 [eax]
      inc eax
      cmp ecx edx
      jne
   <until>
   mov tcb>p [ebp] eax
   dec eax
   sub eax ebx
   ret end-code

code process ( - )
   xor ecx ecx
   mov tcb>finish [ebp] ecx
   <begin>
      mov edx tcb>p [ebp]
      xor ecx ecx
      <begin>
         mov cl 0 [edx]
         inc edx
         cmp cl 20 #
         jl
      <until>
      dec edx
      xor ebx ebx
      mov bl -1 [edx]
      and ebx 0f #
      shl ebx 2 #
      push ebx
      mov ebx ebp
      add ebx tcb>spad #
      push ebx
      xor ecx ecx
      <begin>
         inc ebx
         mov cl 0 [edx]
         inc edx
         cmp cl 61 #
         jl <if>
            cmp cl 7a #
            jg <if>
               sub cl 20 #
            <then>
         <then>
         mov 0 [ebx] cl
         cmp cl 01f #
         jg
      <until>
      pop ecx
      sub ebx ecx
      dec ebx
      mov 0 [ecx] bl
      dec edx
      mov tcb>p [ebp] edx
      pop edx
      add edx ebp
      mov edx tcb>decision [edx]
      call edx
      mov edx tcb>finish [ebp]
      or edx edx
      jz
   <until>
   xor ecx ecx
   mov tcb>finish [ebp] ecx
   ret end-code

\ ------------- Numbering ------------------------------------------------------

hex

: CHAR ( - n ) bl word 1+ c@ ;

: [CHAR] ( - ) char postpone literal ; immediate

: DECIMAL ( - ) 0a base ! ;
: HEX     ( - ) 10 base ! ;
: BINARY  ( - ) 2  base ! ;

: HOLD ( c - ) hld @ 1- dup hld ! c! ;
: SIGN ( n - ) 0< if 2d hold then ;

code # ( ud - ud' )
        mov ecx tcb>base [ebp]
        xor edx edx
        div ecx
        push eax
        mov eax 0 [esi]
        div ecx
        mov 0 [esi] eax
        cmp dl 9 #
        jbe <if>
           add dl 7 #
        <then>
        add dl 30 #
        mov ecx tcb>hld [ebp]
        dec ecx
        mov 0 [ecx] dl
        mov tcb>hld [ebp] ecx
        pop eax
        ret end-code

: <#   ( - ) spad hld ! ;
: #S   ( ud - ud2 ) begin # 2dup or 0= until ;
: #>   ( xd - ca u ) 2drop hld @ spad over - ;

: number ( d - a u ) tuck dabs <# #s rot sign #> ;

code DIGIT ( c base - n f )
        mov edx 0 [esi]
        sub edx 30 #
        jb <if>
           cmp edx 9 #
           jbe L1
           sub edx 7 #
           cmp edx 0a #
           jb <if>
L1:           cmp edx eax
              jae <if>
                 mov 0 [esi] edx
                 mov eax -1 #
                 ret
              <then>
           <then>
        <then>
        xor eax eax
        ret end-code

: >number ( ud ca u -- ud2 ca2 u2 )
   begin dup
   while push dup push c@ base @ digit
   while swap base @ um* drop rot base @ um* d+ pop pop 1 /string
   repeat drop pop pop then ;


: NUMBER? ( ca -- ca 0 | x -1 )
        dup push 0 0 pop count over c@ 2d =
        if 1 /string -1 else 1 then push >number
        if      pop 2drop 2drop false
        else    2drop nip pop * true
        then ;

\ ------------- Compiler -------------------------------------------------------

hex

create VACANT-WORDLIST 5 allot hide     \ link = 1 cell, name = 1 byte

create HIDDEN 4 allot

: WORDLIST ( - wid ) here vacant-wordlist cell+ , ;
: CONTEXT ( - a ) swb searching @ 1- cells + ;
: GET-CURRENT ( - wid ) current @ ;
: SET-CURRENT ( wid - ) current ! ;
: GET-ORDER ( widn ... wid1 n - )
   swb searching @ for dup @ swap cell+ next drop searching @ ;

: SET-ORDER ( widn ... wid1 n - )
   dup 0= if searching ! exit then
   dup 0< if drop enth 1 then
   dup searching ! for r@ 1- cells swb + ! next ;

: +ORDER ( wid - ) push get-order pop swap 1+ set-order ;
: -ORDER ( - ) -1 searching +! ;

: DEFINITIONS ( - ) context @ set-current ;

: ONLY ( - ) -1 set-order ;
: ALSO ( - ) get-order over swap 1+ set-order ;
: PREVIOUS ( - ) -1 searching +! ;
: FORTH-WORDLIST ( - ) enth ;
: FORTH ( - ) get-order nip enth swap set-order ;

code (search-wordlist) ( ca a - b | 0 )
   push edi
   mov ebx 0 [esi]
   xor edx edx
   mov dl 0 [ebx]
   inc edx
   add esi 4 #
   push esi
   <begin>
      mov edi ebx
      mov ecx edx
      mov esi eax
      repe cmpsb
      jnz <if>
         pop esi
         pop edi
         ret
      <then>
      mov eax -4 [eax]
      or eax eax
      jnz
   <until>
   pop esi
   pop edi
   ret end-code hide

: SEARCH-WORDLIST2 ( ca wid - 0 | xt 1 | xt -1 )
   over push @
   begin (search-wordlist) dup
      if dup nfa>pfa c@ 40 and 0=
         if dup nfa>cfa swap nfa>pfa c@
            dup here c! 80 and 0= 1 or
            pop drop exit
         then cell- @
      then dup
   while r@ swap
   repeat pop drop ; hide

: SEARCH-WORDLIST ( ca u wid - 0 | xt 1 | xt -1 )
   push here 1+ place here 1+ pop search-wordlist2 ;

: FIND2 ( ca - ca 0 | xt 1 | xt -1 )
   searching @
   for dup r@ 1- cells swb + @ search-wordlist2
      dup if rot drop pop drop exit then drop
   next false ; hide

: FIND ( ca - ca 0 | xt 1 | xt -1 )
   >ucase find2 ;

: ' ( - xt ) bl word find drop ;

: lit ( n - ) postpone literal ; fhide
: lit? ( - n ) p @ c@ 2 = if lit then ; hide

: ?lit ( - n ) @hist 3 =
   if -4 allot here @ history @ 0f or history !
      drop? if -1 allot drop, exit then
      nip? if -3 allot nip, exit then
      -hist -6 allot  -1 cflag exit
   then 0 cflag ; fhide

: size? ( n - n ) dup -80 80 within if exit then /size ; hide

: INTERPRET ( - )
   finish off
   begin finish @ if exit then
        bl word dup c@
   while find dup
      if 1+ state @ 0= or
         if execute depth 0<
            if 1 throw
            then
         else here c@ 0f and                    \ precedence says inlinable code?
            if here dup c@ dup allot cmove      \ compile inline
            else compile,                       \ compile a call
            then
         then
      else drop >ucase number?
         if state @
            if postpone literal
            then
         else 2 throw
         then
      then pause
   repeat drop ; hide

: EVALUATE ( ca u - )
        #tib @ push 'tib @ push >in @ push sid @ push -1 sid ! 0 >in ! #tib ! 'tib !
        0 blk ! ['] interpret catch pop sid ! pop >in ! pop 'tib ! pop #tib ! throw ;

400 constant ABLOCK hide

: BLOCK ( u - a ) ablock * superblock @ + ;

: ELOAD ( u - )
        blk @ push #tib @ push 'tib @ push >in @ push
        dup blk ! ablock #tib ! 0 >in ! block 'tib ! ['] interpret catch
        pop >in ! pop 'tib ! pop #tib ! pop blk ! throw ;

defer LOAD ' eload is load

: +LOAD ( u - ) blk @ + load ;
: THRU ( u u2 - ) 1+ swap ?do i load loop ;
: +THRU ( u u2 - ) blk @ tuck + push + pop thru ;

: FREAD ( a - )
   p @ push p ! reset ['] process catch reset pop p ! throw ;

: FLOAD ( u - )
   blk @ push p @ push block dup blk ! p ! reset
   ['] process catch reset pop p ! pop blk ! throw ;

: NOPS      ( n - ) dup if for 90 c, next exit then drop ;                     hide
: ALIGN     ( - ) here dup aligned swap - nops ;
: PLACE,    ( a u - ) here over 1+ allot place ; hide
: ALIGN-1   ( - ) here dup aligned swap - dup if 1- nops else drop 3 nops then ; hide
: DSWAP     ( - ) dp @ hp @ dp ! hp ! dp0 @ hp0 @ dp0 ! hp0 ! ;                  hide
: newcfa    ( a - ) get-current @ dup c@ 1+ aligned + ! ;                   hide

: LINK,     ( - ) align-1 0 c, get-current @ , here get-current ! ; hide
: HEADER,   ( - ) here dswap link, bl word >ucase count place, align , dswap ; hide
: CREATE    ( - ) align-1 header, postpone dovar ;
: >BODY     ( a - a' ) 1+ cell+ ;
: VARIABLE  ( - ) create 0 , ;
: VALUE     ( n - ) header, postpone doval , ;
: CONSTANT  ( n - ) value ;
: (DOES>)   ( - ) get-current @ nfa>cfa 1+ pop over cell+ - swap ! ;   hide
: DOES>     ( - ) postpone (does>) postpone pop ; immediate
: DEFER     ( - ) header, postpone noop e9 here 5 - c! ;
: is        ( cfa cfa2 - ) 1+ tuck cell+ - swap ! ;
: IMMEDIATE ( - ) get-current @ nfa>pfa dup c@ 80 or swap c! ;
: SMUDGE    ( - ) get-current @ nfa>pfa dup c@ 40 or swap c! ;         hide
: SHINE     ( - ) get-current @ nfa>pfa dup c@ bf and swap c! ;        hide

: POSTPONE ( - )
   bl word find dup
   if 0<
      if postpone literal postpone compile, exit
      then compile, exit
   then drop ;                                                         immediate

: [       ( - ) state off ;                                            immediate
: ]       ( - ) state on ;
: :       ( - ) header, smudge ] ;
: ;       ( - ) postpone exit postpone [ shine ;                       immediate
: [']     ( - ) ' postpone literal ;                                   immediate
: RECURSE ( - ) get-current @ nfa>cfa compile, ;                       immediate
: :NONAME ( - xt ) here ] ;                                            immediate

: REFILL ( - flag ) blk @
        if      1 blk +! blk @ block 'tib ! ablock #tib !
        else    'tib @ 50 accept #tib !
        then    0 >in ! true ;

: mlook ( - xt f ) spad macro search-wordlist2 ; hide

\ Flux Compiler
: back ( a b - ) dup push 1+ - size? pop c! ; fhide

: look ( - cfa ) spad flux search-wordlist2 if exit then
   spad find2 if exit then /word ; hide

: define here dswap link, spad count place, align , dswap reset ; hide

: fcreate align-1 define ['] dovar compile, ; hide
: number ( - n ) spad number? if exit then /num ; hide
: dnumber ( - n ) decimal number lit? ; hide
: hnumber ( - n ) hex number lit? ; hide
: cfa ( - a ) look lit? ; hide
: now look execute lit? ; hide

: control ( - ) mlook if execute 2 +hist exit then look compile, ; hide
: later ( - ) mlook if compile, exit then look lit ['] compile, compile, ; hide

create (behavior)
 ' noop dup , ' define , ' control , ' now , ' dnumber ,
 ' hnumber , ' cfa , ' later , dup , dup , dup ,
 dup , dup , dup , dup , , hide
 ' (behavior) is behavior

: token ( xt n - ) cells decision + ! ;
: default cells dup behavior + @ swap decision + ! ;

: avar fcreate 0 , ; hide
: amacro get-current macro set-current define set-current ; hide

\ ------------------------------------------------------------------------------

: TO ( n - )
        ' >body state @
        if      postpone literal postpone !
        else    !
        then ;                                                         immediate

\ ------------- Strings --------------------------------------------------------

hex

: sliteral ( ca u - )
   postpone (s') place, ;                        immediate

: csliteral ( ca u - )
   postpone (c') place, ;                        immediate

: s" ( "ccc<quote>" - ) [char] " parse postpone sliteral ;             immediate

: c" ( "ccc<quote>" - ) [char] " parse postpone csliteral ;            immediate

\ ------------- Stuff ----------------------------------------------------------

decimal


: (  ( - ) 41 word drop ; immediate
: \  ( - ) blk @ if >in @ dup 64 mod neg 64 + + else #tib @ then >in ! ; immediate

\ ------------- I/O ------------------------------------------------------------

code PC@ ( p - n )
        mov edx eax
        xor eax eax
        in al dx
        ret end-code

code PC! ( n p - )
        mov edx eax
        lodsd
        out dx al
        lodsd
        ret end-code

code PW@ ( p - n )
        mov edx eax
        xor eax eax
        in ax dx
        ret end-code

code PW! ( n p - )
        mov edx eax
        lodsd
        out dx ax
        lodsd
        ret end-code

code P@ ( p - n )
        mov edx eax
        in eax dx
        ret end-code

code P! ( n p - )
        mov edx eax
        lodsd
        out dx eax
        lodsd
        ret end-code

code INSB ( a p u - )
        mov ebx edi
        mov ecx eax
        mov edx 0 [esi]
        mov edi 4 [esi]
        rep insb
        mov eax 8 [esi]
        add esi 12 #
        mov edi ebx
        ret

code OUTSB ( a p u - )
        mov ebx esi
        mov ecx eax
        mov edx 0 [ebx]
        mov esi 4 [ebx]
        rep outsb
        mov eax 8 [ebx]
        add ebx 12 #
        mov esi ebx
        ret

code INSW ( a p u - )
        mov ebx edi
        mov ecx eax
        mov edx 0 [esi]
        mov edi 4 [esi]
        rep insw
        mov eax 8 [esi]
        add esi 12 #
        mov edi ebx
        ret

code OUTSW ( a p u - )
        mov ebx esi
        mov ecx eax
        mov edx 0 [ebx]
        mov esi 4 [ebx]
        rep outsw
        mov eax 8 [ebx]
        add ebx 12 #
        mov esi ebx
        ret

code INSD ( a p u - )
        mov ebx edi
        mov ecx eax
        mov edx 0 [esi]
        mov edi 4 [esi]
        rep insd
        mov eax 8 [esi]
        add esi 12 #
        mov edi ebx
        ret

code OUTSD ( a p u - )
        mov ebx esi
        mov ecx eax
        mov edx 0 [ebx]
        mov esi 4 [ebx]
        rep outsd
        mov eax 8 [ebx]
        add ebx 12 #
        mov esi ebx
        ret

\ ------------- Tools ----------------------------------------------------------

hex


: -trailing ( ca u - ca u2 )
        dup 1+ 1
        ?do     2dup + i - c@ bl <>
                if      1+ i - unloop exit
                then
        loop drop 0 ;

: -leading ( ca u - ca' u' )
        tuck
        0 ?do   dup c@ 20 =
                if      1+
                else    swap i - unloop exit
                then
        loop    nip 0 ;

: blank ( ca u - ) dup if bl fill exit then 2drop ;
: erase ( a u - ) dup if 0 fill exit then 2drop ;

: stack ( n - ) cells dup here cell+ + , allot ;

code spush ( n a - )
   mov ecx eax
   mov edx esp
   lodsd
   mov esp 0 [ecx]
   push eax
   lodsd
   mov 0 [ecx] esp
   mov esp edx
   ret end-code

code spop ( a - n )
   mov ecx eax
   mov edx esp
   mov esp 0 [ecx]
   pop eax
   mov 0 [ecx] esp
   mov esp edx
   ret end-code

\ ------------- Memory Managment -----------------------------------------------

hex

defer allocate
defer free
defer resize

: blocks ( n - a ) ablock * allocate throw ;

\ ------------ Task Zero -------------------------------------------------------

hex

create kernel
   here
        here ,                  \ active link field
        0a ,                    \ base
        0 ,                     \ sp
        100 allot               \ sp0
        100 allot               \ rp0
        0 ,                     \ rp
        0 ,                     \ exception frame pointer
        0 ,                     \ a register
        100000 2000c +
        dup ,                   \ dictionary point
        ,                       \ dictionary base
        100000 0c +
        dup ,                   \ header point
        ,                       \ header base
        0 ,                     \ Forth Wordlist
        0 ,                     \ Flux Wordlist
        0 ,                     \ Macro Wordlist
        0 ,                     \ state
        0 ,                     \ blk
        20000 ,                 \ superblock
        0 ,                     \ 'tib
        0 ,                     \ #tib
        0 ,                     \ >in
        0 ,                     \ source-id
        0 ,                     \ history
        0 ,                     \ Hold Pointer
        24 allot                \ Number Buffer 36
        100 allot               \ System Pad 256
        kernel tcb>enth  + ,    \ Current
        2 ,                     \ Searching
        hidden ,                \ Context
        kernel tcb>enth  + ,
        38 allot
        0 ,                     \ mark
        0 ,                     \ finish
        0 ,                     \ dropdup
        0 ,                     \ nipdup
        0 ,                     \ p
        0 ,                     \ sibling
        0 ,                     \ children
        0 ,                     \ kid
        0 ,                     \ memory
 ' noop dup , ' define , ' control , ' now , ' dnumber ,
 ' hnumber , ' cfa , ' later , dup , dup , dup ,
 dup , dup , dup , dup , ,
   here swap - constant tcbsize hide

\ ------------- Multitasking ---------------------------------------------------

hex

code coop-switch ( - )
   sub esi 4 #
   mov 0 [esi] eax
   mov tcb>sp [ebp] esi
   mov tcb>rp [ebp] esp
   mov tcb>areg [ebp] edi
   mov ebp 0 [ebp]
   mov esi tcb>sp [ebp]
   mov esp tcb>rp [ebp]
   mov edi tcb>areg [ebp]
   lodsd
   ret end-code      hide

: single ( - ) ['] noop ['] pause is ;
: multi  ( - ) ['] coop-switch ['] pause is ;

: his   ( up a - a' ) self - + ;
: him   ( a - b ) kid @ swap his ; hide

: last-link ( a - b )
   begin dup @
   while @
   repeat ; hide

: push-link ( a b - )
   last-link ! ; hide

: pop-link ( a - b ) dup
   begin dup @
   while nip dup @
   repeat swap off ; hide

: last-child ( up - a )
   dup children his
   begin @ dup
   while nip dup sibling his
   repeat drop ; hide

: init-slave ( up - )
   dup sp0 his over sp his !
   dup rp0 his over rp his !
   dup hand his off
   mark his off ; hide

: tcb, ( - )
   self here dup kid ! tcbsize dup allot cmove
   kid @ init-slave
   memory him off
   sibling him off
   children him off
   current @ him current him !
   swb searching @ 0
   ?do dup @ dup self dup tcbsize + within
      if him then over him ! cell+
   loop drop ; hide

: make-child ( - )
   kid @ self last-child dup self =
   if drop children
   else sibling his
   then ! ; hide

: wake ( up - ) self
   begin 2dup =
      if drop drop exit
      then @ dup self =
   until @ over ! self ! ;

: sleep ( up - ) self
   begin 2dup @ <>
   while @ dup self =
      if drop drop exit then
   repeat push @ pop ! ;

: /memory ( a - ) dup
   begin @ dup
   while dup cell+ free drop
   repeat drop off ; hide

defer halt

: /relatives ( up a - )
   his dup
   begin @ dup
   while dup halt sibling his
   repeat drop off ; hide

: (halt) ( up - )
   dup children /relatives
   dup memory his /memory
   sleep ; hide
   ' (halt) is halt

: stop ( - ) self sleep pause ;

: dispatch ( xt - ) catch self halt pause ; hide

: assign ( xt up - ) kid ! sp him spush ['] dispatch rp him spush ;

: launch ( xt - ) kid @ assign kid @ wake ; hide

: start ( up - )
   dup init-slave kid !
   pop launch ;

: task ( - ) tcb, make-child ;

: child ( xt - ) align task launch ;

: dictionary ( u - )
   ablock * dup allocate throw push 2/ r@ + dup pop
   dp @ push dp ! tcb, here dup pop dp !
   hp him ! hp0 him ! dp him ! dp0 him ! ; hide

: slave ( u - up )
   dictionary make-child kid @ ;

: master ( u - up )
   dictionary kid @
   memory pop-link memory him push-link ;

: stackitems ( n - )
   dup push 0 ?do rp him spush loop pop
   0 ?do rp him spop sp him spush loop ; hide

: cede ( n up - )
   dup init-slave kid ! push p @ pop 1+ stackitems
   ['] fread launch finish on ; fhide

: cede ( n up - )
   dup init-slave kid ! push source> pop 2 + stackitems
   ['] evaluate launch finish on ;

: ignore ( a - )
   >body cell+ push
   @r+ get-current !
   @r+ enth !
   @r+ macro !
   pop @ flux ! ;

: bcb! ( a - )
   get-current @ swap >body push
   @r+
   @r+ get-current !
   @r+ enth !
   @r+ macro !
   @r+ flux !
   [ 5 cells ] literal r+
   @r+ swap 2dup - self + self dup tcbsize + within
   if - self + then pop @ swap !
   get-current @ over cell- !
   get-current ! ; hide

: mcb! ( a - )
   push
   @r+ self =
   if @r+ get-current !
      @r+ enth !
      @r+ macro !
      @r+ flux !
      @r+ dp !
      @r+ hp !
      @r+ mark !
      @r+ /memory
      @r+ dup self =
      if children
      else sibling
      then /relatives
   then pop drop ; hide


: mcb@ ( - nx .. n0 )
   self last-child
   memory last-link
   mark @
   hp @
   dp @
   flux @
   macro @
   enth @
   get-current @
   self ; hide

: mcb, ( nx .. n0 - )
   , , , , , , , , , , get-current dup , @ , ; hide

: empty  ( - ) begin mark @ dup while execute repeat drop
   here mcb@ mcb, here swap postpone literal postpone mcb! postpone exit mark !  ;

: marker ( - ) mcb@ create mcb, get-current @ nfa>cfa mark ! does> mcb! ;

: branch ( a - ) marker bcb! ;

: amark mcb@ fcreate mcb, get-current @ nfa>cfa mark !
   1 default does> mcb! ; hide
: abranch amark bcb! ; hide

: ms ( n - ) push fff8 @ begin pause fff8 @ over - r@ > until pop 2drop ;

variable memory1 2000000 memory1 ! hide

0c constant allochead hide

: allocend ( a - b )
   cell+ dup @ cell+ cell+ + ; hide

: (allocate) ( u - a ior )
   a@ push aligned 100000 a!
   begin @a
   while dup a@ dup @ swap allocend - allochead - 1+ <
      if a@ dup allocend dup push over @ !r+ swap !
         !r+ r@ memory push-link 0 !r+ pop false pop a! exit
      then @a a!
   repeat dup a@ allocend + allochead + memory1 @ 1+ <
   if a@ dup allocend dup push 0 !r+ swap !
      !r+ r@ memory push-link 0 !r+ pop false pop a! exit
   then true pop a! ; hide

: (free) ( a - ior )
   a@ push 0c - 100000 dup push a!
   begin dup a@ =
      if drop @a pop ! false pop a! exit
      then @a dup
   while pop drop a@ push a!
   repeat drop drop pop drop true pop a! ; hide

: (resize) ( a u - b ior )
   drop true ; hide

' (allocate) is allocate
' (free) is free
' (resize) is resize

\ ------------- Task Zero ------------------------------------------------------

code INIT ( - )
   pop edx
   mov ebp kernel #
   mov esi ebp
   add esi tcb>sp0 #
   mov esp ebp
   add esp tcb>rp0 #
   jmp edx end-code hide

: COLD ( - ) init 100000 push 0 !r+ 40000 !r+ 0 pop !
   begin 20000 superblock ! 1 ['] fload catch drop again ; hide

defer load ' fload is load fhide
defer read ' fread is read fhide
: vars ['] avar 1 token ; fhide
: marker ['] amark 1 token ; fhide
: branch ['] abranch 1 token ; fhide
: macros ['] amacro 1 token ; fhide
: : 1 default ; fhide

: var here get-current @ nfa>cfa =
   if align-1 here newcfa then postpone dovar ; mhide

: if ( - a ) 74 1, here 0 1, ; mhide
: then ( a - ) here over - 1- size? swap c! reset ; mhide
: ; @hist 1 = if E9 here 5 - c! exit then C3 1, ; mhide
: dup drop? if -1 allot 8B06 2, exit then nip? if -3 allot
   8906 2, exit then 8D76FC 3, 8906 2, ; mhide
