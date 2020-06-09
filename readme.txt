sof\readme.html
readme
Readme

> September 22nd, 2002

---

 Enth is Copyright (c) 2002 Sean Pringle. This version of Enth is released to the
      Public Domain.
 Enth comes with ABSOLUTELY NO WARRANTY. No responsibility for anything will be
      assumed by Sean Pringle. By using Enth or it's applications, including Flux,
      you agree there is no implied warranty with regard to useability,
      reliability or support.

---

_*Video*_

Runs at 1024x768 pixels, 64k or 32k colors, by default. Requires VESA 2.0+
video card with Linear Frame Buffer support. Failure to initialise the video
will result in a 'Vid' error appearing during boot and system will hang. 

To run at 800x600 pixels, alter the VMODE line in EBOOT.ASM and recreate the
boot disk image by running CREATE.BAT.

_*Interface*_

Default post boot interface is the Flux Color Editor. There is no longer any
distinction between the Forth the Editor and Forth the Terminal, they are one
and the same.

*The color editor:*

The color editor is started automatically at BLOCK 0, Line 0 at boot. Each block
is 1024 bytes wide. The editor operates like a sequential file editor within
each block. Keyboard layout is standard QWERTY. Normal text editing functions
are used including keys like SHIFT, CAPS, BKSPC, DEL, HOME, END and the ARROWs.

*Special control keys:*

 PGUP / PGDN             scroll through blocks.

 F1-F10                  insert color tokens/spaces.

 SPACEBAR                insert last used color token.

 CTRL then F1-F10        insert color token that doubles as a line break.

 ALT                     alternate between code and shadow blocks

 F12                     insert normal ascii blank space.

*Upper right of screen displays:*

* block number
* number of free characters remaining on block
* action, color and function key of token or word under cursor

*The interactive terminal:*

BLOCK 0 acts as the system terminal input buffer. Use the editor to edit the
top line of BLOCK 0 and press the enter key. BLOCK 0 will be interpretted until
the word OK is encountered, whereupon editing will be restarted. OKs are
inserted automatically.

Command line history scrolls down the page. Because you are simply editing a
block, holding down the delete key until the required previous command line
reaches the top of the page gives you a simple form of command history.

Experiment with the colors and function keys. Look at BLOCK 1, it has some
useful words defined on it.

_*Recommendation*_

Take it slow. The learning curve may be steep for some. Those who have
experience with Chuck Moore's colorForth may recognise some things, but be
warned: there will also be things you won't recognise. Flux is not a colorForth
clone by any means, though certainly a cousin :)

_*ANS Forth*_

Yes, as in the original release, Enth contains an ANS Forth based kernel. That
is to say kernel words that also exist in ANS Forth should behave as the
standard defines them. The Enth interpretter loop should behave in an ANS Forth
fashion. At least such is the idea. Don't be surprised by bugs.

Flux is a dual wordlist cmForth/colorForth model Forth implemented on top of
Enth (actually beside Enth now as it is in the kernel). Don't go into it with
any preconceptions.

Yes, the primary Enth interface is now the colored Flux editor. This means
writing color code is easy and even simple. The Enth ANS Forth interpretter
still operates though and you can access it simply through EVALUATE or ELOAD.
The more dedicated programmer may see other ways of reconfiguring the system to
become ANS again. Feel free.

It is my intention to reimplement the ANS Forth terminal interface as an
application and an alternative to the color editor. Maybe in color code. Maybe
not. Don't know yet.

_*Where to?*_

I've been using this system in various forms for the past two years. It changes
sometimes, depending on its task. This release is a snapshot of its current
configuration. I wanted to consolidate it a little before releasing again, but
it refuses to co-operate. So WYSIWYG. I guess as very few people seem to be
using it anyway, what direction it takes is of little matter. It goes whereever
the territory appears interesting :)

_*Your Code*_

Feel free to contribute. Nobody really has, so far. So consider it a blank
slate. I'll look at anything.

_*Source Code*_

 EBOOT.ASM       is the boot sector code.
                 Boot and Video.

 EKERNEL.ASM     is a second stage boot loader.
                 GDT. IDT. IRQs.

 EMAKEIMAGE.ASM  assembles the binary files into one bootable image.

