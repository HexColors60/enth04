; EKERNEL.ASM                           July 23rd, 2002 - 1:24      Sean Pringle
; Copyright (c) 2001 Sean Pringle


; Assembler code written for NASM 0.98
; Protected Mode and Forth kernel for ENTH.

[BITS 16]
[ORG 0fc00h]

jmp start

;-------------- Descriptor Tables ----------------------------------------------

gdtinfo:
        dw gdt_end - gdt        ; gdt length
        dd gdt          ; gdt linear address

idtinfo:
        dw idt_end - idt        ; idt length
        dd idt          ; idt linear address

; Basic Flat Model memory managment

gdt:
dummy32:        dd 0,0          ; dummy
cseg equ $-gdt                  ; code segment
code32: dw 0FFFFh               ; limit FFFF, * granularity
        dw 0h                   ; base 0
        db 0
        db 09Ah                 ; present, ring0, code, expand-up, writable
        db 0CFh                 ; granularity 4K, 32bit
        db 0h
dseg equ $-gdt                  ; data segment
data32: dw 0FFFFh               ; limit FFFF, * granularity
        dw 0h                   ; base 0
        db 0
        db 092h                 ; present, ring0, code, expand-up, writable
        db 0CFh                 ; granularity 4K, 32bit
        db 0h
gdt_end:db 0

idt:    dw what?
        dw cseg
        db 0
        db 0x8E
        dw 0

        dw what?
        dw cseg
        db 0
        db 0x8E
        dw 0

        dw what?
        dw cseg
        db 0
        db 0x8E
        dw 0

        dw what?
        dw cseg
        db 0
        db 0x8E
        dw 0

        dw what?
        dw cseg
        db 0
        db 0x8E
        dw 0

        dw what?
        dw cseg
        db 0
        db 0x8E
        dw 0

        dw what?
        dw cseg
        db 0
        db 0x8E
        dw 0

        dw what?
        dw cseg
        db 0
        db 0x8E
        dw 0

        dw what?
        dw cseg
        db 0
        db 0x8E
        dw 0

        dw what?
        dw cseg
        db 0
        db 0x8E
        dw 0

        dw what?
        dw cseg
        db 0
        db 0x8E
        dw 0

        dw what?
        dw cseg
        db 0
        db 0x8E
        dw 0

        dw what?
        dw cseg
        db 0
        db 0x8E
        dw 0

        dw what?
        dw cseg
        db 0
        db 0x8E
        dw 0

        dw what?
        dw cseg
        db 0
        db 0x8E
        dw 0

        dw what?
        dw cseg
        db 0
        db 0x8E
        dw 0

        dw what?
        dw cseg
        db 0
        db 0x8E
        dw 0

        dw what?
        dw cseg
        db 0
        db 0x8E
        dw 0

        dw what?
        dw cseg
        db 0
        db 0x8E
        dw 0

        dw what?
        dw cseg
        db 0
        db 0x8E
        dw 0

        dw what?
        dw cseg
        db 0
        db 0x8E
        dw 0

        dw what?
        dw cseg
        db 0
        db 0x8E
        dw 0

        dw what?
        dw cseg
        db 0
        db 0x8E
        dw 0

        dw what?
        dw cseg
        db 0
        db 0x8E
        dw 0

        dw what?
        dw cseg
        db 0
        db 0x8E
        dw 0

        dw what?
        dw cseg
        db 0
        db 0x8E
        dw 0

        dw what?
        dw cseg
        db 0
        db 0x8E
        dw 0

        dw what?
        dw cseg
        db 0
        db 0x8E
        dw 0

        dw what?
        dw cseg
        db 0
        db 0x8E
        dw 0

        dw what?
        dw cseg
        db 0
        db 0x8E
        dw 0

        dw what?
        dw cseg
        db 0
        db 0x8E
        dw 0

        dw what?
        dw cseg
        db 0
        db 0x8E
        dw 0
;32
        dw isr0
        dw cseg
        db 0
        db 0x8E
        dw 0
;33
        dw isr1
        dw cseg
        db 0
        db 0x8E
        dw 0
;34
        dw ohyeah
        dw cseg
        db 0
        db 0x8E
        dw 0
;35
        dw ohyeah
        dw cseg
        db 0
        db 0x8E
        dw 0
;36
        dw ohyeah
        dw cseg
        db 0
        db 0x8E
        dw 0
;37
        dw ohyeah
        dw cseg
        db 0
        db 0x8E
        dw 0
;38
        dw isr6
        dw cseg
        db 0
        db 0x8E
        dw 0
;39
        dw ohyeah
        dw cseg
        db 0
        db 0x8E
        dw 0
;40
        dw isr8
        dw cseg
        db 0
        db 0x8E
        dw 0
;41
        dw ohyeah
        dw cseg
        db 0
        db 0x8E
        dw 0
;42
        dw ohyeah
        dw cseg
        db 0
        db 0x8E
        dw 0
;43
        dw ohyeah
        dw cseg
        db 0
        db 0x8E
        dw 0
;44
        dw isr12
        dw cseg
        db 0
        db 0x8E
        dw 0
;45
        dw ohyeah
        dw cseg
        db 0
        db 0x8E
        dw 0
