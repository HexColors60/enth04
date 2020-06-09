; EBOOT.ASM                             July 23rd, 2002 - 1:24      Sean Pringle
; Copyright (c) 2001 Sean Pringle

; Assembler code written for NASM 0.98
; Boot Sector code for loading and jumping to execute the ENTH Forth kernel.

[BITS 16]
[ORG 07C00h]
jmp start

vmode dw 117h                           ; 1024x768 pixels
;vmode dw 114h                           ; 800x600 pixels

dot    db '.',0
query  db '?',0
greet  db 'Enth',0
vesa   db 'Vesa',0

bootdrive     db 0                      ; boot drive
retry         db 0                      ; disk read retry limit
destination   dw 1000h
offset        dw 0
readops       db 0                      ; read operations completed
startsector   db 1                      ; track sector from which to start
numbersectors db 18                     ; sectors to read
pages         db 3                      ; 64k pages to read
bounds        db 2

track      equ 18
sectorsize equ 512
firstsec   equ 1
lasthead   equ 1

; ******************************************************************************

start:                                  ; untangle the bootlaces!
        xor ax, ax                      ; make sure we have the right data seg
        mov ds, ax
        cli
        mov ax, 0x9000                  ; stack at 90000h
        mov ss, ax
        mov sp, 0xFFFF
        sti

readdisk:                               ; read system kernel from the boot disk
        mov [bootdrive], dl             ; save boot drive
        xor ax, ax                      ; al = 00h reset diskette/hard drive
        int 13h                         ; reset disk controller
        jnc sayhi
        mov si, query
        call text
        jmp $

sayhi:                                  ; yes, we are alive
        mov si, greet
        call text

readimage:
        call readtrack                  ; 1 floppy track = 9k
.again: call readtrack
        call readtrack
        call readtrack
        call readtrack
        call readtrack
        call readtrack
        mov bx, [bounds]                ; eighth read crosses 64k page boundary
        call readsectors                ; split track read into two operations
        add byte [bounds], 2            ; adjust for next split read
        dec byte [pages]
        jnz .again

flopyoff:
        mov dx, 3f2h                    ; floppy motor off
        xor ax, ax
        out dx, al

; ******************************************************************************

; Set Video. First try for 16 bit color. If that fails then try for 15 bit color.

vid0:
        call vidtest
        sub word [vmode], 2
        call vidtest

vidbad:
        mov si, vesa
        call text
        jmp $

vidtest:
        call vidmode
        dec word [vmode]

vidmode:
        mov cx, [vmode]
        xor ax, ax
        mov es, ax
        mov di, 0f800h
        mov ax, 04f01h                  ; VBE function 1
        int 10h
        or ax, ax
        jz .nope
.check:
        mov bx, [vmode]
        call vdescript
        mov [gs:si-2], ax
        mov ax, [gs:si]
        test ax, 1h                     ; Video Mode available
        jz .nope
        test ax, 80h                    ; Linear Frame Buffer available;
        jz .setmode
        or bx, 04000h
.setmode:
        mov [gs:si-2], bx
        mov ax, 04f02h
        int 10h                         ; Set Video Mode
        or ax, ax
        jnz vidok

.nope:  ret

vidok:
        call vdescript
        mov ax, [gs:si-2]
        test ax, 4000h
        jnz .scan

        mov [gs:si-8], ax
        mov [gs:si-6], ax
        mov [gs:si-4], ax

        mov ax, 04f0Ah                  ; Get Protected Mode Interface Table
        xor bx, bx
        int 10h
        or ax, ax
        jz vidbad
        call vdescript
        mov [gs:si-8], es
        mov [gs:si-6], di
        mov [gs:si-4], cx

.scan:
        mov ax, 4f07h                   ; Set first scanline and pixel = 0
        xor bx, bx
        xor cx, cx
        xor dx, dx
        int 10h


; ******************************************************************************

; Transfer the Protected Mode entry code, Global and Interupt Desciptor tables
; down to 0000xfc00.

transfer:
        cli
        cld
        xor ax, ax
        mov es, ax
        mov di, 0fc00h                  ; 10000h - 400h
        mov ax, 1000h
        mov ds, ax
        mov si, 200h
        mov cx, 200h                    ; 400h bytes
        repnz movsw                     ; ds:si to es:di

; Align Enth Kernel to 1000x0000.

        mov ax, 1000h
        mov es, ax
        mov di, 0h
        mov ds, ax
        mov si, 600h
        mov cx, 6600h                   ; kernel only, not font
        repnz movsw                     ; ds:si to es:di

; Now we must transfer program execution to the copy of the system at 0000xfbff.

        xor ax, ax                      ; set registers to code position
        mov ds, ax
        mov es, ax
        push ax                         ; segment address onto stack
        mov ax, 0fc00h
        push ax                         ; offset address onto stack
        retf                            ; pop offset to ip, pop segment to cs

; ******************************************************************************

text:                                   ; display a message, teletype style
        lodsb                           ; load byte at ds:si into al
        or al, al                       ; 0=
        jz .end                         ; if ret then
        mov ah, 0Eh                     ; ah=0eh write char to screen teletype
        int 10h
        jmp text
.end:   ret

vdescript:                              ; 0000xf800 = VESA mode descriptor
        xor ax, ax
        mov gs, ax
        mov si, 0f800h
        ret

; ******************************************************************************

; Floppy read code. Not pretty.

readtrack:
        mov bx, track                   ; number of sectors
readsectors:
        mov ax, firstsec                ; start sector
        call readdata
        xor ax, ax
        mov al, [numbersectors]
        cmp al, track
        je .ok                          ; read full track?
        add word [destination], 1000h   ; nope, move to next 64k page
        add al, firstsec                ; read from next start sector
        mov bl, track
        sub bl, [bounds]                ; read remaining sectors in track
        call readdata
.ok:    inc byte [readops]              ; completed one track
        mov si, dot                     ; so we display a dot
        call text
        ret

readdata:
        mov [numbersectors], bl
        mov [startsector], al
        mov byte [retry], 2

.doread:mov ax, [destination]
        mov es, ax
        mov bx, [offset]                ; 9k
        mov dl, [bootdrive]             ; read from boot drive
        mov dh, [readops]
        and dh, lasthead                ; head number
        mov ah, 02h                     ; ah=02h read sectors into memory
        mov al, [numbersectors]         ; number of sectors
        mov cl, [startsector]           ; start sector
        mov ch, [readops]
        shr ch, lasthead                ; track number
        int 13h                         ; do it
        jnc .done                       ; retry upon error
        mov si, query
        call text
        dec byte [retry]                ; retry read 3 times
        jnz .doread
        jmp $

.done:  mov ax, sectorsize
        xor bx, bx
        mov bl, [numbersectors]
        mul bx
        add word [offset], ax           ; advance offset into current 64k page
        ret

; ******************************************************************************

        times 510-($-$$) db 0           ; append 0xAA and 0x55 - needed for boot
        dw 0AA55h                       ;  file
