		format	binary as 'img'

		processor CPU32_V1 + CPU32_V2 + CPU32_V3 + CPU32_V4 + CPU32_V4T + CPU32_V6T + CPU32_P + CPU32_V6 + CPU32_E + CPU32_A

qemu 			= 1
debug 			= 1

if qemu = 1
		org 	0x10000
else
		org 	0x8000
end if

GPBASE 			= 0x20200000
GPFSEL0 		= 0x00
GPFSEL1 		= 0x04
GPFSEL2 		= 0x08
GPSET0 			= 0x1c
GPCLR0 			= 0x28
GPLEV0 			= 0x34
GPPUD 			= 0x94
GPPUDCLK0 		= 0x98

MBOXBASE 		= 0x2000B880
MBOXREAD 		= 0x00
MBOXSTATUS 		= 0x18
MBOXWRITE 		= 0x20

AUXBASE 		= 0x20215000
AMENABLES 		= 0x04
AMIOREG 		= 0x40
AMIERREG 		= 0x44
AMIIRREG 		= 0x48
AMLCRREG 		= 0x4C
AMMCRREG 		= 0x50
AMLSRREG 		= 0x54
AMCNTLREG 		= 0x60
AMBAUDREG 		= 0x68

STBASE 			= 0x20003000
STCS 			= 0x00
STCLO_ 			= 0x04
STC1 			= 0x10
INTBASE 		= 0x2000b000
INTENIRQ1 		= 0x210

UART0_DR 		= 0x20201000

MEMORY 			= endf
LTABLE 			= endf + 0x10026

iyi     equ		r0
mem     equ		r1
stlo    equ     r2
pcff    equ     r3
spfa    equ     r4
bcfb    equ     r5
defr    equ     r6
hlmp    equ     r7
arvpref equ     r8
ix      equ     r9

; Allow misaligned reads/writes and load a memory pointer
        mrc     p15, 0, r0, c1, c0, 0   ; read control register
        orr     r0, r0, (1 shl 22)   	; set the U bit (bit 22)
        mcr     p15, 0, r0, c1, c0, 0	; write control register
        ldr     mem, [memo]

; This is to set the video buffer to 352x264x4
        ldr     r2, [mboxb]
        add     r0, mem, ogetrev + 8
        mov     r4, 8
        bl      mbox
        ldr     r3, [mem, ogetrev + 20]
        cmp     r3, 4
        bcs     nrev1
nrev1:  mov     r4, 1
        add     r0, mem, ofbinfo + 1
        orr     r0, 0x40000000
        bl      mbox

; Zero the rows and pull up the columns (and the EAR port)
        ldr     r0, [gpbas]
        mov     r2, 001000001b      ; configure speaker output
        str     r2, [r0, GPFSEL0]
        mov     r2, 2
        str     r2, [r0, GPPUD]
        bl      wait
        ldr     r2, [filt]
        str     r2, [r0, GPPUDCLK0]
        bl      wait
        str     r2, [r0, GPPUD]
        ldr     r3, [rows]
        str     r3, [r0, GPCLR0]

; Set interrupts and timer
        ldr     r0, [irqh]        	;IRQ vector
        lsr     r0, 2
        orr     r0, 0xea000000
        str     r0, [r2, 0x18]
        ldr     r0, [stbas]
        ldr     r2, [r0, STCLO_]
        add     r2, 0x100
        str     r2, [r0, STC1]
        ldr     r0, [intbas]
        mov     r2, 0010b
        str     r2, [r0, INTENIRQ1]
        mov     r0, 0xd2       		;IRQ mode, FIQ&IRQ disable
        msr     cpsr_c, r0
        mov     sp, 0x4000
        mov     r0, 0x53       		;SVC mode, IRQ enable
    if qemu = 0
        msr     cpsr_c, r0
    end if
        mov     sp, 0x8000

; This is to create quick painting tables
        ldr     r6, [mem, opinrap]
        add     r6, 0x40000 + qemu * 0xc0000
        mov     r0, 255
gent1:  mov     r7, 255				; 256x256 table look up byte attribute + byte bitmap
gent2:  and     r3, r0, 7           ; r3 = ink color
        tst     r0, 01000000b       ; brightness activated?
        orrne   r3, 8               ; transfer brightness to r3
        movs    r2, r0, lsl 25      ; carry=flash
        mov     r2, r2, lsr 28      ; r2 = background color
        add     r4, r7, 0x00008000  ; r4 = byte bitmap with marker bit in bit 15
        eorcs   r4, 0xff            ; if there is flash I invert byte bitmap
    if qemu = 0