All three are NASM compilable. All are automatically recompiled if CREATE.BAT is
run.

 SOURCE.BLK      System color source code.

 COLORHTML.F     HTML generator for SOURCE.BLK.

 ENTH.F          Kernel.

 EMAKE.F         Run metacompiler to recompile Kernel into ENTH.BIN.
                 Win32Forth 4.2 compilable.

_*Memory Maps*_

*System Memory Structure*

  0h     -> 0FFFFh        GDT. IDT. IRQ variables. VESA video descriptor.
  10000h -> 1FFFFh        Kernel.
  20000h -> 3FFFFh        128 System Color Forth Source Blocks, half code, half shadow.
  40000h -> 8FFFFh        Vacant.
  90000h -> 9FFFFh        DMA Transfer Buffer.
 100000h ->               Allocatable Memory Space.

*Boot Disk Structure*

 0h     -> 0FFFFh        Boot code, descriptor tables and Kernel.
 10000h -> 2FFFFh        128 System Color Forth Source Blocks, half code, half shadow.
 30000h ->               Vacant.

_*Memory Managment*_

ALLOCATE and FREE as in ANS Forth.

 BLOCKS          ( u - a )
         ALLOCATE U contiguous blocks of memory and return their address.
 BLOCK           ( u - a )
         Return start address of block U.
 SUPERBLOCK      ( - a )
         A User Variable. A task's BLOCK references are based relative to the
         value stored in this variable.

_*Multitasking*_

 TASK            ( - )
         Usage: CREATE CHARLIE TASK
         Else: HERE TASK CONSTANT CHARLIE
         Or in color: <red>CHARLIE<white>TASK (reference as address: <yellow>CHARLIE)

 WAKE            ( up - )
         Wake task UP. eg CHARLIE WAKE

 SLEEP           ( up - )
         Sleep task UP. eg CHARLIE SLEEP

 START           ( up - )
         WAKE task UP and begin it executing current definition following START.

 STOP            ( - )
         Volantarily go to SLEEP.

 ASSIGN          ( xt up - )
         Initialise task UP to start executing word XT when next aWAKEned.

 PAUSE           ( - )
         Perform a task switch.

 MS              ( n - )
         Continue to PAUSE for n milliseconds.

 CHILD           ( xt - )
         Create background child task. ASSIGN xt to it. WAKE it. A CHILD cannot
         compile.

 SLAVE           ( u - up )
         Create a SLAVE task with dictionary of U Blocks. A SLAVE can compile yet
         remains under control of the creating task.

 MASTER          ( u - up )
         Create autonomous MASTER task with dictionary of U Blocks. A master can
         compile and remain active after its creating task dies.

 CEDE            ( n up - )
         Hand N stack items to MASTER or SLAVE task UP. Start task UP compiling
         the current source block following CEDE.

 HALT            ( up - )
         HALT task UP. If task UP has children HALT them too. If task UP has
         ALLOCTEd memory, free it. HALTing a MASTER task will kill and erase it
         completely, along with any children it may have. It can never be reused.
         HALTing a SLAVE or CHILD task with merely reset them. They may be
         reused until their creator MASTER task is HALTed.

_*MARKERs and BRANCHs_*

MARKER operates similar to the ANS Forth fashion. Execution of a MARKER will
roll back the system to the point just before the MARKER's definition. A MARKER
may only be executed by the task that created it. Roll back affects the
dictionary pointers and wordlists of that task. It also frees any memory
ALLOCATEd to that task since MARKER's creation and HALTs any children tasks
created since MARKER's creation.

BRANCH creates a branchpoint, in the dictionary, from a previous MARKER, hiding
words defined since the previous MARKER was created. Execution of a BRANCH rolls
back anything defined since the BRANCH was created and reinstates the dictionary
wordlists as they were previous to BRANCH being created. A BRANCH affects
the dictionary, alllocated memory and children tasks just as MARKER affects
them.

_*Video Output*_

 SCREEN          ( - )
        Compile video output words. Block 7.
