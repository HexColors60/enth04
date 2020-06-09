; EMAKEIMG.ASM                          October 6th, 2000 - 3:15    Sean Pringle

[BITS 16]
[ORG 0]

incbin "eboot.bin"
incbin "ekernel.bin"
incbin "enth.bin"

times 0d800h-($-$$) db 0h
incbin "font.bin"

times 10000h-($-$$) db 0h       ; System Source Blocks at 20000
incbin "source.blk"
