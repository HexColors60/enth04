\ COLORHTML.F

\ Reads Color Code source file SOURCE.BLK and generates SOURCE.HTML.
\ Quick and dirty.

\ Tested under Win32Forth 4.2 Build 0671

marker colorhtml

hex

variable sourcespot
variable sourcesize
variable sourceid

s" SOURCE.BLK" r/o open-file drop sourceid !
sourceid @ file-size drop d>s sourcesize !
sourcesize @ allocate drop sourcespot !
sourcespot @ sourcesize @ sourceid @ read-file drop drop
sourceid @ close-file drop

variable activeid

s" SOURCE.HTML" r/w create-file drop activeid !

: active! ( a u - )
   activeid @ write-file drop ;

: place  ( a u a2 - )
   over over c! 1+ swap cmove ;

: append ( a u a2 - )
   2dup 2>r dup c@ + 1+ swap cmove 2r> swap over c@ + swap c! ;

: place, ( a u - )
   here over 1+ allot place ;

create spad 400 allot
variable mode

: replace| mode ! [char] | parse [char] | parse
   create here >r 0 , 0 , mode @ , here r@ ! place, here r> cell+ ! place,
   does> >r r@ cell+ cell+ @ mode @ <>
      if r@ @ count active! r@ cell+ @ count active! r@ cell+ cell+ @ mode !
      then spad count active! r> drop ;

: f0 1 throw ;

1 replace| <font color="#ff0000">|</font>| f1
2 replace| <font color="#00ff00">|</font>| f2
3 replace| <font color="#ffffff">|</font>| f3
4 replace| <font color="#00ffff">|</font>| f4
5 replace| <font color="#ff00ff">|</font>| f5
6 replace| <font color="#ffff00">|</font>| f6
7 replace| <font color="#99aa66">|</font>| f7
8 replace| <font color="#0099ff">|</font>| fx

: html| [char] | parse active! ;

html| <html><head><title>SOURCE.BLK</title></head>|
html| <body bgcolor="#000000">|
html| <font face="courier" size="5"><b>|

create replacement
   ' f0 , ' f1 , ' f2 , ' f3 , ' f4 , ' f5 , ' f6 , ' f7 ,
   ' fx , ' fx , ' fx , ' fx , ' fx , ' fx , ' fx , ' fx ,

: replace ( n - )
   dup 0f0 and if s" <br>" active! then 00f and cells replacement + @ execute ;

: u+ ( n - ) swap >r + r> ;
: @+ ( a - b c ) dup c@ 1 u+ ;

variable p

: point ( n - )
   spad c@ + spad c! ;

: sadd ( a - )
   count spad append ;

: cadd ( c - )
   spad count + c! 1 point ;

: blank ( - )
   spad count + 1- c@ bl = if c" &nbsp;" sadd else bl cadd then ;

: add ( c - )
   dup bl = if drop blank exit then cadd ;

: skip ( a - b ) 0 spad !
   begin 2dup < throw @+ 21 <
   while blank
   repeat 2 - ;

: scan ( a - b )
   begin @+ dup 1f > while add repeat drop 1 - ;

: word ( - t ) skip @+ >r scan r> replace ;

: block 400 * ;

: process ( u - ) s" <p>" active! 0 mode ! block sourcespot @ + dup 1 block u+
   begin word again ;

: all ( n - )
   0 ?do i ['] process catch drop drop loop ;

decimal

html| <font>|

128 all

html| </font>|
html| </b></font>|
html| </body></html>|

sourcespot @ free drop
activeid @ close-file drop

colorhtml bye
