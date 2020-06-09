./nasm -fbin emakeimg.asm -o enth.img
dd if=enth.img of=/dev/fd0