gent3:  tst     r4, 0x02            ; read bit 1 from the bitmap and set it to flag zero
        mov     r5, r5, lsl 4       ; nibble scroll
        addeq   r5, r2              ; write background color in nibble
        addne   r5, r3              ; write ink color in nibble
        tst     r4, 0x01            ; read bit 0 from the bitmap and set it to flag zero
        mov     r5, r5, lsl 4       ; nibble scroll
        addeq   r5, r2              ; write background color in nibble
        addne   r5, r3				; write ink color in nibble
        mov     r4, r4, lsr 2       ; shift the bitmap byte 2 bits to the right
        tst     r4, 0x0000ff00      ; repeat 4 times checking the marker bit
        bne     gent3
        str     r5, [r6, -4]!       ; write the 32 bits (8 pixels) calculated in table
    else
        add     r5, mem, opalette
        lsl     r2, 1
        ldrh    r2, [r5, r2]
        ldr     r3, [r5, r3, lsl 1]
        orr     r2, r3, lsl 16
gent3:  tst     r4, 0x01            ; read bit 0 from the bitmap and set it to flag zero
        moveq   r5, r2
        movne   r5, r2, lsr 16
        strh    r5, [r6, -2]!       ; write calculated pixel in table
        lsr     r4, 1               ; shift the bitmap byte 1 bit to the right
        tst     r4, 0x0000ff00      ; repeat 8 times checking the marker bit
        bne     gent3
    end if
        subs    r7, 1               ; close the loop 256x256 times
        bpl     gent2
        subs    r0, 1
        bpl     gent1
        str     r6, [mem, opinrap]  ; save the table pointer (I've gone backwards) in opinrap

; This renders the image

  if debug = 1
        mov     r11, r6
        ldr     pcff, [r11, -32 - 2]; PC
        ldr     r2, [r11, -16]      ; IY
        ldrh    lr, [r11, -28 - 1]  ; I
        add     iyi, lr, r2, lsl 16
        ldr     spfa, [r11, -30 - 2]; SP
        ldr     bcfb, [r11, -36 - 2]; BC
        ldr     defr, [r11, -26 - 2]; DE
        ldr     r2, [r11, -34]      ; HL
        ldrh    lr, [r11, -10]      ; MP
        add     hlmp, lr, r2, lsl 16
        ldrb    r2, [r11, -37]      ; A
        mov     arvpref, r2, lsl 24
        ldrb    r2, [r11, -27]      ; R
        add     arvpref, r2, lsl 16
        and     r2, 0x80
        ldrh    lr, [r11, -12]      ; IM | IFF
        add     r2, lr, lsr 8
        tst     lr, 1
        orrne   r2, 100b
        add     arvpref, r2, lsl 8
        ldr     ix, [r11, -14 - 2] 	; IX
        ldrb    r2, [r11, -38]      ; F
        mvn     lr, r2
        and     lr, 0x00000040
        pkhtb   defr, defr, lr
        orr     r2, r2, r2, lsl 8
        pkhtb   pcff, pcff, r2
        and     lr, r2, 0x00000004
        eor     r2, lr, lsl 5
        and     r2, 0xffffff7f
        eor     r2, lr, lsl 5
        pkhtb   bcfb, bcfb, r2
        uxtb    r2, r2
        pkhtb   spfa, spfa, r2
        str     pcff, [mem, otmpr3]
        ldrb    r2, [r11, -18]      ; F'
        mvn     r3, r2
        and     r3, 0x00000040
        strh    r3, [mem, off_ + 2] ; fr'
        orr     r2, r2, r2, lsl 8
        strh    r2, [mem, off_]     ; ff'
        and     r3, r2, 0x00000004
        eor     r2, r3, lsl 5
        and     r2, 0xffffff7f
        eor     r2, r3, lsl 5
        strh    r2, [mem, ofa_ + 2] ; fb'
        uxtb    r2, r2
        strh    r2, [mem, ofa_]     ; fa'
        ldrb    r2, [r11, -17]      ; A'
        strb    r2, [mem, oa_]
        ldr     r2, [r11, -24]      ; BC' DE'
        str     r2, [mem, oc_]
        ldrh    r2, [r11, -20]      ; HL'
        strh    r2, [mem, oc_ + 6]
  end if

render: mov     r2, 0
drawr:  cmp     r2, 264
        bcs     alli
        tst     r2, 0x1f
        tsteq   r2, 0x100
        bne     noscan
        ldr     r11, [_table]
        ldr     r12, [gpbas]
        add     r10, r11, r2, lsr 5
        ldr     r3, [r12, GPLEV0]
        and     lr, r3, 0011100000000000000000000000b
        tst     r3, 100000000b
        orrne   lr, 0100000000000000000000000000b
        tst     r3, 010000000b
        orrne   lr, 1000000000000000000000000000b
        lsr     lr, 23
        strb    lr, [r10, 8]
        ldrb    r10, [r11, -1]     	; last row
gf1:    add     r12, 4
        subs    r10, 10
        bcs     gf1
        sub     r10, r10, lsl 2
        add     r10, 2
        mov     r3, 111b
        ldr     lr, [r12, -4]
        bic     lr, r3, ror r10
        str     lr, [r12, -4]
        ldrb    r10, [r11, r2, lsr 5]
        strb    r10, [r11, -1]     	; last row
        ldr     r12, [gpbas]
gf2:    add     r12, 4
        subs    r10, 10
        bcs     gf2
        sub     r10, r10, lsl 2
        add     r10, 2
        ldr     lr, [r12, -4]
        bic     lr, r3, ror r10
        mov     r3, 0x001
        orr     lr, r3, ror r10
        str     lr, [r12, -4]
noscan: mov     r3, 0
        ldr     r10, [mem, opoint]
        mov     r11, 176 + 528 * qemu
        smlabb  r10, r11, r2, r10
drawp:  sub     r11, r3, 6
        cmp     r11, 32
        bcs     aqui
        sub     r12, r2, 36
        cmp     r12, 192
        bcs     aqui
        and     lr, r12, 11111000b
        orr     lr, r11, lr, lsl 2
        add     lr, 0x5800
        ldrb    lr, [mem, lr]
        add     r11, r12, lsl 5
        eor     r11, r12, lsl 2
        bic     r11, 0000011100000b
        eor     r11, r12, lsl 2
        eor     r11, r12, lsl 8
        bic     r11, 0011100000000b
        eor     r11, r12, lsl 8
        add     r11, 0x4000
        ldrb    r11, [mem, r11]
        tst     lr, 0x80
        tstne   iyi, 0x80
        eorne   lr, 0x80
        add     r11, r11, lr, lsl 8
        ldr     r12, [mem, opinrap]
    if qemu = 0
        ldr     r11, [r12, r11, lsl 2]
aqui:   ldrcs   r11, [border]
    else
        add     r12, r11, lsl 4
        ldr     r11, [r12], 4
        str     r11, [r10], 4
        ldr     r11, [r12], 4
        str     r11, [r10], 4
        ldr     r11, [r12], 4
        str     r11, [r10], 4
        ldr     r11, [r12], 4
        b       faqui
aqui:   ldr     r11, [border]
        str     r11, [r10], 4
        str     r11, [r10], 4
        str     r11, [r10], 4
    end if
faqui:  str     r11, [r10], 4
        add     r3, 1
        cmp     r3, 44
        bne     drawp
alli:   add     lr, mem, otmpr2
        swp     r2, r2, [lr]
        add     lr, 4
        swp     r3, r3, [lr]
;        bl      regs
        bl      execute
        add     stlo, 224
again:  ldr     lr, [flag]
        subs    lr, 2
    if qemu = 0
        bne     again
    end if
        str     lr, [flag]
        add     lr, mem, otmpr2
        swp     r2, r2, [lr]
        add     lr, 4
        swp     r3, r3, [lr]
        add     r2, 1

        cmp     r2, 312
        bne     drawr

        mov     r11, 4
        uadd8   iyi, iyi, r11
        add     lr, mem, otmpr2
        swp     r2, r2, [lr]
        add     lr, 4
        swp     r3, r3, [lr]
        tst     arvpref, 0x00000400
        beq     exec5
        bic     arvpref, 0x00000400
        tst     arvpref, 0x00000800
        bicne   arvpref, 0x00000800
        addne   pcff, 0x00010000
        mov     r11, pcff, lsr 16
        sub     spfa, 0x00020000
        mov     r10, spfa, lsr 16
        strh    r11, [mem, r10]
        mov     r11, 0x00010000
        uadd8   arvpref, arvpref, r11
        movs    r11, arvpref, lsl 22
        beq     exec3
        bmi     exec4
        sub     stlo, 1
exec3:  mov     r11, 0x00380000
        pkhbt   pcff, pcff, r11
        sub     stlo, 12
        b       exec5
exec4:  and     r11, iyi, 0x0000ff00
        orr     r11, 0x000000ff
        ldrh    r10, [mem, r11]
        pkhbt   pcff, pcff, r10, lsl 16
        sub     stlo, 19
exec5:  add     lr, mem, otmpr2
        swp     r2, r2, [lr]
        add     lr, 4
        swp     r3, r3, [lr]
        b       render

irqhnd: push    {r0, r1}
        ldr     r0, [stbas]
        mov     r1, 0010b
        str     r1, [flag]
        str     r1, [r0, STCS]
        ldr     r1, [r0, STCLO_]
        add     r1, 64
        str     r1, [r0, STC1]
        pop     {r0, r1}
        subs    pc, lr, 4

  if debug = 1
regs:   push    {r0, r12, lr}
        mov     r0, 'P'
        bl      send
        mov     r0, 'C'
        bl      send
        mov     r0, '='
        bl      send
        mov     r0, pcff, lsr 16
        bl      hexh
        mov     r0, 'B'
        bl      send
        mov     r0, 'C'
        bl      send
        mov     r0, '='
        bl      send
        mov     r0, bcfb, lsr 16
        bl      hexh
        mov     r0, 'D'
        bl      send
        mov     r0, 'E'
        bl      send
        mov     r0, '='
        bl      send
        mov     r0, defr
        bl      hexs
        mov     r0, 'H'
        bl      send
        mov     r0, 'L'
        bl      send
        mov     r0, '='
        bl      send
        mov     r0, hlmp, lsr 16
        bl      hexh
        mov     r0, 'A'
        bl      send
        mov     r0, '='
        bl      send
        mov     r0, arvpref, lsr 16
        bl      hexh
        mov     r0, 13
        bl      send
        pop     {r0, r12, pc}

hexs:   push    {r11, r12, lr}
        mov     r11, r0
        mov     r12, 8
hexs1:  mov     r11, r11, ror 28
        and     r0, r11, 0x0f
        cmp     r0, 10
        addcs   r0, 7
        add     r0, 0x30
        bl      send
        subs    r12, 1
        bne     hexs1
        mov     r0, 0x20
        bl      send
        pop     {r11, r12, pc}

hexh:   push    {r11, r12, lr}
        mov     r11, r0, ror 16
        mov     r12, 4
hexh1:  mov     r11, r11, ror 28
        and     r0, r11, 0x0f
        cmp     r0, 10
        addcs   r0, 7
        add     r0, 0x30
        bl      send
        subs    r12, 1
        bne     hexh1
        mov     r0, 0x20
        bl      send
        pop     {r11, r12, pc}
    if qemu = 0
send:   push    {r12, lr}
        ldr     lr, auxb
send1:  ldr     r12, [lr, AMLSRREG]
        tst     r12, 0x20
        beq     send1
        str     r0, [lr, AMIOREG]
        pop     {r12, pc}
    else
send:   push    {lr}
        ldr     lr, [uart]
        str     r0, [lr]
        pop     {pc}
    end if
  end if

; pool of constants

  if debug = 1
const:  dw      0x1234a6d8
  end if

flag:   dw      0
auxb:   dw      AUXBASE
gpbas:  dw      GPBASE
stbas:  dw      STBASE
intbas: dw      INTBASE
uart:   dw      UART0_DR
irqh:   dw      irqhnd - 0x20
memo:   dw      MEMORY
_table: dw      table
_keys:  dw      keys
                ; 7654321098765432109876543210
rows:   dw      001000011001100000111000010101b
lastrw: db      17
table:  db      10, 9, 11, 22, 27, 4, 15, 17		;15->18
keys:   db      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
filt:   dw      001011111001100000111110011101b

in_:    tst     r0, 1
        movne   r0, 0xff
        bxne    lr
        lsr     r3, r0, 8
        mov     r0, 0x1f
    if qemu = 0
        ldr     r11, [_keys]
        orr     r3, 0x100
in1:    ldrb    r2, [r11], 1
        lsrs    r3, 1
        andcc   r0, r2
        bne     in1
        ldr     r2, [gpbas]
        ldr     r3, [r2, GPLEV0]
        orr     r3, 10100b
    end if
        and     r3, 11100b
        orr     r0, r3, lsl 3
        bx      lr

out:    tst     r0, 1
        bxne    lr
        and     r3, r1, 0x7
    if qemu = 0
        ldr     r2, [c1111]
        mul     r3, r2, r3
    else
        ldr     r2, [memo]
        add     r2, r3, lsl 1
        ldrh    r3, [r2, opalette]
        orr     r3, r3, lsl 16
    end if
        str     r3, [border]
        ldr     r2, [gpbas]
        mov     r3, 0101b
        tst     r1, 0x10
        strne   r3, [r2, GPSET0]
        streq   r3, [r2, GPCLR0]
        bx      lr
    if qemu = 0
c1111:  dw      0x11111111
border: dw      0x77777777
    else
border: dw      10111101111101111011110111110111b
    end if

wait:   mov     r2, 100
waita:  subs    r2, 1
        bne     waita
        bx      lr

mbox:   ldr     r3, [r2, MBOXSTATUS]
        tst     r3, 0x80000000
        bne     mbox
        str     r0, [r2, MBOXWRITE]
mbox1:  ldr     r3, [r2, MBOXSTATUS]
        tst     r3, 0x40000000
        bne     mbox1
        ldr     r3, [r2, MBOXREAD]
        and     r3, 0x0000000f
        cmp     r3, r4
        bne     mbox1
        bx      lr

        include  "z80.s"

		; db 0x00, 0xf0, 0x20, 0xe3	; for compare with an original GNU C build

        align 	16

getrev: dw      7 * 4
        dw      0
        dw      0x00010002
        dw      4
        dw      0
        dw      0
        dw      0
        dw      0

fbinfo: dw      1024 - 672 * qemu 	; 0 Width
        dw      768 - 504 * qemu  	; 4 Height
        dw      352           		; 8 vWidth
        dw      264           		; 12 vHeight
        dw      0             		; 16 GPU - Pitch
        dw      4 + 12 * qemu     	; 20 Bit Depth
        dw      0             		; 24 X
        dw      0             		; 28 Y
point:  dw      0             		; 32 GPU - Pointer
        dw      0             		; 36 GPU - Size

              ; rrrrrggggggbbbbb
palette:dh     	0000000000000000b
        dh     	0000000000010111b
        dh     	1011100000000000b
        dh     	1011100000010111b
        dh     	0000010111100000b
        dh     	0000010111110111b
        dh     	1011110111100000b
        dh     	1011110111110111b
        dh     	0000000000000000b
        dh     	0000000000011111b
        dh     	1111100000000000b
        dh     	1111100000011111b
        dh     	0000011111100000b
        dh     	0000011111111111b
        dh     	1111111111100000b
        dh		1111111111111111b

pinrap: dw      LTABLE
tmpr2:  dw      224
tmpr3:  dw      0
        db      0, 0, 0
a_:     db      0
fa_:    dh      0
fb_:    dh      0
ff_:    dh      0
fr_:    dh      0
c_:     db      0
b_:     db      0
e_:     db      0
d_:     db      0
dummy1: dh      0
l_:     db      0
h_:     db      0

oc_ 			= -8
off_ 			= oc_ - 4
ofa_ 			= off_ - 4
oa_ 			= ofa_ - 1
otmpr3 			= oa_ - 7
otmpr2 			= otmpr3 - 4
opinrap 		= otmpr2 - 4
opalette 		= opinrap - 32
opoint 			= opalette - 8
ofbinfo 		= opoint - 32
ogetrev 		= ofbinfo - 32

endf:
		file	"48.rom"

		; GPIO23  D0
		; GPIO24  D1
		; GPIO25  D2
		; GPIO8   D3
		; GPIO7   D4

		; GPIO18  A15
		; GPIO4   A14
		; GPIO17  A8
		; GPIO27  A13
		; GPIO22  A12
		; GPIO10  A9
		; GPIO9   A10
		; GPIO11  A11

		; GPIO3   EAR
		; GPIO2   SPEAKER
