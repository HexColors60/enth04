\ EMAKE.F

\ Makefile to run Enth Crude Metacompiler generating ENTH.BIN.

\ Tested under: Win32Forth 4.2 Build 0671.

\ I'm not even going to try and document this. The whole Metacompiler setup is
\ an interim measure anyway. Downright ugly too. Can I convince you not to
\ advance past this point? :-)


\ Win32Forth Specific Words
sys-warning-off nostack warning off
\ Comment out the above and you have a fair to middling chance of running this
\ file under other ANS Forths. SwiftForth 2.00.3 seemed happy enough.


base @ get-order get-current
marker enth-compile

variable sp

: spush ( n - ) sp @ @ cell+ dup sp @ ! ! ;
: spop ( - n ) sp @ @ dup cell- sp @ ! @ ;
: sdepth ( - n ) sp @ dup @ swap - 4 / ;

: stack ( n - ) create here , cells allot does> sp ! ;

64 stack alloc

: allocate ( n - a ) allocate over alloc spush ;
: freeall ( - ) alloc sdepth 0
   ?do alloc spop free drop loop ;

Include Sasm.f
Include Meta.f
Include Enth.f

hex

' cold torigin !
there  fspace - kernel tcb>dp + !
hhere  fspace - kernel tcb>hp + !
tspace fspace - kernel tcb>dp0 + !
hspace fspace - kernel tcb>hp0 + !
enthlink { @ } kernel tcb>enth + !
fluxlink { @ } kernel tcb>flux + !
macrolink { @ } kernel tcb>macro + !
hidelink { @ } hidden !

{ s" enth.bin" write-binary

freeall

set-current set-order base !
enth-compile \ bye
