 @set file=piBacteria

@rem "c:\Program Files\qemu\qemu-system-arm.exe" -M raspi1ap -serial stdio -kernel %file%.img -d in_asm
"c:\Program Files\qemu\qemu-system-arm.exe" -M raspi1ap -serial stdio -kernel %file%.img

@pause 0	