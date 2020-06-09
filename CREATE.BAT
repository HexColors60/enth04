nasmw -f bin -o eboot.bin eboot.asm
nasmw -f bin -o ekernel.bin ekernel.asm
nasmw -f bin -o enth.img emakeimg.asm
rawrite -f enth.img -d a: -n