;46
        dw ohyeah
        dw cseg
        db 0
        db 0x8E
        dw 0
;47
        dw ohyeah
        dw cseg
        db 0
        db 0x8E
idt_end:dw 0

; ------------- Code -----------------------------------------------------------

start:

; Prepare for Protected Mode

gopmode:lgdt [gdtinfo]                  ; set new global descriptor table
        lidt [idtinfo]                  ; set new interupt descriptor table

; Revector IRQs  (I)nitialization (C)ommand (W)ord
;                (O)utput (C)ontrol (W)ord
; Vector IRQs 0-15 to selector places 32-47 in the interupt desciptor table
; This separates them from the protected mode interupts which is useful :)

vectorirqs:
.icw1:  mov al, 011h                    ; initialization mode
        out 020h, al                    ; PIC 1
        out 0A0h, al                    ; PIC 2
.icw2:  mov al, 020h                    ; IRQ0-IRQ7 -> interrupts 0x20-0x27
        out 021h, al
        mov al, 028h
        out 0A1h, al                    ; IRQ8-IRQ15 -> interrupts 0x28-0x2F
.icw3:  mov al, 4h                      ; bit 2 set, slave cascaded on ir2
        out 021h, al
        mov al, 2h                      ; bit 1 set, slave 2
        out 0A1h, al
.icw4:  mov al, 01h                     ; bit 0 set, 8086 mode
        out 021h, al
        out 0A1h, al
.ocw1:  mov al, 10111000b               ; IRQ 0,1,2 & 6 enabled
        out 021h, al
        mov al, 11111110b               ; IRQ 8 enabled
        out 0A1h, al

; Enable A20 line

goa20:  call chkcmdbuf
        mov al, 0D1h
        out 64h, al
        call chkcmdbuf
        mov al, 0DFh                    ; set a20 line
        out 60h, al
        call chkcmdbuf

; Do the switch to protected mode.

        mov eax, cr0
        or al, 1                        ; set p bit
        mov cr0, eax
        jmp cseg:goforth                ; clear prefetch q upon jmp

; Technically, the Bootstrap ends now!

[BITS 32]                               ; we are now 32bit code, protected mode
goforth:mov ax, dseg                    ; load new data segment
        mov ds, ax                      ; update segment registers
        mov ss, ax
        mov es, ax
        mov fs, ax
        mov gs, ax

        mov al, 0bh                     ; enable RTC periodic interrupt
        out 070h, al                    ; select status reg B
        in al, 071h                     ; read srB
        mov dl, al
        or dl, 040h                     ; set periodic interrupt bit
        mov al, 0bh
        out 070h, al                    ; select srB
        mov al, dl
        out 071h, al                    ; write srB
        mov al, 0ch
        out 070h, al                    ; select srC
        in al, 071h                     ; read srC (chip int ack)

        sti

        mov al, 0AEh                    ; enable keyboard
        out 64h, al

        mov eax, 10000h
        mov eax, [eax]
        jmp eax                         ; start Forth

chkcmdbuf:                              ; checks keyboard command buffer
        in al, 64h
        and al, 02h
        jnz short chkcmdbuf
        ret
reset8259m:
        mov al, 20h
        out 020h, al                    ; reset master PIC
        ret
reset8259s:
        mov al, 20h
        out 0A0h, al                    ; reset both slave and master PICs
        out 020h, al
        ret

; The (I)terupt (S)ervice (R)outines

isr0:                                   ; ISR for IRQ 0 = Timer, 18.2 Hz
        push eax
        call reset8259m
        pop eax
        iret
isr1:                                   ; ISR for IRQ 1 = Keyboard
        push eax
        mov dword [kbdevent], 60h
        call reset8259m
        pop eax
        iret
isr2:                                   ; ISR for IRQ 2 = cascade
        push eax
        call reset8259m
        pop eax
        iret

; The Real Time Clock is set to generate a periodic interupt at 1024 Hz. All we
; do here is to inc a variable that ENTH may notice upon a whim (or not!). Used
; for MS. *** Must read status register C !!! (reset the chip :) ***

isr8:                                   ; ISR for IRQ 8 = RTC, 1024 Hz
        push eax
        inc dword [clkevent]            ; inc clock count
        mov al, 20h                     ; much faster coding PIC resets inline
        out 0A0h, al                    ; here, compared to 2 calls
        out 020h, al
        mov al, 0Ch                     ; read status register C
        out 070h, al                    ; this is the clock's interupt ack.
        in al, 071h
        pop eax
        iret
isr6:                                   ; ISR for IRQ 6 = Floppy Disk Controller
        push eax
        mov dword [fdcevent], 8         ; flag = sense interupt command
        call reset8259m
        pop eax
        iret
isr12:                                  ; ISR for IRQ 12 = PS2 Mouse
        push eax
        dec dword [ps2event]
        call reset8259s
        pop eax
        iret

ohyeah:                                 ; default ISR
        iret
what?:                                  ; unhandled int/fault
        iret

times 1024-($-$$)-(5*4) db 0h

ps2event: dd 0
tmrevent: dd 0
kbdevent: dd 0
clkevent: dd 0
fdcevent: dd 0      

