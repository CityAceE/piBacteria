		fast	= 1

macro	TIME	cycles {
	sub	stlo, cycles
}

macro	PREFIX0 {
      if fast = 0
	bic	arvpref, 0xff
      end if
	b	exit
}

macro	PREFIX1 {
      if fast = 0
	bic	arvpref, 0xff
	add	arvpref, arvpref, 1
      end if
	b	exit
}

macro	PREFIX2 {
      if fast = 0
	orr	arvpref, 0xff
      end if
	b	exit
}

macro	LDRRIM	regis {
	TIME	10
	ldr	lr, [mem, pcff, lsr 16]
	add	pcff, 0x00020000
	pkhbt	regis, regis, lr, lsl 16
	PREFIX0
}

macro	LDRIM	regis, ofs {
	TIME	7
	bic	regis, 0x00ff0000 shl ofs
	ldrb	lr, [mem, pcff, lsr 16]
	add	pcff, 0x00010000
	orr	regis, lr, lsl 16 + ofs
	PREFIX0
}

macro	LDRRPNN regis, cycl {
	TIME	cycl
	ldr	lr, [mem, pcff, lsr 16]
	mov	lr, lr, lsl 16
	ldr	r11, [mem, lr, lsr 16]
	pkhbt	regis, regis, r11, lsl 16
	add	pcff, 0x00020000
	add	lr, 0x00010000
	pkhtb	hlmp, hlmp, lr, asr 16
	PREFIX0
}

macro	LDPNNRR regis, cycl {
	TIME	cycl
	ldr	lr, [mem, pcff, lsr 16]
	uxtah	r11, mem, lr
	mov	r10, regis, lsr 16
	strh	r10, [r11]
	add	pcff, 0x00020000
	add	lr, 0x00000001
	pkhtb	hlmp, hlmp, lr
}

macro	LDXX	dst, ofd, src, ofs {
	TIME	4
	bic	dst, 0x00ff0000 shl ofd
	and	lr, src, 0x00ff0000 shl ofs
      if ofs - ofd = -8
	orr	dst, lr, ror 24
      else
	orr	dst, lr, ror ofs - ofd
      end if
	PREFIX0
}

macro	INC	regis, ofs {
	TIME	4
      if ofs = 0
	and	lr, regis, 0x00ff0000
	pkhtb	spfa, spfa, lr, asr 16
      else
	mov	lr, regis, lsr 24
	pkhtb	spfa, spfa, lr
      end if
	mov	lr, 0x00000001
	pkhtb	bcfb, bcfb, lr
	uadd8	lr, lr, spfa
	bic	regis, 0x00ff0000 shl ofs
	orr	regis, regis, lr, lsl 16 + ofs
	pkhtb	defr, defr, lr
	and	r11, pcff, 0x00000100
	orr	lr, r11
	pkhtb	pcff, pcff, lr
	PREFIX0
}

macro	DEC	regis, ofs {
	TIME	4
      if ofs = 0
	and	lr, regis, 0x00ff0000
	pkhtb	spfa, spfa, lr, asr 16
      else
	mov	lr, regis, lsr 24
	pkhtb	spfa, spfa, lr
      end if
	mov	lr, 0xffff00ff
	pkhtb	bcfb, bcfb, lr, asr 16
	uadd8	lr, lr, spfa
	bic	regis, 0x00ff0000 shl ofs
	orr	regis, regis, lr, lsl 16 + ofs
	pkhtb	defr, defr, lr
	and	r11, pcff, 0x00000100
	orr	lr, r11
	pkhtb	pcff, pcff, lr
	PREFIX0
}

macro	INCPI	regis {
	TIME	19
	add	r11, lr, regis, lsr 16
	ldrb	lr, [mem, r11]
	pkhtb	spfa, spfa, lr
	mov	lr, 0x00000001
	pkhtb	bcfb, bcfb, lr
	add	lr, spfa
	strb	lr, [mem, r11]
	uxtb	lr, lr
	pkhtb	defr, defr, lr
	and	r11, pcff, 0x00000100
	orr	lr, r11
	pkhtb	pcff, pcff, lr
	PREFIX0
}

macro	DECPI	regis {
	TIME	19
	add	r11, lr, regis, lsr 16
	ldrb	lr, [mem, r11]
	pkhtb	spfa, spfa, lr
	mov	lr, 0xffffffff
	pkhtb	bcfb, bcfb, lr
	add	lr, spfa
	strb	lr, [mem, r11]
	uxtb	lr, lr
	pkhtb	defr, defr, lr
	and	r11, pcff, 0x00000100
	orr	lr, r11
	pkhtb	pcff, pcff, lr
	PREFIX0
}

macro	XADD	regis, ofs, cycl {
	TIME	cycl
	mov	r11, arvpref, lsr 24
	pkhtb	spfa, spfa, r11
    if ofs = 0
	and	lr, regis, 0x00ff0000
	pkhtb	bcfb, bcfb, lr, asr 16
    else
      if ofs < 24
	mov	lr, regis, lsr 24
      end if
	pkhtb	bcfb, bcfb, lr
    end if
	add	lr, spfa, bcfb
	pkhtb	pcff, pcff, lr
	uxtb	lr, lr
	bic	arvpref, 0xff000000
	orr	arvpref, lr, lsl 24
	pkhtb	defr, defr, lr
	PREFIX0
}

macro	XADC	regis, ofs, cycl {
	TIME	cycl
	mov	r11, arvpref, lsr 24
	pkhtb	spfa, spfa, r11
    if ofs = 0
	and	lr, regis, 0x00ff0000
	pkhtb	bcfb, bcfb, lr, asr 16
    else
      if ofs < 24
	mov	lr, regis, lsr 24
      end if
	pkhtb	bcfb, bcfb, lr
    end if
	movs	lr, pcff, lsl 24
	adc	lr, spfa, bcfb
	pkhtb	pcff, pcff, lr
	uxtb	lr, lr
	bic	arvpref, 0xff000000
	orr	arvpref, lr, lsl 24
	pkhtb	defr, defr, lr
	PREFIX0
}

macro	XSUB	regis, ofs, cycl {
	TIME	cycl
	mov	r11, arvpref, lsr 24
	pkhtb	spfa, spfa, r11
      if ofs < 24
	uxtb	lr, regis, ror 16 + ofs
      end if
	mvn	lr, lr
	pkhtb	bcfb, bcfb, lr
	add	lr, r11
	add	lr, 0x00000001
	pkhtb	pcff, pcff, lr
	uxtb	lr, lr
	bic	arvpref, 0xff000000
	orr	arvpref, lr, lsl 24
	pkhtb	defr, defr, lr
	PREFIX0
}

macro	XSBC	regis, ofs, cycl {
	TIME	cycl
	mov	r11, arvpref, lsr 24
	pkhtb	spfa, spfa, r11
      if ofs < 24
	uxtb	lr, regis, ror 16 + ofs
      end if
	mvn	lr, lr
	pkhtb	bcfb, bcfb, lr
	eor	lr, pcff, 0x00000100
	movs	lr, lr, lsl 24
	adc	lr, spfa, bcfb
	pkhtb	pcff, pcff, lr
	uxtb	lr, lr
	bic	arvpref, 0xff000000
	orr	arvpref, lr, lsl 24
	pkhtb	defr, defr, lr
	PREFIX0
}

macro	XAND	regis, ofs, cycl {
	TIME	cycl
    if ofs = 24
	mov	r10, 0xffffff00
	orr	lr, r10
	and	arvpref, lr, ror 8
    else
      if ofs = 0
	mov	lr, 0xff00ffff
	orr	lr, regis
	and	arvpref, lr, ror 24
      else
	mov	lr, 0x00ffffff
	orr	lr, regis
	and	arvpref, lr
      end if
    end if
	mov	lr, arvpref, lsr 24
	pkhtb	bcfb, bcfb, lr, asr 16
	pkhtb	defr, defr, lr
	pkhtb	pcff, pcff, lr
	mvn	lr, lr
	pkhtb	spfa, spfa, lr
	PREFIX0
}

macro	XOR	regis, ofs, cycl {
	TIME	cycl
      if ofs = 24
	eor	arvpref, lr, lsl 24
      else
	and	lr, regis, 0x00ff0000 shl ofs
	eor	arvpref, lr, lsl 8 - ofs
      end if
	mov	lr, arvpref, lsr 24
	pkhtb	defr, defr, lr
	pkhtb	pcff, pcff, lr
	add	lr, 0x00000100
	pkhtb	spfa, spfa, lr
	pkhtb	bcfb, bcfb, lr, asr 16
	PREFIX0
}

macro	OR	regis, ofs, cycl {
	TIME	cycl
      if ofs = 24
	orr	arvpref, lr, lsl 24
      else
	and	lr, regis, 0x00ff0000 shl ofs
	orr	arvpref, lr, lsl 8 - ofs
      end if
	mov	lr, arvpref, lsr 24
	pkhtb	defr, defr, lr
	pkhtb	pcff, pcff, lr
	add	lr, 0x00000100
	pkhtb	spfa, spfa, lr
	pkhtb	bcfb, bcfb, lr, asr 16
	PREFIX0
}

macro	CP	regis, ofs, cycl {
	TIME	cycl
	mov	r11, arvpref, lsr 24
	pkhtb	spfa, spfa, r11
    if ofs = 24
	mvn	r11, lr
	pkhtb	bcfb, bcfb, r11
	sub	r10, spfa, lr
	and	r11, r10, 0x000000ff
	pkhtb	defr, defr, r11
	eor	r10, lr
	and	r10, 0xffffffd7
	eor	r10, lr
    else
      if ofs = 0
	and	lr, regis, 0x00ff0000
	mvn	r11, lr, asr 16
	pkhtb	bcfb, bcfb, r11
	sub	r10, spfa, lr, asr 16
	and	r11, r10, 0x000000ff
	pkhtb	defr, defr, r11
	eor	r10, lr, lsr 16
	and	r10, 0xffffffd7
	eor	r10, lr, lsr 16
      else
	mov	lr, regis, lsr 24
	mvn	r11, lr
	pkhtb	bcfb, bcfb, r11
	sub	r10, spfa, lr
	and	r11, r10, 0x000000ff
	pkhtb	defr, defr, r11
	eor	r10, lr
	and	r10, 0xffffffd7
	eor	r10, lr
      end if
    end if
	pkhtb	pcff, pcff, r10
	PREFIX0
}

macro	INCW	regis {
	TIME	6
	add	regis, 0x00010000
	PREFIX0
}

macro	DECW	regis {
	TIME	6
	sub	regis, 0x00010000
	PREFIX0
}

macro	CALLC	{
	beq	callnn
	TIME	10
	add	pcff, 0x00020000
	PREFIX0
}

macro	CALLCI	{
	bne	callnn
	TIME	10
	add	pcff, 0x00020000
	PREFIX0
}

macro	JPC	{
	beq	jpcc
	TIME	10
	add	pcff, 0x00020000
	PREFIX0
}

macro	JPCI	{
	bne	jpcc
	TIME	10
	add	pcff, 0x00020000
	PREFIX0
}

macro	RETC	{
	beq	ret11
	TIME	5
	PREFIX0
}

macro	RETCI	{
	bne	ret11
	TIME	5
	PREFIX0
}

macro	LDRP	src, dst, ofs {
	TIME	7
	mov	r11, src, lsr 16
	ldrb	lr, [mem, r11]
	bic	dst, 0x00ff0000 shl ofs
	orr	dst, dst, lr, lsl 16 + ofs
	add	r11, 1
	pkhtb	hlmp, hlmp, r11
	PREFIX0
}

macro	LDRPI	src, dst, ofs {
	TIME	15
	ldr	lr, [mem, pcff, lsr 16]
	add	pcff, 0x00010000
	sxtb	lr, lr
	add	lr, src, lr, lsl 16
	ldrb	lr, [mem, lr, lsr 16]
	bic	dst, 0x00ff0000 shl ofs
	orr	dst, lr, lsl 16 + ofs
	PREFIX0
}

macro	LDPR	src, dst, ofs {
	TIME	7
	mov	lr, dst, lsr 16 + ofs
	strb	lr, [mem, src, lsr 16]
	mov	lr, 0x00010000
	uadd8	lr, lr, src
	pkhtb	hlmp, hlmp, lr, asr 16
	PREFIX0
}

macro	LDPRI	src, dst, ofs {
	TIME	15
	ldr	lr, [mem, pcff, lsr 16]
	add	pcff, 0x00010000
	sxtb	lr, lr
	add	lr, src, lr, lsl 16
	mov	r11, dst, lsr 16 + ofs
	strb	r11, [mem, lr, lsr 16]
	PREFIX0
}

macro	LDPIM	src {
	TIME	15
	ldr	lr, [mem, pcff, lsr 16]
	add	pcff, 0x00020000
	mov	r11, lr, lsr 8
	sxtb	lr, lr
	add	lr, src, lr, lsl 16
	strb	r11, [mem, lr, lsr 16]
	PREFIX0
}

macro	RET	cycl {
	TIME	cycl
	ldr	lr, [mem, spfa, lsr 16]
	add	spfa, 0x00020000
	pkhtb	hlmp, hlmp, lr
	pkhbt	pcff, pcff, lr, lsl 16
}

macro	JRC	{
	beq	jrnn
	TIME	7
	add	pcff, 0x00010000
	PREFIX0
}

macro	JRCI	{
	bne	jrnn
	TIME	7
	add	pcff, 0x00010000
	PREFIX0
}

macro	PUS	regis {
	TIME	11
	sub	spfa, 0x00020000
	mov	lr, spfa, lsr 16
	mov	r11, regis, lsr 16
	strh	r11, [mem, lr]
	PREFIX0
}

macro	POPP	regis {
	TIME	10
	ldr	lr, [mem, spfa, lsr 16]
	pkhbt	regis, regis, lr, lsl 16
	add	spfa, 0x00020000
}

macro	RLC	regis, ofs {
	TIME	8
	uxtb	lr, regis, ror 16 + ofs
	add	lr, lr, lr, lsl 8
	pkhtb	pcff, pcff, lr, asr 7
	uxtb	lr, pcff
	bic	regis, 0x00ff0000 shl ofs
	orr	regis, lr, lsl 16 + ofs
	pkhtb	defr, defr, lr
	orr	lr, 0x00000100
	pkhtb	spfa, spfa, lr
	pkhtb	bcfb, bcfb, lr, asr 16
	b	exit
}

macro	RLCX	regis, ofs {
	add	lr, r10, r10, lsl 8
	pkhtb	pcff, pcff, lr, asr 7
	uxtb	lr, pcff
	pkhtb	defr, defr, lr
      if ~(regis eq arvpref) | ofs  <> 0
	bic	regis, 0x00ff0000 shl ofs
	orr	regis, lr, lsl 16 + ofs
      end if
	orr	lr, 0x00000100
	pkhtb	spfa, spfa, lr
	pkhtb	bcfb, bcfb, lr, asr 16
	strb	lr, [mem, r11]
	TIME	8
	b	exit
}

macro	RRC	regis, ofs {
	TIME	8
      if ofs = 0
	uxtb	lr, regis, ror 16
	movs	lr, lr, lsr 1
      else
	movs	lr, regis, lsr 25
      end if
	orrcs	lr, 0x00000180
	pkhtb	pcff, pcff, lr
	uxtb	lr, lr
	bic	regis, 0x00ff0000 shl ofs
	orr	regis, lr, lsl 16 + ofs
	pkhtb	defr, defr, lr
	orr	lr, 0x00000100
	pkhtb	spfa, spfa, lr
	pkhtb	bcfb, bcfb, lr, asr 16
	b	exit
}

macro	RRCX	regis, ofs {
	movs	lr, r10, lsr 1
	orrcs	lr, 0x00000180
	pkhtb	pcff, pcff, lr
	uxtb	lr, lr
      if ~(regis eq arvpref) | ofs  <> 0
	bic	regis, 0x00ff0000 shl ofs
	orr	regis, lr, lsl 16 + ofs
      end if
	pkhtb	defr, defr, lr
	orr	lr, 0x00000100
	pkhtb	spfa, spfa, lr
	pkhtb	bcfb, bcfb, lr, asr 16
	strb	lr, [mem, r11]
	TIME	8
	b	exit
}

macro	RL	regis, ofs {
	TIME	8
	movs	lr, pcff, lsl 24
	uxtb	lr, regis, ror 16 + ofs
	adc	lr, lr
	pkhtb	pcff, pcff, lr
	uxtb	lr, lr
	bic	regis, 0x00ff0000 shl ofs
	orr	regis, lr, lsl 16 + ofs
	pkhtb	defr, defr, lr
	add	lr, 0x00000100
	pkhtb	spfa, spfa, lr
	pkhtb	bcfb, bcfb, lr, asr 16
	b	exit
}

macro	RLX    regis, ofs {
	movs	lr, pcff, lsl 24
	adc	lr, r10, r10
	pkhtb	pcff, pcff, lr
	uxtb	lr, lr
	pkhtb	defr, defr, lr
      if ~(regis eq arvpref) | ofs  <> 0
	bic	regis, 0x00ff0000 shl ofs
	orr	regis, lr, lsl 16 + ofs
      end if
	orr	lr, 0x00000100
	pkhtb	spfa, spfa, lr
	pkhtb	bcfb, bcfb, lr, asr 16
	strb	lr, [mem, r11]
	TIME	8
	b	exit
}

macro	RR	regis, ofs {
	TIME	8
	uxtb	lr, regis, ror 16 + ofs
	add	lr, lr, lr, lsl 9
	and	r10, pcff, 0x00000100
	orr	lr, r10
	pkhtb	pcff, pcff, lr, asr 1
	uxtb	lr, pcff
	bic	regis, 0x00ff0000 shl ofs
	orr	regis, lr, lsl 16 + ofs
	pkhtb	defr, defr, lr
	add	lr, 0x00000100
	pkhtb	spfa, spfa, lr
	pkhtb	bcfb, bcfb, lr, asr 16
	b	exit
}

macro	RRX	regis, ofs {
	add	lr, r10, r10, lsl 9
	tst	pcff, 0x00000100
	orrne	lr, 0x00000100
	pkhtb	pcff, pcff, lr, asr 1
	uxtb	lr, pcff
	pkhtb	defr, defr, lr
      if ~(regis eq arvpref) | ofs  <> 0
	bic	regis, 0x00ff0000 shl ofs
	orr	regis, lr, lsl 16 + ofs
      end if
	orr	lr, 0x00000100
	pkhtb	spfa, spfa, lr
	pkhtb	bcfb, bcfb, lr, asr 16
	strb	lr, [mem, r11]
	TIME	8
	b	exit
}

macro	SLA	regis, ofs {
	TIME	8
	uxtb	lr, regis, ror 16 + ofs
	mov	lr, lr, lsl 1
	pkhtb	pcff, pcff, lr
	uxtb	lr, lr
	bic	regis, 0x00ff0000 shl ofs
	orr	regis, lr, lsl 16 + ofs
	pkhtb	defr, defr, lr
	add	lr, 0x00000100
	pkhtb	spfa, spfa, lr
	pkhtb	bcfb, bcfb, lr, asr 16
	b	exit
}

macro	SLAX	regis, ofs {
	mov	lr, r10, lsl 1
	pkhtb	pcff, pcff, lr
	uxtb	lr, lr
	pkhtb	defr, defr, lr
      if ~(regis eq arvpref) | ofs  <> 0
	bic	regis, 0x00ff0000 shl ofs
	orr	regis, lr, lsl 16 + ofs
      end if
	orr	lr, 0x00000100
	pkhtb	spfa, spfa, lr
	pkhtb	bcfb, bcfb, lr, asr 16
	strb	lr, [mem, r11]
	TIME	8
	b	exit
}

macro	SRA	regis, ofs {
	TIME	8
	uxtb	lr, regis, ror 16 + ofs
	add	lr, lr, lr, lsl 9
	tst	lr, 0x00000080
	orrne	lr, 0x00000100
	pkhtb	pcff, pcff, lr, asr 1
	uxtb	lr, pcff
	bic	regis, 0x00ff0000 shl ofs
	orr	regis, lr, lsl 16 + ofs
	pkhtb	defr, defr, lr
	add	lr, 0x00000100
	pkhtb	spfa, spfa, lr
	pkhtb	bcfb, bcfb, lr, asr 16
	b	exit
}

macro	SRAX	regis, ofs {
	add	lr, r10, r10, lsl 9
	tst	lr, 0x00000080
	orrne	lr, 0x00000100
	pkhtb	pcff, pcff, lr, asr 1
	uxtb	lr, pcff
	pkhtb	defr, defr, lr
      if ~(regis eq arvpref) | ofs  <> 0
	bic	regis, 0x00ff0000 shl ofs
	orr	regis, lr, lsl 16 + ofs
      end if
	orr	lr, 0x00000100
	pkhtb	spfa, spfa, lr
	pkhtb	bcfb, bcfb, lr, asr 16
	strb	lr, [mem, r11]
	TIME	8
	b	exit
}

macro	SLL	regis, ofs {
	TIME	8
	uxtb	lr, regis, ror 16 + ofs
	mov	lr, lr, lsl 1
	orr	lr, 0x00000001
	pkhtb	pcff, pcff, lr
	uxtb	lr, lr
	bic	regis, 0x00ff0000 shl ofs
	orr	regis, lr, lsl 16 + ofs
	pkhtb	defr, defr, lr
	add	lr, 0x00000100
	pkhtb	spfa, spfa, lr
	pkhtb	bcfb, bcfb, lr, asr 16
	b	exit
}

macro	SLLX	regis, ofs {
	mov	lr, r10, lsl 1
	orr	lr, 0x00000001
	pkhtb	pcff, pcff, lr
	uxtb	lr, lr
	pkhtb	defr, defr, lr
      if ~(regis eq arvpref) | ofs  <> 0
	bic	regis, 0x00ff0000 shl ofs
	orr	regis, lr, lsl 16 + ofs
      end if
	orr	lr, 0x00000100
	pkhtb	spfa, spfa, lr
	pkhtb	bcfb, bcfb, lr, asr 16
	strb	lr, [mem, r11]
	TIME	8
	b	exit
}

macro	SRL	regis, ofs {
	TIME	8
	uxtb	lr, regis, ror 16 + ofs
	add	lr, lr, lr, lsl 9
	pkhtb	pcff, pcff, lr, asr 1
	uxtb	lr, pcff
	bic	regis, 0x00ff0000 shl ofs
	orr	regis, lr, lsl 16 + ofs
	pkhtb	defr, defr, lr
	add	lr, 0x00000100
	pkhtb	spfa, spfa, lr
	pkhtb	bcfb, bcfb, lr, asr 16
	b	exit
}

macro	SRLX	regis, ofs {
	add	lr, r10, r10, lsl 9
	orr	lr, 0x00000001
	pkhtb	pcff, pcff, lr, asr 1
	uxtb	lr, pcff
	pkhtb	defr, defr, lr
      if ~(regis eq arvpref) | ofs  <> 0
	bic	regis, 0x00ff0000 shl ofs
	orr	regis, lr, lsl 16 + ofs
      end if
	orr	lr, 0x00000100
	pkhtb	spfa, spfa, lr
	pkhtb	bcfb, bcfb, lr, asr 16
	strb	lr, [mem, r11]
	TIME	8
	b	exit
}

macro	BIT	const, regis, ofs {
	TIME	8
	mov	lr, regis, lsr 16 + ofs
	and	r11, lr, const
	pkhtb	defr, defr, r11
	and	lr, 0x00000028
	orr	lr, r11
	bic	pcff, 0x000000ff
	uxtab	pcff, pcff, lr
	mvn	r11, r11
	pkhtb	spfa, spfa, r11
	pkhtb	bcfb, bcfb, lr, asr 16
	b	exit
}

macro	BITHL	const {
	TIME	12
	ldrb	r10, [mem, hlmp, lsr 16]
	and	r10, const
	eor	lr, r10, hlmp, lsr 8
	and	lr, 0xffffffd7
	eor	lr, hlmp, lsr 8
	bic	pcff, 0x000000ff
	uxtab	pcff, pcff, lr
	pkhtb	defr, defr, r10
	mvn	lr, r10
	pkhtb	spfa, spfa, lr
	pkhtb	bcfb, bcfb, r10, asr 16
	b	exit
}

macro	RES	const, regis, ofs {
	TIME	8
      if ofs = 0
	and	regis, 0xff00ffff or const shl 16
      else
	and	regis, 0x00ffffff or const shl 24
      end if
	b	exit
}

macro	RESHL	const {
	TIME	15
	ldrb	lr, [mem, hlmp, lsr 16]
	and	lr, const
	strb	lr, [mem, hlmp, lsr 16]
	b	exit
}

macro	RESXD	const, regis, ofs {
	and	r10, const
	strb	r10, [mem, r11]
      if ~(regis eq arvpref) | ofs  <> 0
	bic	regis, 0x00ff0000 shl ofs
	orr	regis, r10, lsl 16 + ofs
      end if
	TIME	8
	b	exit
}

macro	SET	const, regis, ofs {
	TIME	8
	orr	regis, const shl (16 + ofs)
	b	exit
}

macro	SETHL	const {
	TIME	15
	ldrb	lr, [mem, hlmp, lsr 16]
	orr	lr, const
	strb	lr, [mem, hlmp, lsr 16]
	b	exit
}

macro	SETXD	const, regis, ofs {
	orr	r10, const
	strb	r10, [mem, r11]
      if ~(regis eq arvpref) | ofs  <> 0
	bic	regis, 0x00ff0000 shl ofs
	orr	regis, r10, lsl 16 + ofs
      end if
	TIME	8
	b	exit
}

macro	BITI	const {
	TIME	5
	and	r10, const
	eor	lr, r10, hlmp, lsr 8
	and	lr, 0xffffffd7
	eor	lr, hlmp, lsr 8
	bic	pcff, 0x000000ff
	uxtab	pcff, pcff, lr
	pkhtb	defr, defr, r10
	mvn	lr, r10
	pkhtb	spfa, spfa, lr
	pkhtb	bcfb, bcfb, r10, asr 16
	b	exit
}

macro	EXSPI	regis {
	TIME	19
	add	r10, mem, spfa, lsr 16
	mov	lr, regis, lsr 16
	swpb	r11, lr, [r10]
	mov	lr, regis, lsr 24
	add	r10, 1
	swpb	lr, lr, [r10]
	orr	lr, r11, lr, lsl 8
	pkhbt	regis, regis, lr, lsl 16
	pkhtb	hlmp, hlmp, lr
}

macro	ADDRRRR dst, src {
	TIME	11
	mov	lr, src, lsr 16
	add	lr, dst, lsr 16
	and	r11, lr, 0x00012800
	and	r10, pcff, 0x00000080
	orr	r10, r11, lsr 8
	pkhtb	pcff, pcff, r10
	eor	r11, defr, spfa
	eor	r10, dst, src
	eor	r10, lr, lsl 16
	eor	r11, r10, lsr 24
	and	r11, 0x00000010
	and	r10, bcfb, 0x00000080
	orr	r11, r10
	pkhtb	bcfb, bcfb, r11
	add	r11, dst, 0x00010000
	pkhtb	hlmp, hlmp, r11, asr 16
	pkhbt	dst, dst, lr, lsl 16
	PREFIX0
}

macro	ADCHLRR regis {
	TIME	15
	movs	lr, pcff, lsl 24
	mov	r11, hlmp, lsr 16
	mov	r10, regis, lsr 16
	adc	lr, r11, r10
	pkhtb	pcff, pcff, lr, asr 8
	pkhtb	spfa, spfa, r11, asr 8
	pkhtb	bcfb, bcfb, r10, asr 8
	add	r11, 1
	pkhbt	hlmp, r11, lr, lsl 16
	rev	lr, hlmp
	pkhtb	defr, defr, lr
	b	exit
}

macro	SBCHLRR regis {
	TIME	15
	eor	lr, pcff, 0x00000100
	movs	lr, lr, lsl 24
	mov	r11, hlmp, lsr 16
	sbc	lr, r11, regis, lsr 16
	pkhtb	pcff, pcff, lr, asr 8
	pkhtb	spfa, spfa, r11, asr 8
	mvn	r10, regis, lsr 24
	pkhtb	bcfb, bcfb, r10
	add	r11, 1
	pkhbt	hlmp, r11, lr, lsl 16
	rev	lr, hlmp
	pkhtb	defr, defr, lr
	b	exit
}

macro	RST	addr {
	TIME	11
	mov	lr, pcff, lsr 16
      if addr = 0
	uxth	pcff, pcff
      else
	mov	r11, addr
	pkhbt	pcff, pcff, r11, lsl 16
      end if
	pkhtb	hlmp, hlmp, pcff, asr 16
	sub	spfa, 0x00020000
	mov	r11, spfa, lsr 16
	strh	lr, [mem, r11]
	PREFIX0
}

macro	INR	regis, ofs {
	TIME	12
	push	{r0-r3\}
	mov	r0, bcfb, lsr 16
	add	r11, r0, 0x00000001
	pkhtb	hlmp, hlmp, r11
	bl	in_
      if ~(regis eq arvpref) | ofs  <> 0
	bic	regis, 0x00ff0000 shl ofs
	orr	regis, r0, lsl 16 + ofs
      end if
	pkhtb	defr, defr, r0
	bic	pcff, 0x000000ff
	orr	pcff, r0
	orr	r0, 0x00000100
	pkhtb	spfa, spfa, r0
	pkhtb	bcfb, bcfb, r0, asr 16
	pop	{r0-r3\}
	b	exit
}

macro	OUTR	regis, ofs {
	TIME	12
	push	{r0-r3\}
	mov	r0, bcfb, lsr 16
	add	r11, r0, 0x00000001
	pkhtb	hlmp, hlmp, r11
      if ~(regis eq arvpref) | ofs  <> 0
	uxtb	r1, regis, ror 16 + ofs
      else
	mov	r1, 0x00000000
      end if
	bl	out
	pop	{r0-r3\}
	b	exit
}

		; r0	  iy | i
	; r1	  mem
	; r2	  stlo
	; r3	  pc | ff
	; r4	  sp | fa
	; r5	  bc | fb
	; r6	  de | fr
	; r7	  hl | mp
	; r8	  ar | r7 halted_3 iff_2 im : prefix
	; r9	  ix

execute:push	{lr}
exec1:
  if debug = 1
		; push	  {r0}
		; mov	  r0, pcff, lsr 16
		; sub	  r0, 0x00d5
		; cmp	  r0, 0x0200
		; bne	  ca
		; bl	  regs
; ca:	pop	{r0}
  end if

	mov	lr, 0x00010000
	uadd8	arvpref, arvpref, lr
	ldrb	lr, [mem, pcff, lsr 16]
	add	pcff, 0x00010000
	ldr	pc, [pc, lr, lsl 2]
mboxb:	dw	MBOXBASE
      if fast = 0
	dw	nop_		    ; 00 NOP
	dw	ldbcnn		    ; 01 LD BC,nn
	dw	ldbca		    ; 02 LD (BC),A
	dw	incbc		    ; 03 INC BC
	dw	incb		    ; 04 INC B
	dw	decb		    ; 05 DEC B
	dw	ldbn		    ; 06 LD B,n
	dw	rlca		    ; 07 RLCA
	dw	exafaf		    ; 08 EX AF,AF
	dw	addxxbc		    ; 09 ADD HL,BC
	dw	ldabc		    ; 0a LD A,(BC)
	dw	decbc		    ; 0b DEC BC
	dw	incc		    ; 0c INC C
	dw	decc		    ; 0d DEC C
	dw	ldcn		    ; 0e LD C,n
	dw	rrca		    ; 0f RRCA
	dw	djnz		    ; 10 DJNZ
	dw	lddenn		    ; 11 LD DE,nn
	dw	lddea		    ; 12 LD (DE),A
	dw	incde		    ; 13 INC DE
	dw	incd		    ; 14 INC D
	dw	decd		    ; 15 DEC D
	dw	lddn		    ; 16 LD D,n
	dw	rla		    ; 17 RLA
	dw	jr		    ; 18 JR
	dw	addxxde		    ; 19 ADD HL,DE
	dw	ldade		    ; 1a LD A,(DE)
	dw		decde		    ; 1b DEC DE
	dw	ince		    ; 1c INC E
	dw	dece		    ; 1d DEC E
	dw	lden		    ; 1e LD E,n
	dw	rra		    ; 1f RRA
	dw	jrnz		    ; 20 JR NZ,s8
	dw	ldxxnn		    ; 21 LD HL,nn
	dw	ldpnnxx		    ; 22 LD (nn),HL
	dw	inchlx		    ; 23 INC HL
	dw	inchx		    ; 24 INC H
	dw	dechx		    ; 25 DEC H
	dw	lxhn		    ; 26 LD H,n
	dw	daa		    ; 27 DAA
	dw	jrz		    ; 28 JR Z,s8
	dw	addxxxx		    ; 29 ADD HL,HL
	dw	ldxxpnn		    ; 2a LD HL,(nn)
	dw	dechlx		    ; 2b DEC HL
	dw	inclx		    ; 2c INC L
	dw	declx		    ; 2d DEC L
	dw	lxln		    ; 2e LD L,n
	dw	cpl		    ; 2f CPL
	dw	jrnc		    ; 30 JR NC,s8
	dw	ldspnn		    ; 31 LD SP,nn
	dw	ldnna		    ; 32 LD (nn),A
	dw	incsp		    ; 33 INC SP
	dw	incpxx		    ; 34 INC (HL)
	dw	decpxx		    ; 35 DEC (HL)
	dw	ldxxn		    ; 36 LD (HL),n
	dw	scf		    ; 37 SCF
	dw	jrc		    ; 38 JR C,s8
	dw	addxxsp		    ; 39 ADD HL,SP
	dw	ldann		    ; 3a LD A,(nn)
	dw	decsp		    ; 3b DEC SP
	dw	inca		    ; 3c INC A
	dw	deca		    ; 3d DEC A
	dw	ldan		    ; 3e LD A,n
	dw	ccf		    ; 3f CCF
	dw	nop_		    ; 40 LD B,B
	dw	ldbc		    ; 41 LD B,C
	dw	ldbd		    ; 42 LD B,D
	dw	ldbe		    ; 43 LD B,E
	dw	lxbh		    ; 44 LD B,H
	dw	lxbl		    ; 45 LD B,L
	dw	lxbhl		    ; 46 LD B,(HL)
	dw	ldba		    ; 47 LD B,A
	dw	ldcb		    ; 48 LD C,B
	dw	nop_		    ; 49 LD C,C
	dw	ldcd		    ; 4a LD C,D
	dw	ldce		    ; 4b LD C,E
	dw	lxch		    ; 4c LD C,H
	dw	lxcl		    ; 4d LD C,L
	dw	lxchl		    ; 4e LD C,(HL)
	dw	ldca		    ; 4f LD C,A
	dw	lddb		    ; 50 LD D,B
	dw	lddc		    ; 51 LD D,C
	dw	nop_		    ; 52 LD D,D
	dw	ldde		    ; 53 LD D,E
	dw	lxdh		    ; 54 LD D,H
	dw	lxdl		    ; 55 LD D,L
	dw	lxdhl		    ; 56 LD D,(HL)
	dw	ldda		    ; 57 LD D,A
	dw	ldeb		    ; 58 LD E,B
	dw	ldec		    ; 59 LD E,C
	dw	lded		    ; 5a LD E,D
	dw	nop_		    ; 5b LD E,E
	dw	lxeh		    ; 5c LD E,H
	dw	lxel		    ; 5d LD E,L
	dw	lxehl		    ; 5e LD E,(HL)
	dw	ldea		    ; 5f LD E,A
	dw	lxhb		    ; 60 LD H,B
	dw	lxhc		    ; 61 LD H,C
	dw	lxhd		    ; 62 LD H,D
	dw	lxhe		    ; 63 LD H,E
	dw	nop_		    ; 64 LD H,H
	dw	lxhl		    ; 65 LD H,L
	dw	lxhhl		    ; 66 LD H,(HL)
	dw	lxha		    ; 67 LD H,A
	dw	lxlb		    ; 68 LD L,B
	dw	lxlc		    ; 69 LD L,C
	dw	lxld		    ; 6a LD L,D
	dw	lxle		    ; 6b LD L,E
	dw	lxlh		    ; 6c LD L,H
	dw	nop_		    ; 6d LD L,L
	dw	lxlhl		    ; 6e LD L,(HL)
	dw	lxla		    ; 6f LD L,A
	dw	ldxxb		    ; 70 LD (HL),B
	dw	ldxxc		    ; 71 LD (HL),C
	dw	ldxxd		    ; 72 LD (HL),D
	dw	ldxxe		    ; 73 LD (HL),E
	dw	ldxxh		    ; 74 LD (HL),H
	dw	ldxxl		    ; 75 LD (HL),L
	dw	halt		    ; 76 HALT
	dw	ldxxa		    ; 77 LD (HL),A
	dw	ldab_		    ; 78 LD A,B
	dw	ldac		    ; 79 LD A,C
	dw	ldad		    ; 7a LD A,D
	dw	ldae		    ; 7b LD A,E
	dw	lxah		    ; 7c LD A,H
	dw	lxal		    ; 7d LD A,L
	dw	lxahl		    ; 7e LD A,(HL)
	dw	nop_		    ; 7f LD A,A
	dw	addab		    ; 80 ADD A,B
	dw	addac		    ; 81 ADD A,C
	dw	addad		    ; 82 ADD A,D
	dw	addae		    ; 83 ADD A,E
	dw	addxh		    ; 84 ADD A,H
	dw	addxl		    ; 85 ADD A,L
	dw	addaxx		    ; 86 ADD A,(HL)
	dw	addaa		    ; 87 ADD A,A
	dw	adcab		    ; 88 ADC A,B
	dw	adcac		    ; 89 ADC A,C
	dw	adcad		    ; 8a ADC A,D
	dw	adcae		    ; 8b ADC A,E
	dw	adcahx		    ; 8c ADC A,H
	dw	adcalx		    ; 8d ADC A,L
	dw	adcaxx		    ; 8e ADC A,(HL)
	dw	adcaa		    ; 8f ADC A,A
	dw	subb		    ; 90 SUB B
	dw	subc		    ; 91 SUB C
	dw	subd		    ; 92 SUB D
	dw	sube		    ; 93 SUB E
	dw	subhx		    ; 94 SUB H
	dw	sublx		    ; 95 SUB L
	dw	subxx		    ; 96 SUB (HL)
	dw	suba		    ; 97 SUB A
	dw	sbcab		    ; 98 SBC A,B
	dw	sbcac		    ; 99 SBC A,C
	dw	sbcad		    ; 9a SBC A,D
	dw	sbcae		    ; 9b SBC A,E
	dw	sbcahx		    ; 9c SBC A,H
	dw	sbcalx		    ; 9d SBC A,L
	dw	sbcaxx		    ; 9e SBC A,(HL)
	dw	sbcaa		    ; 9f SBC A,A
	dw	andb		    ; a0 AND B
	dw	andc		    ; a1 AND C
	dw	andd		    ; a2 AND D
	dw	ande		    ; a3 AND E
	dw	andhx		    ; a4 AND H
	dw	andlx		    ; a5 AND L
	dw	andxx		    ; a6 AND (HL)
	dw	anda		    ; a7 AND A
	dw	xorb		    ; a8 XOR B
	dw	xorc		    ; a9 XOR C
	dw	xord		    ; aa XOR D
	dw	xore		    ; ab XOR E
	dw	xorhx		    ; ac XOR H
	dw	xorlx		    ; ad XOR L
	dw	xorxx		    ; ae XOR (HL)
	dw	xora		    ; af XOR A
	dw	orb		    ; b0 OR B
	dw	orc		    ; b1 OR C
	dw	ord		    ; b2 OR D
	dw	ore		    ; b3 OR E
	dw	orhx		    ; b4 OR H
	dw	orlx		    ; b5 OR L
	dw	orxx		    ; b6 OR (HL)
	dw	ora		    ; b7 OR A
	dw	cpb		    ; b8 CP B
	dw	cpc		    ; b9 CP C
	dw	cp_d		    ; ba CP D
	dw	cpe		    ; bb CP E
	dw	cphx		    ; bc CP H
	dw	cplx		    ; bd CP L
	dw	cpxx		    ; be CP (HL)
	dw	cpa		    ; bf CP A
	dw	retnz		    ; c0 RET NZ
	dw	popbc		    ; c1 POP BC
	dw	jpnz		    ; c2 JP NZ
	dw	jpnn		    ; c3 JP nn
	dw	callnz		    ; c4 CALL NZ
	dw	pushbc		    ; c5 PUSH BC
	dw	addan		    ; c6 ADD A,n
	dw	rst00		    ; c7 RST 0x00
	dw	retz		    ; c8 RET Z
	dw	ret10		    ; c9 RET
	dw	jpz		    ; ca JP Z
	dw	opcb		    ; cb op cb
	dw	callz		    ; cc CALL Z
	dw	callnn		    ; cd CALL NN
	dw	adcan		    ; ce ADC A,n
	dw	rst08		    ; cf RST 0x08
	dw	retnc		    ; d0 RET NC
	dw	popde		    ; d1 POP DE
	dw	jpnc		    ; d2 JP NC
	dw	outna		    ; d3 OUT (n),A
	dw	callnc		    ; d4 CALL NC
	dw	pushde		    ; d5 PUSH DE
	dw	subn		    ; d6 SUB n
	dw	rst10		    ; d7 RST 0x10
	dw	retc		    ; d8 RET C
	dw	exx		    ; d9 EXX
	dw	jpc		    ; da JP C
	dw	inan		    ; db IN A,(n)
	dw	callc		    ; dc CALL C
	dw	opdd		    ; dd OP dd
	dw	sbcan		    ; de SBC A,n
	dw	rst18		    ; df RST 0x18
	dw	retpo		    ; e0 RET PO
	dw	popxx		    ; e1 POP HL
	dw	jppo		    ; e2 JP PO
	dw	exspxx		    ; e3 EX (SP),HL
	dw	callpo		    ; e4 CALL PO
	dw	pushxx		    ; e5 PUSH HL
	dw	andan		    ; e6 AND A,n
	dw	rst20		    ; e7 RST 0x20
	dw	retpe		    ; e8 RET PE
	dw	jpxx		    ; e9 JP (HL)
	dw	jppe		    ; ea JP PE
	dw	exdehl		    ; eb EX DE,HL
	dw	callpe		    ; ec CALL PE
	dw	oped		    ; ed op ed
	dw	xoran		    ; ee XOR A,n
	dw	rst28		    ; ef RST 0x28
	dw	retp		    ; f0 RET P
	dw	popaf		    ; f1 POP AF
	dw	jpp		    ; f2 JP P
	dw	di		    ; f3 DI
	dw	callp		    ; f4 CALL P
	dw	pushaf		    ; f5 PUSH AF
	dw	oran		    ; f6 OR A,n
	dw	rst30		    ; f7 RST 0x30
	dw	retm		    ; f8 RET M
	dw	ldspxx		    ; f9 LD SP,HL
	dw	jpm		    ; fa JP M
	dw	ei		    ; fb EI
	dw	callm		    ; fc CALL M
	dw	opfd		    ; fd op fd
	dw	cpan		    ; fe CP A,n
	dw	rst38		    ; ff RST 0x38
      else
	dw	nop_		    ; 00 NOP
	dw	ldbcnn		    ; 01 LD BC,nn
	dw	ldbca		    ; 02 LD (BC),A
	dw	incbc		    ; 03 INC BC
	dw	incb		    ; 04 INC B
	dw	decb		    ; 05 DEC B
	dw	ldbn		    ; 06 LD B,n
	dw	rlca		    ; 07 RLCA
	dw	exafaf		    ; 08 EX AF,AF
	dw	addhlbc		    ; 09 ADD HL,BC
	dw	ldabc		    ; 0a LD A,(BC)
	dw	decbc		    ; 0b DEC BC
	dw	incc		    ; 0c INC C
	dw	decc		    ; 0d DEC C
	dw	ldcn		    ; 0e LD C,n
	dw	rrca		    ; 0f RRCA
	dw	djnz		    ; 10 DJNZ
	dw	lddenn		    ; 11 LD DE,nn
	dw	lddea		    ; 12 LD (DE),A
	dw	incde		    ; 13 INC DE
	dw	incd		    ; 14 INC D
	dw	decd		    ; 15 DEC D
	dw	lddn		    ; 16 LD D,n
	dw	rla		    ; 17 RLA
	dw	jr		    ; 18 JR
	dw	addhlde		    ; 19 ADD HL,DE
	dw	ldade		    ; 1a LD A,(DE)
	dw	decde		    ; 1b DEC DE
	dw	ince		    ; 1c INC E
	dw	dece		    ; 1d DEC E
	dw	lden		    ; 1e LD E,n
	dw	rra		    ; 1f RRA
	dw	jrnz		    ; 20 JR NZ,s8
	dw	ldhlnn		    ; 21 LD HL,nn
	dw	ldpnnhl		    ; 22 LD (nn),HL
	dw	inchl		    ; 23 INC HL
	dw	inch		    ; 24 INC H
	dw	dech		    ; 25 DEC H
	dw	ldhn		    ; 26 LD H,n
	dw	daa		    ; 27 DAA
	dw	jrz		    ; 28 JR Z,s8
	dw	addhlhl		    ; 29 ADD HL,HL
	dw	ldhlpnn		    ; 2a LD HL,(nn)
	dw	dechl		    ; 2b DEC HL
	dw	incl		    ; 2c INC L
	dw	decl		    ; 2d DEC L
	dw	ldln		    ; 2e LD L,n
	dw	cpl		    ; 2f CPL
	dw	jrnc		    ; 30 JR NC,s8
	dw	ldspnn		    ; 31 LD SP,nn
	dw	ldnna		    ; 32 LD (nn),A
	dw	incsp		    ; 33 INC SP
	dw	incphl		    ; 34 INC (HL)
	dw	decphl		    ; 35 DEC (HL)
	dw	ldhln		    ; 36 LD (HL),n
	dw	scf		    ; 37 SCF
	dw	jrc		    ; 38 JR C,s8
	dw	addhlsp		    ; 39 ADD HL,SP
	dw	ldann		    ; 3a LD A,(nn)
	dw	decsp		    ; 3b DEC SP
	dw	inca		    ; 3c INC A
	dw	deca		    ; 3d DEC A
	dw	ldan		    ; 3e LD A,n
	dw	ccf		    ; 3f CCF
	dw	nop_		    ; 40 LD B,B
	dw	ldbc		    ; 41 LD B,C
	dw	ldbd		    ; 42 LD B,D
	dw	ldbe		    ; 43 LD B,E
	dw	ldbh		    ; 44 LD B,H
	dw	ldbl		    ; 45 LD B,L
	dw	ldbhl		    ; 46 LD B,(HL)
	dw	ldba		    ; 47 LD B,A
	dw	ldcb		    ; 48 LD C,B
	dw	nop_		    ; 49 LD C,C
	dw	ldcd		    ; 4a LD C,D
	dw	ldce		    ; 4b LD C,E
	dw	ldch		    ; 4c LD C,H
	dw	ldcl_		    ; 4d LD C,L
	dw	ldchl		    ; 4e LD C,(HL)
	dw	ldca		    ; 4f LD C,A
	dw	lddb		    ; 50 LD D,B
	dw	lddc		    ; 51 LD D,C
	dw	nop_		    ; 52 LD D,D
	dw	ldde		    ; 53 LD D,E
	dw	lddh		    ; 54 LD D,H
	dw	lddl		    ; 55 LD D,L
	dw	lddhl		    ; 56 LD D,(HL)
	dw	ldda		    ; 57 LD D,A
	dw	ldeb		    ; 58 LD E,B
	dw	ldec		    ; 59 LD E,C
	dw	lded		    ; 5a LD E,D
	dw	nop_		    ; 5b LD E,E
	dw	ldeh		    ; 5c LD E,H
	dw	ldel		    ; 5d LD E,L
	dw	ldehl		    ; 5e LD E,(HL)
	dw	ldea		    ; 5f LD E,A
	dw	ldhb		    ; 60 LD H,B
	dw	ldhc		    ; 61 LD H,C
	dw	ldhd		    ; 62 LD H,D
	dw	ldhe		    ; 63 LD H,E
	dw	nop_		    ; 64 LD H,H
	dw	ldhl		    ; 65 LD H,L
	dw	ldhhl		    ; 66 LD H,(HL)
	dw	ldha		    ; 67 LD H,A
	dw	ldlb		    ; 68 LD L,B
	dw	ldlc		    ; 69 LD L,C
	dw	ldld		    ; 6a LD L,D
	dw	ldle		    ; 6b LD L,E
	dw	ldlh		    ; 6c LD L,H
	dw	nop_		    ; 6d LD L,L
	dw	ldlhl		    ; 6e LD L,(HL)
	dw	ldla		    ; 6f LD L,A
	dw	ldhlb		    ; 70 LD (HL),B
	dw	ldhlc		    ; 71 LD (HL),C
	dw	ldhld		    ; 72 LD (HL),D
	dw	ldhle		    ; 73 LD (HL),E
	dw	ldhlh		    ; 74 LD (HL),H
	dw	ldhll		    ; 75 LD (HL),L
	dw	halt		    ; 76 HALT
	dw	ldhla		    ; 77 LD (HL),A
	dw	ldab_		    ; 78 LD A,B
	dw	ldac		    ; 79 LD A,C
	dw	ldad		    ; 7a LD A,D
	dw	ldae		    ; 7b LD A,E
	dw	ldah_		    ; 7c LD A,H
	dw	ldal		    ; 7d LD A,L
	dw	ldahl		    ; 7e LD A,(HL)
	dw	nop_		    ; 7f LD A,A
	dw	addab		    ; 80 ADD A,B
	dw	addac		    ; 81 ADD A,C
	dw	addad		    ; 82 ADD A,D
	dw	addae		    ; 83 ADD A,E
	dw	addah		    ; 84 ADD A,H
	dw	addal_		    ; 85 ADD A,L
	dw	addahl		    ; 86 ADD A,(HL)
	dw	addaa		    ; 87 ADD A,A
	dw	adcab		    ; 88 ADC A,B
	dw	adcac		    ; 89 ADC A,C
	dw	adcad		    ; 8a ADC A,D
	dw	adcae		    ; 8b ADC A,E
	dw	adcah		    ; 8c ADC A,H
	dw	adcal_		    ; 8d ADC A,L
	dw	adcahl		    ; 8e ADC A,(HL)
	dw	adcaa		    ; 8f ADC A,A
	dw	subb		    ; 90 SUB B
	dw	subc		    ; 91 SUB C
	dw	subd		    ; 92 SUB D
	dw	sube		    ; 93 SUB E
	dw	subh		    ; 94 SUB H
	dw	subl		    ; 95 SUB L
	dw	subhl		    ; 96 SUB (HL)
	dw	suba		    ; 97 SUB A
	dw	sbcab		    ; 98 SBC A,B
	dw	sbcac		    ; 99 SBC A,C
	dw	sbcad		    ; 9a SBC A,D
	dw	sbcae		    ; 9b SBC A,E
	dw	sbcah		    ; 9c SBC A,H
	dw	sbcal_		    ; 9d SBC A,L
	dw	sbcahl		    ; 9e SBC A,(HL)
	dw	sbcaa		    ; 9f SBC A,A
	dw	andb		    ; a0 AND B
	dw	andc		    ; a1 AND C
	dw	andd		    ; a2 AND D
	dw	ande		    ; a3 AND E
	dw	andh		    ; a4 AND H
	dw	andl		    ; a5 AND L
	dw	andhl		    ; a6 AND (HL)
	dw	anda		    ; a7 AND A
	dw	xorb		    ; a8 XOR B
	dw	xorc		    ; a9 XOR C
	dw	xord		    ; aa XOR D
	dw	xore		    ; ab XOR E
	dw	xorh		    ; ac XOR H
	dw	xorl		    ; ad XOR L
	dw	xorhl		    ; ae XOR (HL)
	dw	xora		    ; af XOR A
	dw	orb		    ; b0 OR B
	dw	orc		    ; b1 OR C
	dw	ord		    ; b2 OR D
	dw	ore		    ; b3 OR E
	dw	orh		    ; b4 OR H
	dw	orl		    ; b5 OR L
	dw	orhl		    ; b6 OR (HL)
	dw	ora		    ; b7 OR A
	dw	cpb		    ; b8 CP B
	dw	cpc		    ; b9 CP C
	dw	cp_d		    ; ba CP D
	dw	cpe		    ; bb CP E
	dw	cph		    ; bc CP H
	dw	cp_l		    ; bd CP L
	dw	cphl		    ; be CP (HL)
	dw	cpa		    ; bf CP A
	dw	retnz		    ; c0 RET NZ
	dw	popbc		    ; c1 POP BC
	dw	jpnz		    ; c2 JP NZ
	dw	jpnn		    ; c3 JP nn
	dw	callnz		    ; c4 CALL NZ
	dw	pushbc		    ; c5 PUSH BC
	dw	addan		    ; c6 ADD A,n
	dw	rst00		    ; c7 RST 0x00
	dw	retz		    ; c8 RET Z
	dw	ret10		    ; c9 RET
	dw	jpz		    ; ca JP Z
	dw	opcb		    ; cb op cb
	dw	callz		    ; cc CALL Z
	dw	callnn		    ; cd CALL NN
	dw	adcan		    ; ce ADC A,n
	dw	rst08		    ; cf RST 0x08
	dw	retnc		    ; d0 RET NC
	dw	popde		    ; d1 POP DE
	dw	jpnc		    ; d2 JP NC
	dw	outna		    ; d3 OUT (n),A
	dw	callnc		    ; d4 CALL NC
	dw	pushde		    ; d5 PUSH DE
	dw	subn		    ; d6 SUB n
	dw	rst10		    ; d7 RST 0x10
	dw	retc		    ; d8 RET C
	dw	exx		    ; d9 EXX
	dw	jpc		    ; da JP C
	dw	inan		    ; db IN A,(n)
	dw	callc		    ; dc CALL C
	dw	opdd		    ; dd OP dd
	dw	sbcan		    ; de SBC A,n
	dw	rst18		    ; df RST 0x18
	dw	retpo		    ; e0 RET PO
	dw	pophl		    ; e1 POP HL
	dw	jppo		    ; e2 JP PO
	dw	exsphl		    ; e3 EX (SP),HL
	dw	callpo		    ; e4 CALL PO
	dw	pushhl		    ; e5 PUSH HL
	dw	andan		    ; e6 AND A,n
	dw	rst20		    ; e7 RST 0x20
	dw	retpe		    ; e8 RET PE
	dw	jphl		    ; e9 JP (HL)
	dw	jppe		    ; ea JP PE
	dw	exdehl		    ; eb EX DE,HL
	dw	callpe		    ; ec CALL PE
	dw	oped		    ; ed op ed
	dw	xoran		    ; ee XOR A,n
	dw	rst28		    ; ef RST 0x28
	dw	retp		    ; f0 RET P
	dw	popaf		    ; f1 POP AF
	dw	jpp		    ; f2 JP P
	dw	di		    ; f3 DI
	dw	callp		    ; f4 CALL P
	dw	pushaf		    ; f5 PUSH AF
	dw	oran		    ; f6 OR A,n
	dw	rst30		    ; f7 RST 0x30
	dw	retm		    ; f8 RET M
	dw	ldsphl		    ; f9 LD SP,HL
	dw	jpm		    ; fa JP M
	dw	ei		    ; fb EI
	dw	callm		    ; fc CALL M
	dw	opfd		    ; fd op fd
	dw	cpan		    ; fe CP A,n
	dw	rst38		    ; ff RST 0x38
      end if

nop_:	TIME	4
	PREFIX0

opdd:	TIME	4
      if fast = 0
	PREFIX1
      else
	mov	lr, 0x00010000
	uadd8	arvpref, arvpref, lr
	ldrb	lr, [mem, pcff, lsr 16]
	add	pcff, 0x00010000
	ldr	pc, [pc, lr, lsl 2]
	dw	0
	dw	nop_		    ; 00 NOP
	dw	ldbcnn		    ; 01 LD BC,nn
	dw	ldbca		    ; 02 LD (BC),A
	dw	incbc		    ; 03 INC BC
	dw	incb		    ; 04 INC B
	dw	decb		    ; 05 DEC B
	dw	ldbn		    ; 06 LD B,n
	dw	rlca		    ; 07 RLCA
	dw	exafaf		    ; 08 EX AF,AF
	dw	addixbc		    ; 09 ADD IX,BC
	dw	ldabc		    ; 0a LD A,(BC)
	dw	decbc		    ; 0b DEC BC
	dw	incc		    ; 0c INC C
	dw	decc		    ; 0d DEC C
	dw	ldcn		    ; 0e LD C,n
	dw	rrca		    ; 0f RRCA
	dw	djnz		    ; 10 DJNZ
	dw	lddenn		    ; 11 LD DE,nn
	dw	lddea		    ; 12 LD (DE),A
	dw	incde		    ; 13 INC DE
	dw	incd		    ; 14 INC D
	dw	decd		    ; 15 DEC D
	dw	lddn		    ; 16 LD D,n
	dw	rla		    ; 17 RLA
	dw	jr		    ; 18 JR
	dw	addiyde		    ; 19 ADD IY,DE
	dw	ldade		    ; 1a LD A,(DE)
	dw	decde		    ; 1b DEC DE
	dw	ince		    ; 1c INC E
	dw	dece		    ; 1d DEC E
	dw	lden		    ; 1e LD E,n
	dw	rra		    ; 1f RRA
	dw	jrnz		    ; 20 JR NZ,s8
	dw	ldixnn		    ; 21 LD IX,nn
	dw	ldpnnix		    ; 22 LD (nn),IX
	dw	incix		    ; 23 INC IX
	dw	incixh		    ; 24 INC IXh
	dw	decixh		    ; 25 DEC IXh
	dw	ldixhn		    ; 26 LD IXh,n
	dw	daa		    ; 27 DAA
	dw	jrz		    ; 28 JR Z,s8
	dw	addixix		    ; 29 ADD IX,IX
	dw	ldixpnn		    ; 2a LD IX,(nn)
	dw	decix		    ; 2b DEC IX
	dw	incixl		    ; 2c INC IXl
	dw	decixl		    ; 2d DEC IXl
	dw	ldixln		    ; 2e LD IXl,n
	dw	cpl		    ; 2f CPL
	dw	jrnc		    ; 30 JR NC,s8
	dw	ldspnn		    ; 31 LD SP,nn
	dw	ldnna		    ; 32 LD (nn),A
	dw	incsp		    ; 33 INC SP
	dw	incpix		    ; 34 INC (IX + d)
	dw	decpix		    ; 35 DEC (IX + d)
	dw	ldixn		    ; 36 LD (IX + d),n
	dw	scf		    ; 37 SCF
	dw	jrc		    ; 38 JR C,s8
	dw	addixsp		    ; 39 ADD IX,SP
	dw	ldann		    ; 3a LD A,(nn)
	dw	decsp		    ; 3b DEC SP
	dw	inca		    ; 3c INC A
	dw	deca		    ; 3d DEC A
	dw	ldan		    ; 3e LD A,n
	dw	ccf		    ; 3f CCF
	dw	nop_		    ; 40 LD B,B
	dw	ldbc		    ; 41 LD B,C
	dw	ldbd		    ; 42 LD B,D
	dw	ldbe		    ; 43 LD B,E
	dw	ldbixh		    ; 44 LD B,IXh
	dw	ldbixl		    ; 45 LD B,IXl
	dw	ldbix		    ; 46 LD B,(IX + d)
	dw	ldba		    ; 47 LD B,A
	dw	ldcb		    ; 48 LD C,B
	dw	nop_		     ; 49 LD C,C
	dw	ldcd		    ; 4a LD C,D
	dw	ldce		    ; 4b LD C,E
	dw	ldcixh		    ; 4c LD C,IXh
	dw	ldcixl		    ; 4d LD C,IXl
	dw	ldcix		    ; 4e LD C,(IX + d)
	dw	ldca		    ; 4f LD C,A
	dw	lddb		    ; 50 LD D,B
	dw	lddc		    ; 51 LD D,C
	dw	nop_		    ; 52 LD D,D
	dw	ldde		    ; 53 LD D,E
	dw	lddixh		    ; 54 LD D,IXh
	dw	lddixl		    ; 55 LD D,IXl
	dw	lddix		    ; 56 LD D,(IX + d)
	dw	ldda		    ; 57 LD D,A
	dw	ldeb		    ; 58 LD E,B
	dw	ldec		    ; 59 LD E,C
	dw	lded		    ; 5a LD E,D
	dw	nop_		    ; 5b LD E,E
	dw	ldeixh		    ; 5c LD E,IXh
	dw	ldeixl		    ; 5d LD E,IXl
	dw	ldeix		    ; 5e LD E,(IX + d)
	dw	ldea		    ; 5f LD E,A
	dw	ldixhb		    ; 60 LD IXh,B
	dw	ldixhc		    ; 61 LD IXh,C
	dw	ldixhd		    ; 62 LD IXh,D
	dw	ldixhe		    ; 63 LD IXh,E
	dw	nop_		    ; 64 LD IXh,IXh
	dw	ldxhxl		    ; 65 LD IXh,IXl
	dw	ldhix		    ; 66 LD H,(IX + d)
	dw	ldixha		    ; 67 LD IXh,A
	dw	ldixlb		    ; 68 LD IXl,B
	dw	ldixlc		    ; 69 LD IXl,C
	dw	ldixld		    ; 6a LD IXl,D
	dw	ldixle		    ; 6b LD IXl,E
	dw	ldxlxh		    ; 6c LD IXl,IXh
	dw	nop_		    ; 6d LD IXl,IXl
	dw	ldlix		    ; 6e LD L,(IX + d)
	dw	ldixla		    ; 6f LD IXl,A
	dw	ldixb		    ; 70 LD (IX + d),B
	dw	ldixc		    ; 71 LD (IX + d),C
	dw	ldixd		    ; 72 LD (IX + d),D
	dw	ldixe		    ; 73 LD (IX + d),E
	dw	ldixh		    ; 74 LD (IX + d),H
	dw	ldixl		    ; 75 LD (IX + d),L
	dw	halt		    ; 76 HALT
	dw	ldixa		    ; 77 LD (IX + d),A
	dw	ldab_		    ; 78 LD A,B
	dw	ldac		    ; 79 LD A,C
	dw	ldad		    ; 7a LD A,D
	dw	ldae		    ; 7b LD A,E
	dw	ldaixh		    ; 7c LD A,IXh
	dw	ldaixl		    ; 7d LD A,IXl
	dw	ldaix		    ; 7e LD A,(IX + d)
	dw	nop_		    ; 7f LD A,A
	dw	addab		    ; 80 ADD A,B
	dw	addac		    ; 81 ADD A,C
	dw	addad		    ; 82 ADD A,D
	dw	addae		    ; 83 ADD A,E
	dw	addaxh		    ; 84 ADD A,IXh
	dw	addaxl		    ; 85 ADD A,IXl
	dw	addaix		    ; 86 ADD A,(IX + d)
	dw	addaa		    ; 87 ADD A,A
	dw	adcab		    ; 88 ADC A,B
	dw	adcac		    ; 89 ADC A,C
	dw	adcad		    ; 8a ADC A,D
	dw	adcae		    ; 8b ADC A,E
	dw	adcaxh		    ; 8c ADC A,IXh
	dw	adcaxl		    ; 8d ADC A,IXl
	dw	adcaix		    ; 8e ADC A,(IX + d)
	dw	adcaa		    ; 8f ADC A,A
	dw	subb		    ; 90 SUB B
	dw	subc		    ; 91 SUB C
	dw	subd		    ; 92 SUB D
	dw	sube		    ; 93 SUB E
	dw	subxh		    ; 94 SUB IXh
	dw	subxl		    ; 95 SUB IXl
	dw	subix		    ; 96 SUB (IX + d)
	dw	suba		    ; 97 SUB A
	dw	sbcab		    ; 98 SBC A,B
	dw	sbcac		    ; 99 SBC A,C
	dw	sbcad		    ; 9a SBC A,D
	dw	sbcae		    ; 9b SBC A,E
	dw	sbcaxh		    ; 9c SBC A,IXh
	dw	sbcaxl		    ; 9d SBC A,IXl
	dw	sbcaix		    ; 9e SBC A,(IX + d)
	dw	sbcaa		    ; 9f SBC A,A
	dw	andb		    ; a0 AND B
	dw	andc		    ; a1 AND C
	dw	andd		    ; a2 AND D
	dw	ande		    ; a3 AND E
	dw	andxh		    ; a4 AND IXh
	dw	andxl		    ; a5 AND IXl
	dw	andix		    ; a6 AND (IX + d)
	dw	anda		    ; a7 AND A
	dw	xorb		    ; a8 XOR B
	dw	xorc		    ; a9 XOR C
	dw	xord		    ; aa XOR D
	dw	xore		    ; ab XOR E
	dw	xorxh		    ; ac XOR IXh
	dw	xorxl		    ; ad XOR IXl
	dw	xorix		    ; ae XOR (IX + d)
	dw	xora		    ; af XOR A
	dw	orb		    ; b0 OR B
	dw	orc		    ; b1 OR C
	dw	ord		    ; b2 OR D
	dw	ore		    ; b3 OR E
	dw	orxh		    ; b4 OR IXh
	dw	orxl		    ; b5 OR IXl
	dw	orix		    ; b6 OR (IX + d)
	dw	ora		    ; b7 OR A
	dw	cpb		    ; b8 CP B
	dw	cpc		    ; b9 CP C
	dw	cp_d		    ; ba CP D
	dw	cpe		    ; bb CP E
	dw	cpxh		    ; bc CP IXh
	dw	cpxl		    ; bd CP IXl
	dw	cpix		    ; be CP (IX + d)
	dw	cpa		    ; bf CP A
	dw	retnz		    ; c0 RET NZ
	dw	popbc		    ; c1 POP BC
	dw	jpnz		    ; c2 JP NZ
	dw	jpnn		    ; c3 JP nn
	dw	callnz		    ; c4 CALL NZ
	dw	pushbc		    ; c5 PUSH BC
	dw	addan		    ; c6 ADD A,n
	dw	rst00		    ; c7 RST 0x00
	dw	retz		    ; c8 RET Z
	dw	ret10		    ; c9 RET
	dw	jpz		    ; ca JP Z
	dw	opddcb		    ; cb op cb
	dw	callz		    ; cc CALL Z
	dw	callnn		    ; cd CALL NN
	dw	adcan		    ; ce ADC A,n
	dw	rst08		    ; cf RST 0x08
	dw	retnc		    ; d0 RET NC
	dw	popde		    ; d1 POP DE
	dw	jpnc		    ; d2 JP NC
	dw	outna		    ; d3 OUT (n),A
	dw	callnc		    ; d4 CALL NC
	dw	pushde		    ; d5 PUSH DE
	dw	subn		    ; d6 SUB n
	dw	rst10		    ; d7 RST 0x10
	dw	retc		    ; d8 RET C
	dw	exx		    ; d9 EXX
	dw	jpc		    ; da JP C
	dw	inan		    ; db IN A,(n)
	dw	callc		    ; dc CALL C
	dw	opdd		    ; dd OP dd
	dw	sbcan		    ; de SBC A,n
	dw	rst18		    ; df RST 0x18
	dw	retpo		    ; e0 RET PO
	dw	popix		    ; e1 POP IX
	dw	jppo		    ; e2 JP PO
	dw	exspix		    ; e3 EX (SP),IX
	dw	callpo		    ; e4 CALL PO
	dw	pushix		    ; e5 PUSH IX
	dw	andan		    ; e6 AND A,n
	dw	rst20		    ; e7 RST 0x20
	dw	retpe		    ; e8 RET PE
	dw	jpix		    ; e9 JP (IX)
	dw	jppe		    ; ea JP PE
	dw	exdehl		    ; eb EX DE,HL
	dw	callpe		    ; ec CALL PE
	dw	oped		    ; ed op ed
	dw	xoran		    ; ee XOR A,n
	dw	rst28		    ; ef RST 0x28
	dw	retp		    ; f0 RET P
	dw	popaf		    ; f1 POP AF
	dw	jpp		    ; f2 JP P
	dw	di		    ; f3 DI
	dw	callp		    ; f4 CALL P
	dw	pushaf		    ; f5 PUSH AF
	dw	oran		    ; f6 OR A,n
	dw	rst30		    ; f7 RST 0x30
	dw	retm		    ; f8 RET M
	dw	ldspix		    ; f9 LD SP,IX
	dw	jpm		    ; fa JP M
	dw	ei		    ; fb EI
	dw	callm		    ; fc CALL M
	dw	opfd		    ; fd op fd
	dw	cpan		    ; fe CP A,n
	dw	rst38		    ; ff RST 0x38
      end if

opfd:	TIME	4
      if fast = 0
	PREFIX2
      else
	mov	lr, 0x00010000
	uadd8	arvpref, arvpref, lr
	ldrb	lr, [mem, pcff, lsr 16]
	add	pcff, 0x00010000
	ldr	pc, [pc, lr, lsl 2]
	dw	0
	dw	nop_		    ; 00 NOP
	dw	ldbcnn		    ; 01 LD BC,nn
	dw	ldbca		    ; 02 LD (BC),A
	dw	incbc		    ; 03 INC BC
	dw	incb		    ; 04 INC B
	dw	decb		    ; 05 DEC B
	dw	ldbn		    ; 06 LD B,n
	dw	rlca		    ; 07 RLCA
	dw	exafaf		    ; 08 EX AF,AF
	dw	addiybc		    ; 09 ADD IY,BC
	dw	ldabc		    ; 0a LD A,(BC)
	dw	decbc		    ; 0b DEC BC
	dw	incc		    ; 0c INC C
	dw	decc		    ; 0d DEC C
	dw	ldcn		    ; 0e LD C,n
	dw	rrca		    ; 0f RRCA
	dw	djnz		    ; 10 DJNZ
	dw	lddenn		    ; 11 LD DE,nn
	dw	lddea		    ; 12 LD (DE),A
	dw	incde		    ; 13 INC DE
	dw	incd		    ; 14 INC D
	dw	decd		    ; 15 DEC D
	dw	lddn		    ; 16 LD D,n
	dw	rla		    ; 17 RLA
	dw	jr		    ; 18 JR
	dw	addiyde		    ; 19 ADD IY,DE
	dw	ldade		    ; 1a LD A,(DE)
	dw	decde		    ; 1b DEC DE
	dw	ince		    ; 1c INC E
	dw	dece		    ; 1d DEC E
	dw	lden		    ; 1e LD E,n
	dw	rra		    ; 1f RRA
	dw	jrnz		    ; 20 JR NZ,s8
	dw	ldiynn		    ; 21 LD IY,nn
	dw	ldpnniy		    ; 22 LD (nn),IY
	dw	inciy		    ; 23 INC IY
	dw	inciyh		    ; 24 INC IYh
	dw	deciyh		    ; 25 DEC IYh
	dw	ldiyhn		    ; 26 LD IYh,n
	dw	daa		    ; 27 DAA
	dw	jrz		    ; 28 JR Z,s8
	dw	addiyiy		    ; 29 ADD IY,IY
	dw	ldiypnn		    ; 2a LD IY,(nn)
	dw	deciy		    ; 2b DEC IY
	dw	inciyl		    ; 2c INC IYl
	dw	deciyl		    ; 2d DEC IYl
	dw	ldiyln		    ; 2e LD IYl,n
	dw	cpl		    ; 2f CPL
	dw	jrnc		    ; 30 JR NC,s8
	dw	ldspnn		    ; 31 LD SP,nn
	dw	ldnna		    ; 32 LD (nn),A
	dw	incsp		    ; 33 INC SP
	dw	incpiy		    ; 34 INC (IY + d)
	dw	decpiy		    ; 35 DEC (IY + d)
	dw	ldiyn		    ; 36 LD (IY + d),n
	dw	scf		    ; 37 SCF
	dw	jrc		    ; 38 JR C,s8
	dw	addiysp		    ; 39 ADD IY,SP
	dw	ldann		    ; 3a LD A,(nn)
	dw	decsp		    ; 3b DEC SP
	dw	inca		    ; 3c INC A
	dw	deca		    ; 3d DEC A
	dw	ldan		    ; 3e LD A,n
	dw	ccf		    ; 3f CCF
	dw	nop_		    ; 40 LD B,B
	dw	ldbc		    ; 41 LD B,C
	dw	ldbd		    ; 42 LD B,D
	dw	ldbe		    ; 43 LD B,E
	dw	ldbiyh		    ; 44 LD B,IYh
	dw	ldbiyl		    ; 45 LD B,IYl
	dw	ldbiy		    ; 46 LD B,(IY + d)
	dw	ldba		    ; 47 LD B,A
	dw	ldcb		    ; 48 LD C,B
	dw	nop_		    ; 49 LD C,C
	dw	ldcd		    ; 4a LD C,D
	dw	ldce		    ; 4b LD C,E
	dw	ldciyh		    ; 4c LD C,IYh
	dw	ldciyl		    ; 4d LD C,IYl
	dw	ldciy		    ; 4e LD C,(IY + d)
	dw	ldca		    ; 4f LD C,A
	dw	lddb		    ; 50 LD D,B
	dw	lddc		    ; 51 LD D,C
	dw	nop_		    ; 52 LD D,D
	dw	ldde		    ; 53 LD D,E
	dw	lddiyh		    ; 54 LD D,IYh
	dw	lddiyl		    ; 55 LD D,IYl
	dw	lddiy		    ; 56 LD D,(IY + d)
	dw	ldda		    ; 57 LD D,A
	dw	ldeb		    ; 58 LD E,B
	dw	ldec		    ; 59 LD E,C
	dw	lded		    ; 5a LD E,D
	dw	nop_		    ; 5b LD E,E
	dw	ldeiyh		    ; 5c LD E,IYh
	dw	ldeiyl		    ; 5d LD E,IYl
	dw	ldeiy		    ; 5e LD E,(IY + d)
	dw	ldea		    ; 5f LD E,A
	dw	ldiyhb		    ; 60 LD IYh,B
	dw	ldiyhc		    ; 61 LD IYh,C
	dw	ldiyhd		    ; 62 LD IYh,D
	dw	ldiyhe		    ; 63 LD IYh,E
	dw	nop_		    ; 64 LD IYh,IYh
	dw	ldyhyl		    ; 65 LD IYh,IYl
	dw	ldhiy		    ; 66 LD H,(IY + d)
	dw	ldiyha		    ; 67 LD IYh,A
	dw	ldiylb		    ; 68 LD IYl,B
	dw	ldiylc		    ; 69 LD IYl,C
	dw	ldiyld		    ; 6a LD IYl,D
	dw	ldiyle		    ; 6b LD IYl,E
	dw	ldylyh		    ; 6c LD IYl,IYh
	dw	nop_		    ; 6d LD IYl,IYl
	dw	ldliy		    ; 6e LD L,(IY + d)
	dw	ldiyla		    ; 6f LD IYl,A
	dw	ldiyb		    ; 70 LD (IY + d),B
	dw	ldiyc		    ; 71 LD (IY + d),C
	dw	ldiyd		    ; 72 LD (IY + d),D
	dw	ldiye		    ; 73 LD (IY + d),E
	dw	ldiyh		    ; 74 LD (IY + d),H
	dw	ldiyl		    ; 75 LD (IY + d),L
	dw	halt		    ; 76 HALT
	dw	ldiya		    ; 77 LD (IY + d),A
	dw	ldab_		    ; 78 LD A,B
	dw	ldac		    ; 79 LD A,C
	dw	ldad		    ; 7a LD A,D
	dw	ldae		    ; 7b LD A,E
	dw	ldaiyh		    ; 7c LD A,IYh
	dw	ldaiyl		    ; 7d LD A,IYl
	dw	ldaiy		    ; 7e LD A,(IY + d)
	dw	nop_		    ; 7f LD A,A
	dw	addab		    ; 80 ADD A,B
	dw	addac		    ; 81 ADD A,C
	dw	addad		    ; 82 ADD A,D
	dw	addae		    ; 83 ADD A,E
	dw	addayh		    ; 84 ADD A,IYh
	dw	addayl		    ; 85 ADD A,IYl
	dw	addaiy		    ; 86 ADD A,(IY + d)
	dw	addaa		    ; 87 ADD A,A
	dw	adcab		    ; 88 ADC A,B
	dw	adcac		    ; 89 ADC A,C
	dw	adcad		    ; 8a ADC A,D
	dw	adcae		    ; 8b ADC A,E
	dw	adcayh		    ; 8c ADC A,IYh
	dw	adcayl		    ; 8d ADC A,IYl
	dw	adcaiy		    ; 8e ADC A,(IY + d)
	dw	adcaa		    ; 8f ADC A,A
	dw	subb		    ; 90 SUB B
	dw	subc		    ; 91 SUB C
	dw	subd		    ; 92 SUB D
	dw	sube		    ; 93 SUB E
	dw	subyh		    ; 94 SUB IYh
	dw	subyl		    ; 95 SUB IYl
	dw	subiy		    ; 96 SUB (IY + d)
	dw	suba		    ; 97 SUB A
	dw	sbcab		    ; 98 SBC A,B
	dw	sbcac		    ; 99 SBC A,C
	dw	sbcad		    ; 9a SBC A,D
	dw	sbcae		    ; 9b SBC A,E
	dw	sbcayh		    ; 9c SBC A,IYh
	dw	sbcayl		    ; 9d SBC A,IYl
	dw	sbcaiy		    ; 9e SBC A,(IY + d)
	dw	sbcaa		    ; 9f SBC A,A
	dw	andb		    ; a0 AND B
	dw	andc		    ; a1 AND C
	dw	andd		    ; a2 AND D
	dw	ande		    ; a3 AND E
	dw	andyh		    ; a4 AND IYh
	dw	andyl		    ; a5 AND IYl
	dw	andiy		    ; a6 AND (IY + d)
	dw	anda		    ; a7 AND A
	dw	xorb		    ; a8 XOR B
	dw	xorc		    ; a9 XOR C
	dw	xord		    ; aa XOR D
	dw	xore		    ; ab XOR E
	dw	xoryh		    ; ac XOR IYh
	dw	xoryl		    ; ad XOR IYl
	dw	xoriy		    ; ae XOR (IY + d)
	dw	xora		    ; af XOR A
	dw	orb		    ; b0 OR B
	dw	orc		    ; b1 OR C
	dw	ord		    ; b2 OR D
	dw	ore		    ; b3 OR E
	dw	oryh		    ; b4 OR IYh
	dw	oryl		    ; b5 OR IYl
	dw	oriy		    ; b6 OR (IY + d)
	dw	ora		    ; b7 OR A
	dw	cpb		    ; b8 CP B
	dw	cpc		    ; b9 CP C
	dw	cp_d		    ; ba CP D
	dw	cpe		    ; bb CP E
	dw	cpyh		    ; bc CP IYh
	dw	cpyl		    ; bd CP IYl
	dw	cpiy		    ; be CP (IY + d)
	dw	cpa		    ; bf CP A
	dw	retnz		    ; c0 RET NZ
	dw	popbc		    ; c1 POP BC
	dw	jpnz		    ; c2 JP NZ
	dw	jpnn		    ; c3 JP nn
	dw	callnz		    ; c4 CALL NZ
	dw	pushbc		    ; c5 PUSH BC
	dw	addan		    ; c6 ADD A,n
	dw	rst00		    ; c7 RST 0x00
	dw	retz		    ; c8 RET Z
	dw	ret10		    ; c9 RET
	dw	jpz		    ; ca JP Z
	dw	opfdcb		    ; cb op cb
	dw	callz		    ; cc CALL Z
	dw	callnn		    ; cd CALL NN
	dw	adcan		    ; ce ADC A,n
	dw	rst08		    ; cf RST 0x08
	dw	retnc		    ; d0 RET NC
	dw	popde		    ; d1 POP DE
	dw	jpnc		    ; d2 JP NC
	dw	outna		    ; d3 OUT (n),A
	dw	callnc		    ; d4 CALL NC
	dw	pushde		    ; d5 PUSH DE
	dw	subn		    ; d6 SUB n
	dw	rst10		    ; d7 RST 0x10
	dw	retc		    ; d8 RET C
	dw	exx		    ; d9 EXX
	dw	jpc		    ; da JP C
	dw	inan		    ; db IN A,(n)
	dw	callc		    ; dc CALL C
	dw	opdd		    ; dd OP dd
	dw	sbcan		    ; de SBC A,n
	dw	rst18		    ; df RST 0x18
	dw	retpo		    ; e0 RET PO
	dw	popiy		    ; e1 POP IY
	dw	jppo		    ; e2 JP PO
	dw	exspiy		    ; e3 EX (SP),IY
	dw	callpo		    ; e4 CALL PO
	dw	pushiy		    ; e5 PUSH IY
	dw	andan		    ; e6 AND A,n
	dw	rst20		    ; e7 RST 0x20
	dw	retpe		    ; e8 RET PE
	dw	jpiy		    ; e9 JP (IY)
	dw	jppe		    ; ea JP PE
	dw	exdehl		    ; eb EX DE,HL
	dw	callpe		    ; ec CALL PE
	dw	oped		    ; ed op ed
	dw	xoran		    ; ee XOR A,n
	dw	rst28		    ; ef RST 0x28
	dw	retp		    ; f0 RET P
	dw	popaf		    ; f1 POP AF
	dw	jpp		    ; f2 JP P
	dw	di		    ; f3 DI
	dw	callp		    ; f4 CALL P
	dw	pushaf		    ; f5 PUSH AF
	dw	oran		    ; f6 OR A,n
	dw	rst30		    ; f7 RST 0x30
	dw	retm		    ; f8 RET M
	dw	ldspiy		    ; f9 LD SP,IY
	dw	jpm		    ; fa JP M
	dw	ei		    ; fb EI
	dw	callm		    ; fc CALL M
	dw	opfd		    ; fd op fd
	dw	cpan		    ; fe CP A,n
	dw	rst38		    ; ff RST 0x38
      end if

daa:	TIME	4
	and	lr, pcff, 0x00000100
	mov	r11, 0x00000000
	mov	r10, arvpref, lsr 24
	orr	r10, lr
	cmp	r10, 0x00000099
	movhi	r11, 0x00000160
	and	r10, 0x0000000f
	eor	lr, defr, spfa
	eor	lr, bcfb
	eor	lr, bcfb, lsr 8
	and	lr, 0x00000010
	orr	lr, r10
	cmp	lr, 0x00000009
	addhi	r11, 0x00000006
	mov	r10, arvpref, lsr 24
	pkhtb	spfa, spfa, r10
	orr	spfa, 0x00000100
	tst	bcfb, 0x00000200
	mov	lr, r11
	mvnne	lr, r11
	pkhtb	bcfb, bcfb, lr
	subne	arvpref, r11, lsl 24
	addeq	arvpref, r11, lsl 24
	mov	lr, arvpref, lsr 24
	pkhtb	defr, defr, lr
	and	r11, 0x00000100
	orr	lr, r11
	pkhtb	pcff, pcff, lr
	PREFIX0

cpl:	TIME	4
	eor	arvpref, 0xff000000
	mov	lr, arvpref, lsr 24
	eor	lr, pcff
	and	lr, 0x00000028
	eor	pcff, lr
	orr	bcfb, 0x0000007f
	orr	bcfb, 0x0000ff00
	mvn	lr, defr
	eor	lr, spfa
	and	lr, 0x00000010
	eor	spfa, lr
	PREFIX0

rlca:	TIME	4
	uxtb	lr, arvpref, ror 24
	add	lr, lr, lr, lsl 8
	pkhtb	pcff, pcff, lr, asr 7
	uxtb	lr, pcff
	bic	arvpref, 0xff000000
	orr	arvpref, lr, lsl 24
	pkhtb	defr, defr, lr
	orr	lr, 0x00000100
	pkhtb	spfa, spfa, lr
	pkhtb	bcfb, bcfb, lr, asr 16
	; mov	  lr, arvpref, lsr 24
	; add	  lr, lr, lr, lsl 8
	; mov	  r11, lr, lsr 7
	; bic	  arvpref, 0xff000000
	; orr	  arvpref, r11, lsl 24
	; eor	  r11, pcff
	; and	  r11, 0x00000128
	; eor	  pcff, r11
	; eor	  lr, spfa, defr
	; and	  lr, 0x00000010
	; and	  r11, bcfb, 0x00000080
	; orr	  lr, r11
	; pkhtb	  bcfb, bcfb, lr
	PREFIX0

rrca:	TIME	4
	movs	lr, arvpref, lsr 25
	orrcs	lr, 0x00000180
	bic	arvpref, 0xff000000
	orr	arvpref, lr, lsl 24
	eor	lr, pcff
	and	lr, 0x00000128
	eor	pcff, lr
	eor	lr, spfa, defr
	and	lr, 0x00000010
	and	r11, bcfb, 0x00000080
	orr	lr, r11
	pkhtb	bcfb, bcfb, lr
	PREFIX0

rla:	TIME	4
	movs	lr, pcff, lsl 24
	uxtb	lr, arvpref, ror 24
	adc	lr, lr
	pkhtb	pcff, pcff, lr
	uxtb	lr, lr
	bic	arvpref, 0xff000000
	orr	arvpref, lr, lsl 24
	pkhtb	defr, defr, lr
	add	lr, 0x00000100
	pkhtb	spfa, spfa, lr
	pkhtb	bcfb, bcfb, lr, asr 16
	; mov	  lr, arvpref, lsr 24
	; movs	  r11, pcff, lsr 9
	; adc	  lr, lr
	; bic	  arvpref, 0xff000000
	; orr	  arvpref, lr, lsl 24
	; eor	  lr, pcff
	; and	  lr, 0x00000128
	; eor	  pcff, lr
	; eor	  lr, spfa, defr
	; and	  lr, 0x00000010
	; and	  r11, bcfb, 0x00000080
	; orr	  lr, r11
	; pkhtb	  bcfb, bcfb, lr
	PREFIX0

rra:	TIME	4
	mov	lr, arvpref, lsr 24
	add	lr, lr, lr, lsl 9
	and	r11, pcff, 0x00000100
	orr	lr, r11
	mov	lr, lr, lsr 1
	bic	arvpref, 0xff000000
	orr	arvpref, lr, lsl 24
	and	lr, 0x00000128
	and	r11, pcff, 0x000000d7
	orr	lr, r11
	pkhtb	pcff, pcff, lr
	eor	lr, spfa, defr
	and	lr, 0x00000010
	and	r11, bcfb, 0x00000080
	orr	lr, r11
	pkhtb	bcfb, bcfb, lr
	PREFIX0

outna:	TIME	11
	ldrb	lr, [mem, pcff, lsr 16]
	add	pcff, 0x00010000
	push	{r0-r3}
	mov	r1, arvpref, lsr 24
	orr	r0, lr, r1, lsl 8
	mov	r11, 0x00000001
	uadd8	r11, r11, r0
	pkhtb	hlmp, hlmp, r11
	bl	out
	pop	{r0-r3}
	PREFIX0

inan:	TIME	11
	ldrb	lr, [mem, pcff, lsr 16]
	add	pcff, 0x00010000
	mov	r11, arvpref, lsr 24
	push	{r0-r3}
	orr	r0, lr, r11, lsl 8
	add	r11, r0, 0x00000001
	pkhtb	hlmp, hlmp, r11
	bl	in_
	bic	arvpref, 0xff000000
	orr	arvpref, r0, lsl 24
	pop	{r0-r3}
	PREFIX0

djnz:	sub	bcfb, 0x01000000
	tst	bcfb, 0xff000000
	beq	djnz2
	TIME	13
	ldr	lr, [mem, pcff, lsr 16]
	sxtb	lr, lr
	add	pcff, lr, lsl 16
	add	pcff, 0x00010000
	pkhtb	hlmp, hlmp, pcff, asr 16
	PREFIX0
djnz2:	TIME	8
	add	pcff, 0x00010000
	PREFIX0

ei:	TIME	4
	orr	arvpref, 0x00000400
	PREFIX0

di:	TIME	4
	and	arvpref, 0xfffffbff
	PREFIX0

ldbcnn: LDRRIM	bcfb
lddenn: LDRRIM	defr
ldspnn: LDRRIM	spfa

      if fast = 0
ldxxn:	movs	lr, arvpref, lsl 24
	beq	ldhln
	bmi	ldiyn
      end if
ldixn:	LDPIM	ix
ldiyn:	LDPIM	iyi
ldhln:	TIME	10
	ldr	lr, [mem, pcff, lsr 16]
	add	pcff, 0x00010000
	strb	lr, [mem, hlmp, lsr 16]
	PREFIX0

      if fast = 0
ldxxnn: movs	lr, arvpref, lsl 24
	beq	ldhlnn
	bmi	ldiynn
      end if
ldixnn: LDRRIM	ix
ldiynn: LDRRIM	iyi
ldhlnn: LDRRIM	hlmp

      if fast = 0
jpxx:	TIME	4
	movs	lr, arvpref, lsl 24
	beq	jphl
	bmi	jpiy
      end if
jpix:	pkhbt	pcff, pcff, ix
	PREFIX0
jpiy:	pkhbt	pcff, pcff, iyi
	PREFIX0
jphl:	pkhbt	pcff, pcff, hlmp
	PREFIX0

      if fast = 0
ldspxx: TIME	4
	movs	lr, arvpref, lsl 24
	beq	ldsphl
	bmi	ldspiy
      end if
ldspix: pkhbt	spfa, spfa, ix
	PREFIX0
ldspiy: pkhbt	spfa, spfa, iyi
	PREFIX0
ldsphl: pkhbt	spfa, spfa, hlmp
	PREFIX0

      if fast = 0
ldxxpnn:movs	lr, arvpref, lsl 24
	beq	ldhlpnn
	bmi	ldiypnn
      end if
ldixpnn:LDRRPNN ix, 16
	PREFIX0
ldiypnn:LDRRPNN iyi, 16
	PREFIX0
ldhlpnn:LDRRPNN hlmp, 16
	PREFIX0

ldbcpnn:LDRRPNN bcfb, 20
	b	exit
lddepnn:LDRRPNN defr, 20
	b	exit
ldxepnn:LDRRPNN hlmp, 20
	b	exit
ldsppnn:LDRRPNN spfa, 20
	b	exit

      if fast = 0
ldpnnxx:movs	lr, arvpref, lsl 24
	beq	ldpnnhl
	bmi	ldpnniy
      end if
ldpnnix:LDPNNRR ix, 16
	PREFIX0
ldpnniy:LDPNNRR iyi, 16
	PREFIX0
ldpnnhl:LDPNNRR hlmp, 16
	PREFIX0

ldpnnbc:LDPNNRR bcfb, 20
	b	exit
ldpnnde:LDPNNRR defr, 20
	b	exit
ldpnnxe:LDPNNRR hlmp, 20
	b	exit
ldpnnsp:LDPNNRR spfa, 20
	b	exit

      if fast = 0
addxxbc:movs	lr, arvpref, lsl 24
	beq	addhlbc
	bmi	addiybc
      end if
addixbc:ADDRRRR ix, bcfb
addiybc:ADDRRRR iyi, bcfb
addhlbc:ADDRRRR hlmp, bcfb

      if fast = 0
addxxde:movs	lr, arvpref, lsl 24
	beq	addhlde
	bmi	addiyde
      end if
addixde:ADDRRRR ix, defr
addiyde:ADDRRRR iyi, defr
addhlde:ADDRRRR hlmp, defr

      if fast = 0
addxxxx:movs	lr, arvpref, lsl 24
	beq	addhlhl
	bmi	addiyiy
      end if
addixix:ADDRRRR ix, ix
addiyiy:ADDRRRR iyi, iyi
addhlhl:ADDRRRR hlmp, hlmp

      if fast = 0
addxxsp:movs	lr, arvpref, lsl 24
	beq	addhlsp
	bmi	addiysp
      end if
addixsp:ADDRRRR ix, spfa
addiysp:ADDRRRR iyi, spfa
addhlsp:ADDRRRR hlmp, spfa

callnn: TIME	17
	mov	r11, pcff, lsr 16
	ldrh	lr, [mem, r11]
	add	r11, r11, 2
	pkhbt	pcff, pcff, lr, lsl 16
	pkhtb	hlmp, hlmp, lr
	sub	spfa, 0x00020000
	mov	r10, spfa, lsr 16
	strh	r11, [mem, r10]
	PREFIX0

callz:	movs	lr, defr, lsl 16
	CALLC

callnz: movs	lr, defr, lsl 16
	CALLCI

callnc: tst	pcff, 0x00000100
	CALLC

callc:	tst	pcff, 0x00000100
	CALLCI

callp:	tst	pcff, 0x00000080
	CALLC

callm:	tst	pcff, 0x00000080
	CALLCI

ret11:	RET	11
	PREFIX0

ret10:	RET	10
	PREFIX0

retz:	movs	lr, defr, lsl 16
	RETC

retnz:	movs	lr, defr, lsl 16
	RETCI

retnc:	tst	pcff, 0x00000100
	RETC

retc:	tst	pcff, 0x00000100
	RETCI

retp:	tst	pcff, 0x00000080
	RETC

retm:	tst	pcff, 0x00000080
	RETCI

jr:	TIME	12
	ldr	lr, [mem, pcff, lsr 16]
	sxtb	lr, lr
	add	pcff, lr, lsl 16
	add	pcff, 0x00010000
	pkhtb	hlmp, hlmp, pcff, asr 16
	PREFIX0

jrnc:	tst	pcff, 0x00000100
	JRC
jrnn:	TIME	12
	ldr	lr, [mem, pcff, lsr 16]
	sxtb	lr, lr
	add	pcff, lr, lsl 16
	add	pcff, 0x00010000
	PREFIX0

jrc:	tst	pcff, 0x00000100
	JRCI

jrz:	movs	lr, defr, lsl 16
	JRC

jrnz:	movs	lr, defr, lsl 16
	JRCI

jpnn:	TIME	10
	ldr	lr, [mem, pcff, lsr 16]
	pkhbt	pcff, pcff, lr, lsl 16
	pkhtb	hlmp, hlmp, lr
	PREFIX0

jpcc:	TIME	10
	ldr	lr, [mem, pcff, lsr 16]
	pkhbt	pcff, pcff, lr, lsl 16
	PREFIX0

jpz:	movs	lr, defr, lsl 16
	JPC
jpnz:	movs	lr, defr, lsl 16
	JPCI
jpnc:	tst	pcff, 0x00000100
	JPC
jpc:	tst	pcff, 0x00000100
	JPCI
jpp:	tst	pcff, 0x00000080
	JPC
jpm:	tst	pcff, 0x00000080
	JPCI

ldbn:	LDRIM	bcfb, 8
ldcn:	LDRIM	bcfb, 0
lddn:	LDRIM	defr, 8
lden:	LDRIM	defr, 0

      if fast = 0
lxhn:	movs	lr, arvpref, lsl 24
	beq	ldhn
	bmi	ldiyhn
      end if
ldixhn: LDRIM	ix, 8
ldiyhn: LDRIM	iyi, 8
ldhn:	LDRIM	hlmp, 8

      if fast = 0
lxln:	movs	lr, arvpref, lsl 24
	beq	ldln
	bmi	ldiyln
      end if
ldixln: LDRIM	ix, 0
ldiyln: LDRIM	iyi, 0
ldln:	LDRIM	hlmp, 0

ldan:	LDRIM	arvpref, 8

ldann:	TIME	13
	ldr	lr, [mem, pcff, lsr 16]
	mov	lr, lr, lsl 16
	ldrb	r11, [mem, lr, lsr 16]
	bic	arvpref, 0xff000000
	orr	arvpref, r11, lsl 24
	add	pcff, 0x00020000
	add	lr, 0x00010000
	pkhtb	hlmp, hlmp, lr, asr 16
	PREFIX0

ldnna:	TIME	13
	ldr	lr, [mem, pcff, lsr 16]
	mov	lr, lr, lsl 16
	mov	r11, arvpref, lsr 24
	strb	r11, [mem, lr, lsr 16]
	add	pcff, 0x00020000
	add	lr, 0x00010000
	and	lr, 0x00ff0000
	orr	lr, r11, lsl 24
	pkhtb	hlmp, hlmp, lr, asr 16
	PREFIX0

ldbc:	LDXX	bcfb, 8, bcfb, 0
ldbd:	LDXX	bcfb, 8, defr, 8
ldbe:	LDXX	bcfb, 8, defr, 0
      if fast = 0
lxbh:	movs	lr, arvpref, lsl 24
	beq	ldbh
	bmi	ldbiyh
      end if
ldbixh: LDXX	bcfb, 8, ix, 8
ldbiyh: LDXX	bcfb, 8, iyi, 8
ldbh:	LDXX	bcfb, 8, hlmp, 8

      if fast = 0
lxbl:	movs	lr, arvpref, lsl 24
	beq	ldbl
	bmi	ldbiyl
      end if
ldbixl: LDXX	bcfb, 8, ix, 0
ldbiyl: LDXX	bcfb, 8, iyi, 0
ldbl:	LDXX	bcfb, 8, hlmp, 0

ldba:	LDXX	bcfb, 8, arvpref, 8
ldcb:	LDXX	bcfb, 0, bcfb, 8
ldcd:	LDXX	bcfb, 0, defr, 8
ldce:	LDXX	bcfb, 0, defr, 0

      if fast = 0
lxch:	movs	lr, arvpref, lsl 24
	beq	ldch
	bmi	ldciyh
      end if
ldcixh: LDXX	bcfb, 0, ix, 8
ldciyh: LDXX	bcfb, 0, iyi, 8
ldch:	LDXX	bcfb, 0, hlmp, 8

      if fast = 0
lxcl:	movs	lr, arvpref, lsl 24
	beq	ldcl_
	bmi	ldciyl
      end if
ldcixl: LDXX	bcfb, 0, ix, 0
ldciyl: LDXX	bcfb, 0, iyi, 0
ldcl_:	LDXX	bcfb, 0, hlmp, 0

ldca:	LDXX	bcfb, 0, arvpref, 8
lddb:	LDXX	defr, 8, bcfb, 8
lddc:	LDXX	defr, 8, bcfb, 0
ldde:	LDXX	defr, 8, defr, 0

      if fast = 0
lxdh:	movs	lr, arvpref, lsl 24
	beq	lddh
	bmi	lddiyh
      end if
lddixh: LDXX	defr, 8, ix, 8
lddiyh: LDXX	defr, 8, iyi, 8
lddh:	LDXX	defr, 8, hlmp, 8

      if fast = 0
lxdl:	movs	lr, arvpref, lsl 24
	beq	lddl
	bmi	lddiyl
      end if
lddixl: LDXX	defr, 8, ix, 0
lddiyl: LDXX	defr, 8, iyi, 0
lddl:	LDXX	defr, 8, hlmp, 0

ldda:	LDXX	defr, 8, arvpref, 8
ldeb:	LDXX	defr, 0, bcfb, 8
ldec:	LDXX	defr, 0, bcfb, 0
lded:	LDXX	defr, 0, defr, 8

      if fast = 0
lxeh:	movs	lr, arvpref, lsl 24
	beq	ldeh
	bmi	ldeiyh
      end if
ldeixh: LDXX	defr, 0, ix, 8
ldeiyh: LDXX	defr, 0, iyi, 8
ldeh:	LDXX	defr, 0, hlmp, 8

      if fast = 0
lxel:	movs	lr, arvpref, lsl 24
	beq	ldel
	bmi	ldeiyl
      end if
ldeixl: LDXX	defr, 0, ix, 0
ldeiyl: LDXX	defr, 0, iyi, 0
ldel:	LDXX	defr, 0, hlmp, 0

ldea:	LDXX	defr, 0, arvpref, 8

      if fast = 0
lxhb:	movs	lr, arvpref, lsl 24
	beq	ldhb
	bmi	ldiyhb
      end if
ldixhb: LDXX	ix, 8, bcfb, 8
ldiyhb: LDXX	iyi, 8, bcfb, 8
ldhb:	LDXX	hlmp, 8, bcfb, 8

      if fast = 0
lxhc:	movs	lr, arvpref, lsl 24
	beq	ldhc
	bmi	ldiyhc
      end if
ldixhc: LDXX	ix, 8, bcfb, 0
ldiyhc: LDXX	iyi, 8, bcfb, 0
ldhc:	LDXX	hlmp, 8, bcfb, 0

      if fast = 0
lxhd:	movs	lr, arvpref, lsl 24
	beq	ldhd
	bmi	ldiyhd
      end if
ldixhd: LDXX	ix, 8, defr, 8
ldiyhd: LDXX	iyi, 8, defr, 8
ldhd:	LDXX	hlmp, 8, defr, 8

      if fast = 0
lxhe:	movs	lr, arvpref, lsl 24
	beq	ldhe
	bmi	ldiyhe
      end if
ldixhe: LDXX	ix, 8, defr, 0
ldiyhe: LDXX	iyi, 8, defr, 0
ldhe:	LDXX	hlmp, 8, defr, 0

      if fast = 0
lxhl:	movs	lr, arvpref, lsl 24
	beq	ldhl
	bmi	ldyhyl
      end if
ldxhxl: LDXX	ix, 8, ix, 0
ldyhyl: LDXX	iyi, 8, iyi, 0
ldhl:	LDXX	hlmp, 8, hlmp, 0

      if fast = 0
lxha:	movs	lr, arvpref, lsl 24
	beq	ldha
	bmi	ldiyha
      end if
ldixha: LDXX	ix, 8, arvpref, 8
ldiyha: LDXX	iyi, 8, arvpref, 8
ldha:	LDXX	hlmp, 8, arvpref, 8

      if fast = 0
lxlb:	movs	lr, arvpref, lsl 24
	beq	ldlb
	bmi	ldiylb
      end if
ldixlb: LDXX	ix, 0, bcfb, 8
ldiylb: LDXX	iyi, 0, bcfb, 8
ldlb:	LDXX	hlmp, 0, bcfb, 8

      if fast = 0
lxlc:	movs	lr, arvpref, lsl 24
	beq	ldlc
	bmi	ldiylc
      end if
ldixlc: LDXX	ix, 0, bcfb, 0
ldiylc: LDXX	iyi, 0, bcfb, 0
ldlc:	LDXX	hlmp, 0, bcfb, 0

      if fast = 0
lxld:	movs	lr, arvpref, lsl 24
	beq	ldld
	bmi	ldiyld
      end if
ldixld: LDXX	ix, 0, defr, 8
ldiyld: LDXX	iyi, 0, defr, 8
ldld:	LDXX	hlmp, 0, defr, 8

      if fast = 0
lxle:	movs	lr, arvpref, lsl 24
	beq	ldle
	bmi	ldiyle
      end if
ldixle: LDXX	ix, 0, defr, 0
ldiyle: LDXX	iyi, 0, defr, 0
ldle:	LDXX	hlmp, 0, defr, 0

      if fast = 0
lxlh:	movs	lr, arvpref, lsl 24
	beq	ldlh
	bmi	ldylyh
      end if
ldxlxh: LDXX	ix, 0, ix, 8
ldylyh: LDXX	iyi, 0, iyi, 8
ldlh:	LDXX	hlmp, 0, hlmp, 8

      if fast = 0
lxla:	movs	lr, arvpref, lsl 24
	beq	ldla
	bmi	ldiyla
      end if
ldixla: LDXX	ix, 0, arvpref, 8
ldiyla: LDXX	iyi, 0, arvpref, 8
ldla:	LDXX	hlmp, 0, arvpref, 8

ldab_:	LDXX	arvpref, 8, bcfb, 8
ldac:	LDXX	arvpref, 8, bcfb, 0
ldad:	LDXX	arvpref, 8, defr, 8
ldae:	LDXX	arvpref, 8, defr, 0

      if fast = 0
lxah:	movs	lr, arvpref, lsl 24
	beq	ldah_
	bmi	ldaiyh
      end if
ldaixh: LDXX	arvpref, 8, ix, 8
ldaiyh: LDXX	arvpref, 8, iyi, 8
ldah_:	LDXX	arvpref, 8, hlmp, 8

      if fast = 0
lxal:	movs	lr, arvpref, lsl 24
	beq	ldal
	bmi	ldaiyl
      end if
ldaixl: LDXX	arvpref, 8, ix, 0
ldaiyl: LDXX	arvpref, 8, iyi, 0
ldal:	LDXX	arvpref, 8, hlmp, 0

inca:	INC	arvpref, 8
incb:	INC	bcfb, 8
incc:	INC	bcfb, 0
incd:	INC	defr, 8
ince:	INC	defr, 0

      if fast = 0
inchx:	movs	lr, arvpref, lsl 24
	beq	inch
	bmi	inciyh
      end if
incixh: INC	ix, 8
inciyh: INC	iyi, 8
inch:	INC	hlmp, 8

      if fast = 0
inclx:	movs	lr, arvpref, lsl 24
	beq	incl
	bmi	inciyl
      end if
incixl: INC	ix, 0
inciyl: INC	iyi, 0
incl:	INC	hlmp, 0

      if fast = 0
incpxx: movs	lr, arvpref, lsl 24
	beq	incphl
	ldr	lr, [mem, pcff, lsr 16]
	add	pcff, 0x00010000
	sxtb	lr, lr
	bmi	incpiy
incpix: INCPI	ix
incpiy: INCPI	iyi
      else
incpix: ldr	lr, [mem, pcff, lsr 16]
	add	pcff, 0x00010000
	sxtb	lr, lr
	INCPI	ix
incpiy: ldr	lr, [mem, pcff, lsr 16]
	add	pcff, 0x00010000
	sxtb	lr, lr
	INCPI	iyi
      end if
incphl: TIME	11
	ldrb	lr, [mem, hlmp, lsr 16]
	pkhtb	spfa, spfa, lr
	mov	lr, 0x00000001
	pkhtb	bcfb, bcfb, lr
	add	lr, spfa
	strb	lr, [mem, hlmp, lsr 16]
	uxtb	lr, lr
	pkhtb	defr, defr, lr
	and	r11, pcff, 0x00000100
	orr	lr, r11
	pkhtb	pcff, pcff, lr
	PREFIX0

      if fast = 0
decpxx: movs	lr, arvpref, lsl 24
	beq	decphl
	ldr	lr, [mem, pcff, lsr 16]
	add	pcff, 0x00010000
	sxtb	lr, lr
	bmi	decpiy
decpix: DECPI	ix
decpiy: DECPI	iyi
      else
decpix: ldr	lr, [mem, pcff, lsr 16]
	add	pcff, 0x00010000
	sxtb	lr, lr
	DECPI	ix
decpiy: ldr	lr, [mem, pcff, lsr 16]
	add	pcff, 0x00010000
	sxtb	lr, lr
	DECPI	iyi
      end if
decphl: TIME	11
	ldrb	lr, [mem, hlmp, lsr 16]
	pkhtb	spfa, spfa, lr
	mov	lr, 0xffffffff
	pkhtb	bcfb, bcfb, lr
	add	lr, spfa
	strb	lr, [mem, hlmp, lsr 16]
	uxtb	lr, lr
	pkhtb	defr, defr, lr
	and	r11, pcff, 0x00000100
	orr	lr, r11
	pkhtb	pcff, pcff, lr
	PREFIX0

deca:	DEC	arvpref, 8
decb:	DEC	bcfb, 8
decc:	DEC	bcfb, 0
decd:	DEC	defr, 8
dece:	DEC	defr, 0

      if fast = 0
dechx:	movs	lr, arvpref, lsl 24
	beq	dech
	bmi	deciyh
      end if
decixh: DEC	ix, 8
deciyh: DEC	iyi, 8
dech:	DEC	hlmp, 8

      if fast = 0
declx:	movs	lr, arvpref, lsl 24
	beq	decl
	bmi	deciyl
      end if
decixl: DEC	ix, 0
deciyl: DEC	iyi, 0
decl:	DEC	hlmp, 0

rst00:	RST	0x00
rst08:	RST	0x18
rst10:	RST	0x10
rst18:	RST	0x18
rst20:	RST	0x20
rst28:	RST	0x28
rst30:	RST	0x30
rst38:	RST	0x38

addab:	XADD	bcfb, 8, 4
addac:	XADD	bcfb, 0, 4
addad:	XADD	defr, 8, 4
addae:	XADD	defr, 0, 4

      if fast = 0
addxh:	movs	lr, arvpref, lsl 24
	beq	addah
	bmi	addayh
      end if
addaxh: XADD	ix, 8, 4
addayh: XADD	iyi, 8, 4
addah:	XADD	hlmp, 8, 4

      if fast = 0
addxl:	movs	lr, arvpref, lsl 24
	beq	addal_
	bmi	addayl
      end if
addaxl: XADD	ix, 0, 4
addayl: XADD	iyi, 0, 4
addal_: XADD	hlmp, 0, 4

      if fast = 0
addaxx: movs	lr, arvpref, lsl 24
	beq	addahl
	ldr	lr, [mem, pcff, lsr 16]
	add	pcff, 0x00010000
	sxtb	lr, lr
	bmi	addaiy
addaix: add	lr, ix, lsr 16
	ldrb	lr, [mem, lr]
	XADD	lr, 24, 7
addaiy: add	lr, iyi, lsr 16
	ldrb	lr, [mem, lr]
	XADD	lr, 24, 7
      else
addaix: ldr	lr, [mem, pcff, lsr 16]
	add	pcff, 0x00010000
	sxtb	lr, lr
	add	lr, ix, lsr 16
	ldrb	lr, [mem, lr]
	XADD	lr, 24, 7
addaiy: ldr	lr, [mem, pcff, lsr 16]
	add	pcff, 0x00010000
	sxtb	lr, lr
	add	lr, iyi, lsr 16
	ldrb	lr, [mem, lr]
	XADD	lr, 24, 7
      end if
addahl: ldrb	lr, [mem, hlmp, lsr 16]
	XADD	lr, 24, 7

addan:	ldrb	lr, [mem, pcff, lsr 16]
	add	pcff, 0x00010000
	XADD	lr, 24, 7

addaa:	TIME	4
	mov	lr, arvpref, lsr 24
	pkhtb	spfa, spfa, lr
	pkhtb	bcfb, bcfb, lr
	mov	lr, lr, lsl 1
	pkhtb	pcff, pcff, lr
	uxtb	lr, lr				; important
	bic	arvpref, 0xff000000
	orr	arvpref, lr, lsl 24
	pkhtb	defr, defr, lr
	PREFIX0

adcab:	XADC	bcfb, 8, 4
adcac:	XADC	bcfb, 0, 4
adcad:	XADC	defr, 8, 4
adcae:	XADC	defr, 0, 4

      if fast = 0
adcahx: movs	lr, arvpref, lsl 24
	beq	adcah
	bmi	adcayh
      end if
adcaxh: XADC	ix, 8, 4
adcayh: XADC	iyi, 8, 4
adcah:	XADC	hlmp, 8, 4

      if fast = 0
adcalx: movs	lr, arvpref, lsl 24
	beq	adcal_
	bmi	adcayl
      end if
adcaxl: XADC	ix, 0, 4
adcayl: XADC	iyi, 0, 4
adcal_: XADC	hlmp, 0, 4

      if fast = 0
adcaxx: movs	lr, arvpref, lsl 24
	beq	adcahl
	ldr	lr, [mem, pcff, lsr 16]
	add	pcff, 0x00010000
	sxtb	lr, lr
	bmi	adcaiy
adcaix: add	lr, ix, lsr 16
	ldrb	lr, [mem, lr]
	XADC	lr, 24, 7
adcaiy: add	lr, iyi, lsr 16
	ldrb	lr, [mem, lr]
	XADC	lr, 24, 7
      else
adcaix: ldr	lr, [mem, pcff, lsr 16]
	add	pcff, 0x00010000
	sxtb	lr, lr
	add	lr, ix, lsr 16
	ldrb	lr, [mem, lr]
	XADC	lr, 24, 7
adcaiy: ldr	lr, [mem, pcff, lsr 16]
	add	pcff, 0x00010000
	sxtb	lr, lr
	add	lr, iyi, lsr 16
	ldrb	lr, [mem, lr]
	XADC	lr, 24, 7
      end if
adcahl: ldrb	lr, [mem, hlmp, lsr 16]
	XADC	lr, 24, 7

adcan:	ldrb	lr, [mem, pcff, lsr 16]
	add	pcff, 0x00010000
	XADC	lr, 24, 7

adcaa:	TIME	4
	mov	lr, arvpref, lsr 24
	pkhtb	spfa, spfa, lr
	pkhtb	bcfb, bcfb, lr
	movs	r11, pcff, lsr 9
	adc	lr, lr, lr
	pkhtb	pcff, pcff, lr
	uxtb	lr, lr				; important
	bic	arvpref, 0xff000000
	orr	arvpref, lr, lsl 24
	pkhtb	defr, defr, lr
	PREFIX0

subb:	XSUB	bcfb, 8, 4
subc:	XSUB	bcfb, 0, 4
subd:	XSUB	defr, 8, 4
sube:	XSUB	defr, 0, 4

      if fast = 0
subhx:	movs	lr, arvpref, lsl 24
	beq	subh
	bmi	subyh
      end if
subxh:	XSUB	ix, 8, 4
subyh:	XSUB	iyi, 8, 4
subh:	XSUB	hlmp, 8, 4

      if fast = 0
sublx:	movs	lr, arvpref, lsl 24
	beq	subl
	bmi	subyl
      end if
subxl:	XSUB	ix, 0, 4
subyl:	XSUB	iyi, 0, 4
subl:	XSUB	hlmp, 0, 4

      if fast = 0
subxx:	movs	lr, arvpref, lsl 24
	beq	subhl
	ldr	lr, [mem, pcff, lsr 16]
	add	pcff, 0x00010000
	sxtb	lr, lr
	bmi	subiy
subix:	add	lr, ix, lsr 16
	ldrb	lr, [mem, lr]
	XSUB	lr, 24, 7
subiy:	add	lr, iyi, lsr 16
	ldrb	lr, [mem, lr]
	XSUB	lr, 24, 7
      else
subix:	ldr	lr, [mem, pcff, lsr 16]
	add	pcff, 0x00010000
	sxtb	lr, lr
	add	lr, ix, lsr 16
	ldrb	lr, [mem, lr]
	XSUB	lr, 24, 7
subiy:	ldr	lr, [mem, pcff, lsr 16]
	add	pcff, 0x00010000
	sxtb	lr, lr
	add	lr, iyi, lsr 16
	ldrb	lr, [mem, lr]
	XSUB	lr, 24, 7
      end if
subhl:	ldrb	lr, [mem, hlmp, lsr 16]
	XSUB	lr, 24, 7

subn:	ldrb	lr, [mem, pcff, lsr 16]
	add	pcff, 0x00010000
	XSUB	lr, 24, 7

suba:	TIME	4
	mov	lr, arvpref, lsr 24
	pkhtb	spfa, spfa, lr
	mvn	r11, lr
	pkhtb	bcfb, bcfb, r11
	bic	arvpref, 0xff000000
	pkhtb	pcff, pcff, lr, asr 16
	pkhtb	defr, defr, lr, asr 16
	PREFIX0

sbcab:	XSBC	bcfb, 8, 4
sbcac:	XSBC	bcfb, 0, 4
sbcad:	XSBC	defr, 8, 4
sbcae:	XSBC	defr, 0, 4

      if fast = 0
sbcahx: movs	lr, arvpref, lsl 24
	beq	sbcah
	bmi	sbcayh
      end if
sbcaxh: XSBC	ix, 8, 4
sbcayh: XSBC	iyi, 8, 4
sbcah:	XSBC	hlmp, 8, 4

      if fast = 0
sbcalx: movs	lr, arvpref, lsl 24
	beq	sbcal_
	bmi	sbcayl
      end if
sbcaxl: XSBC	ix, 0, 4
sbcayl: XSBC	iyi, 0, 4
sbcal_: XSBC	hlmp, 0, 4

      if fast = 0
sbcaxx: movs	lr, arvpref, lsl 24
	beq	sbcahl
	ldr	lr, [mem, pcff, lsr 16]
	add	pcff, 0x00010000
	sxtb	lr, lr
	bmi	sbcaiy
sbcaix: add	lr, ix, lsr 16
	ldrb	lr, [mem, lr]
	XSBC	lr, 24, 7
sbcaiy: add	lr, iyi, lsr 16
	ldrb	lr, [mem, lr]
	XSBC	lr, 24, 7
      else
sbcaix: ldr	lr, [mem, pcff, lsr 16]
	add	pcff, 0x00010000
	sxtb	lr, lr
	add	lr, ix, lsr 16
	ldrb	lr, [mem, lr]
	XSBC	lr, 24, 7
sbcaiy: ldr	lr, [mem, pcff, lsr 16]
	add	pcff, 0x00010000
	sxtb	lr, lr
	add	lr, iyi, lsr 16
	ldrb	lr, [mem, lr]
	XSBC	lr, 24, 7
      end if
sbcahl: ldrb	lr, [mem, hlmp, lsr 16]
	XSBC	lr, 24, 7

sbcan:	ldrb	lr, [mem, pcff, lsr 16]
	add	pcff, 0x00010000
	XSBC	lr, 24, 7

sbcaa:	TIME	4
	mov	lr, arvpref, lsr 24
	pkhtb	spfa, spfa, lr
	mvn	r11, lr
	pkhtb	bcfb, bcfb, r11
	eor	lr, pcff, 0x00000100
	movs	lr, lr, lsl 24
	sbc	lr, lr
	pkhtb	pcff, pcff, lr
	bic	arvpref, 0xff000000
	orr	arvpref, lr, lsl 24
	pkhtb	defr, defr, lr
	PREFIX0

andb:	XAND	bcfb, 8, 4
andc:	XAND	bcfb, 0, 4
andd:	XAND	defr, 8, 4
ande:	XAND	defr, 0, 4

      if fast = 0
andhx:	movs	lr, arvpref, lsl 24
	beq	andh
	bmi	andyh
      end if
andxh:	XAND	ix, 8, 4
andyh:	XAND	iyi, 8, 4
andh:	XAND	hlmp, 8, 4

      if fast = 0
andlx:	movs	lr, arvpref, lsl 24
	beq	andl
	bmi	andyl
      end if
andxl:	XAND	ix, 0, 4
andyl:	XAND	iyi, 0, 4
andl:	XAND	hlmp, 0, 4

      if fast = 0
andxx:	movs	lr, arvpref, lsl 24
	beq	andhl
	ldr	lr, [mem, pcff, lsr 16]
	add	pcff, 0x00010000
	sxtb	lr, lr
	bmi	andiy
andix:	add	lr, ix, lsr 16
	ldrb	lr, [mem, lr]
	XAND	lr, 24, 7
andiy:	add	lr, iyi, lsr 16
	ldrb	lr, [mem, lr]
	XAND	lr, 24, 7
      else
andix:	ldr	lr, [mem, pcff, lsr 16]
	add	pcff, 0x00010000
	sxtb	lr, lr
	add	lr, ix, lsr 16
	ldrb	lr, [mem, lr]
	XAND	lr, 24, 7
andiy:	ldr	lr, [mem, pcff, lsr 16]
	add	pcff, 0x00010000
	sxtb	lr, lr
	add	lr, iyi, lsr 16
	ldrb	lr, [mem, lr]
	XAND	lr, 24, 7
      end if
andhl:	ldrb	lr, [mem, hlmp, lsr 16]
	XAND	lr, 24, 7

andan:	ldrb	lr, [mem, pcff, lsr 16]
	add	pcff, 0x00010000
	XAND	lr, 24, 7

anda:	TIME	4
	mov	lr, arvpref, lsr 24
	pkhtb	bcfb, bcfb, lr, asr 16
	pkhtb	defr, defr, lr
	pkhtb	pcff, pcff, lr
	mvn	lr, lr
	pkhtb	spfa, spfa, lr
	PREFIX0

xorb:	XOR	bcfb, 8, 4
xorc:	XOR	bcfb, 0, 4
xord:	XOR	defr, 8, 4
xore:	XOR	defr, 0, 4

      if fast = 0
xorhx:	movs	lr, arvpref, lsl 24
	beq	xorh
	bmi	xoryh
      end if
xorxh:	XOR	ix, 8, 4
xoryh:	XOR	iyi, 8, 4
xorh:	XOR	hlmp, 8, 4

      if fast = 0
xorlx:	movs	lr, arvpref, lsl 24
	beq	xorl
	bmi	xoryl
      end if
xorxl:	XOR	ix, 0, 4
xoryl:	XOR	iyi, 0, 4
xorl:	XOR	hlmp, 0, 4

      if fast = 0
xorxx:	movs	lr, arvpref, lsl 24
	beq	xorhl
	ldr	lr, [mem, pcff, lsr 16]
	add	pcff, 0x00010000
	sxtb	lr, lr
	bmi	xoriy
xorix:	add	lr, ix, lsr 16
	ldrb	lr, [mem, lr]
	XOR	lr, 24, 7
xoriy:	add	lr, iyi, lsr 16
	ldrb	lr, [mem, lr]
	XOR	lr, 24, 7
      else
xorix:	ldr	lr, [mem, pcff, lsr 16]
	add	pcff, 0x00010000
	sxtb	lr, lr
	add	lr, ix, lsr 16
	ldrb	lr, [mem, lr]
	XOR	lr, 24, 7
xoriy:	ldr	lr, [mem, pcff, lsr 16]
	add	pcff, 0x00010000
	sxtb	lr, lr
	add	lr, iyi, lsr 16
	ldrb	lr, [mem, lr]
	XOR	lr, 24, 7
      end if
xorhl:	ldrb	lr, [mem, hlmp, lsr 16]
	XOR	lr, 24, 7

xoran:	ldrb	lr, [mem, pcff, lsr 16]
	add	pcff, 0x00010000
	XOR	lr, 24, 7

xora:	TIME	4
	mov	lr, 0x00000100
	pkhtb	bcfb, bcfb, lr, asr 16
	pkhtb	defr, defr, lr, asr 16
	pkhtb	pcff, pcff, lr, asr 16
	bic	arvpref, 0xff000000
	pkhtb	spfa, spfa, lr
	PREFIX0

orb:	OR	bcfb, 8, 4
orc:	OR	bcfb, 0, 4
ord:	OR	defr, 8, 4
ore:	OR	defr, 0, 4

      if fast = 0
orhx:	movs	lr, arvpref, lsl 24
	beq	orh
	bmi	oryh
      end if
orxh:	OR	ix, 8, 4
oryh:	OR	iyi, 8, 4
orh:	OR	hlmp, 8, 4

      if fast = 0
orlx:	movs	lr, arvpref, lsl 24
	beq	orl
	bmi	oryl
      end if
orxl:	OR	ix, 0, 4
oryl:	OR	iyi, 0, 4
orl:	OR	hlmp, 0, 4

      if fast = 0
orxx:	movs	lr, arvpref, lsl 24
	beq	orhl
	ldr	lr, [mem, pcff, lsr 16]
	add	pcff, 0x00010000
	sxtb	lr, lr
	bmi	oriy
orix:	add	lr, ix, lsr 16
	ldrb	lr, [mem, lr]
	OR	lr, 24, 7
oriy:	add	lr, iyi, lsr 16
	ldrb	lr, [mem, lr]
	OR	lr, 24, 7
      else
orix:	ldr	lr, [mem, pcff, lsr 16]
	add	pcff, 0x00010000
	sxtb	lr, lr
	add	lr, ix, lsr 16
	ldrb	lr, [mem, lr]
	OR	lr, 24, 7
oriy:	ldr	lr, [mem, pcff, lsr 16]
	add	pcff, 0x00010000
	sxtb	lr, lr
	add	lr, iyi, lsr 16
	ldrb	lr, [mem, lr]
	OR	lr, 24, 7
      end if
orhl:	ldrb	lr, [mem, hlmp, lsr 16]
	OR	lr, 24, 7

oran:	ldrb	lr, [mem, pcff, lsr 16]
	add	pcff, 0x00010000
	OR	lr, 24, 7

ora:	TIME	4
	mov	lr, arvpref, lsr 24
	pkhtb	defr, defr, lr
	pkhtb	pcff, pcff, lr
	add	lr, 0x00000100
	pkhtb	spfa, spfa, lr
	pkhtb	bcfb, bcfb, lr, asr 16
	PREFIX0

cpb:	CP	bcfb, 8, 4
cpc:	CP	bcfb, 0, 4
cp_d:	CP	defr, 8, 4
cpe:	CP	defr, 0, 4

      if fast = 0
cphx:	movs	lr, arvpref, lsl 24
	beq	cph
	bmi	cpyh
      end if
cpxh:	CP	ix, 8, 4
cpyh:	CP	iyi, 8, 4
cph:	CP	hlmp, 8, 4

      if fast = 0
cplx:	movs	lr, arvpref, lsl 24
	beq	cp_l
	bmi	cpyl
      end if
cpxl:	CP	ix, 0, 4
cpyl:	CP	iyi, 0, 4
cp_l:	CP	hlmp, 0, 4

cpan:	ldrb	lr, [mem, pcff, lsr 16]
	add	pcff, 0x00010000
	CP	lr, 24, 7

      if fast = 0
cpxx:	movs	lr, arvpref, lsl 24
	beq	cphl
	ldr	lr, [mem, pcff, lsr 16]
	add	pcff, 0x00010000
	sxtb	lr, lr
	bmi	cpiy
cpix:	add	lr, ix, lsr 16
	ldrb	lr, [mem, lr]
	CP	lr, 24, 7
cpiy:	add	lr, iyi, lsr 16
	ldrb	lr, [mem, lr]
	CP	lr, 24, 7
      else
cpix:	ldr	lr, [mem, pcff, lsr 16]
	add	pcff, 0x00010000
	sxtb	lr, lr
	add	lr, ix, lsr 16
	ldrb	lr, [mem, lr]
	CP	lr, 24, 7
cpiy:	ldr	lr, [mem, pcff, lsr 16]
	add	pcff, 0x00010000
	sxtb	lr, lr
	add	lr, iyi, lsr 16
	ldrb	lr, [mem, lr]
	CP	lr, 24, 7
      end if
cphl:	ldrb	lr, [mem, hlmp, lsr 16]
	CP	lr, 24, 7

cpa:	TIME	4
	mov	lr, arvpref, lsr 24
	pkhtb	defr, defr, lr, asr 16
	pkhtb	spfa, spfa, lr
	mvn	r11, lr
	pkhtb	bcfb, bcfb, r11
	and	lr, 0x00000028
	pkhtb	pcff, pcff, lr
	PREFIX0

scf:	TIME	4
	and	lr, bcfb, 0x00000080
	eor	r11, defr, spfa
	and	r11, 0x00000010
	orr	lr, r11
	pkhtb	bcfb, bcfb, lr
	and	lr, arvpref, 0x28000000
	and	r11, pcff, 0x00000080
	orr	r11, lr, lsr 24
	orr	r11, 0x00000100
	pkhtb	pcff, pcff, r11
	PREFIX0

ccf:	TIME	4
	and	lr, bcfb, 0x00000080
	eor	r11, defr, spfa
	eor	r11, pcff, lsr 4
	and	r11, 0x00000010
	orr	lr, r11
	pkhtb	bcfb, bcfb, lr
	and	lr, arvpref, 0x28000000
	and	r11, pcff, 0x00000180
	orr	r11, lr, lsr 24
	eor	r11, 0x00000100
	pkhtb	pcff, pcff, r11
	PREFIX0

      if fast = 0
lxbhl:	movs	lr, arvpref, lsl 24
	beq	ldbhl
	bmi	ldbiy
      end if
ldbix:	LDRPI	ix, bcfb, 8
ldbiy:	LDRPI	iyi, bcfb, 8
ldbhl:	LDRP	hlmp, bcfb, 8

      if fast = 0
lxchl:	movs	lr, arvpref, lsl 24
	beq	ldchl
	bmi	ldciy
      end if
ldcix:	LDRPI	ix, bcfb, 0
ldciy:	LDRPI	iyi, bcfb, 0
ldchl:	LDRP	hlmp, bcfb, 0

      if fast = 0
lxdhl:	movs	lr, arvpref, lsl 24
	beq	lddhl
	bmi	lddiy
      end if
lddix:	LDRPI	ix, defr, 8
lddiy:	LDRPI	iyi, defr, 8
lddhl:	LDRP	hlmp, defr, 8

      if fast = 0
lxehl:	movs	lr, arvpref, lsl 24
	beq	ldehl
	bmi	ldeiy
      end if
ldeix:	LDRPI	ix, defr, 0
ldeiy:	LDRPI	iyi, defr, 0
ldehl:	LDRP	hlmp, defr, 0

      if fast = 0
lxhhl:	movs	lr, arvpref, lsl 24
	beq	ldhhl
	bmi	ldhiy
      end if
ldhix:	LDRPI	ix, hlmp, 8
ldhiy:	LDRPI	iyi, hlmp, 8
ldhhl:	LDRP	hlmp, hlmp, 8

      if fast = 0
lxlhl:	movs	lr, arvpref, lsl 24
	beq	ldlhl
	bmi	ldliy
      end if
ldlix:	LDRPI	ix, hlmp, 0
ldliy:	LDRPI	iyi, hlmp, 0
ldlhl:	LDRP	hlmp, hlmp, 0

      if fast = 0
lxahl:	movs	lr, arvpref, lsl 24
	beq	ldahl
	bmi	ldaiy
      end if
ldaix:	LDRPI	ix, arvpref, 8
ldaiy:	LDRPI	iyi, arvpref, 8
ldahl:	LDRP	hlmp, arvpref, 8

ldabc:	LDRP	bcfb, arvpref, 8
ldade:	LDRP	defr, arvpref, 8

ldbca:	LDPR	bcfb, arvpref, 8
lddea:	LDPR	defr, arvpref, 8

      if fast = 0
ldxxb:	movs	lr, arvpref, lsl 24
	beq	ldhlb
	bmi	ldiyb
      end if
ldixb:	LDPRI	ix, bcfb, 8
ldiyb:	LDPRI	iyi, bcfb, 8
ldhlb:	LDPR	hlmp, bcfb, 8

      if fast = 0
ldxxc:	movs	lr, arvpref, lsl 24
	beq	ldhlc
	bmi	ldiyc
      end if
ldixc:	LDPRI	ix, bcfb, 0
ldiyc:	LDPRI	iyi, bcfb, 0
ldhlc:	LDPR	hlmp, bcfb, 0

      if fast = 0
ldxxd:	movs	lr, arvpref, lsl 24
	beq	ldhld
	bmi	ldiyd
      end if
ldixd:	LDPRI	ix, defr, 8
ldiyd:	LDPRI	iyi, defr, 8
ldhld:	LDPR	hlmp, defr, 8

      if fast = 0
ldxxe:	movs	lr, arvpref, lsl 24
	beq	ldhle
	bmi	ldiye
      end if
ldixe:	LDPRI	ix, defr, 0
ldiye:	LDPRI	iyi, defr, 0
ldhle:	LDPR	hlmp, defr, 0

      if fast = 0
ldxxh:	movs	lr, arvpref, lsl 24
	beq	ldhlh
	bmi	ldiyh
      end if
ldixh:	LDPRI	ix, hlmp, 8
ldiyh:	LDPRI	iyi, hlmp, 8
ldhlh:	LDPR	hlmp, hlmp, 8

      if fast = 0
ldxxl:	movs	lr, arvpref, lsl 24
	beq	ldhll
	bmi	ldiyl
      end if
ldixl:	LDPRI	ix, hlmp, 0
ldiyl:	LDPRI	iyi, hlmp, 0
ldhll:	LDPR	hlmp, hlmp, 0

halt:	TIME	4
	orr	arvpref, 0x00000800
	sub	pcff, 0x00010000
	PREFIX0

      if fast = 0
ldxxa:	movs	lr, arvpref, lsl 24
	beq	ldhla
	bmi	ldiya
      end if
ldixa:	LDPRI	ix, arvpref, 8
ldiya:	LDPRI	iyi, arvpref, 8
ldhla:	LDPR	hlmp, arvpref, 8

incbc:	INCW	bcfb
incde:	INCW	defr
incsp:	INCW	spfa

      if fast = 0
inchlx: movs	lr, arvpref, lsl 24
	beq	inchl
	bmi	inciy
      end if
incix:	INCW	ix
inciy:	INCW	iyi
inchl:	INCW	hlmp

decbc:	DECW	bcfb
decde:	DECW	defr
decsp:	DECW	spfa

      if fast = 0
dechlx: movs	lr, arvpref, lsl 24
	beq	dechl
	bmi	deciy
      end if
decix:	DECW	ix
deciy:	DECW	iyi
dechl:	DECW	hlmp

pushaf: and	lr, arvpref, 0xff000000
	and	r11, pcff, 0x000000a8
	orr	r11, lr, r11, lsl 16
	movs	lr, pcff, lsr 9
	orrcs	r11, 0x00010000
	movs	lr, bcfb, lsr 10
	orrcs	r11, 0x00020000
	movs	lr, defr, lsl 16
	orreq	r11, 0x00400000
	eor	lr, defr, spfa
	eor	r10, bcfb, bcfb, lsr 8
	eor	lr, r10
	movs	lr, lr, lsr 5
	orrcs	r11, 0x00100000
	tst	spfa, 0x00000100
	beq	over5
	ldr	lr, [cb34]
	eor	r10, defr, defr, lsr 4
	tst	lr, lr, ror r10
	orrmi	r11, 0x00040000
	PUS	r11
over5:	eor	lr, spfa, defr
	eor	r10, bcfb, defr
	and	lr, r10
	movs	lr, lr, lsr 8
	orrcs	r11, 0x00040000
	PUS	r11

pushbc: PUS	bcfb
pushde: PUS	defr

      if fast = 0
pushxx: movs	lr, arvpref, lsl 24
	beq	pushhl
	bmi	pushiy
      end if
pushix: PUS	ix
pushiy: PUS	iyi
pushhl: PUS	hlmp

popaf:	TIME	10
	ldr	lr, [mem, spfa, lsr 16]
	add	spfa, 0x00020000
	rev16	lr, lr
	bic	arvpref, 0xff000000
	orr	arvpref, lr, lsl 24
	uxtb	lr, lr, ror 8
	mvn	r11, lr
	and	r11, 0x00000040
	pkhtb	defr, defr, r11
	orr	lr, lr, lr, lsl 8
	pkhtb	pcff, pcff, lr
	and	r11, lr, 0x00000004
	eor	lr, r11, lsl 5
	and	lr, 0xffffff7f
	eor	lr, r11, lsl 5
	pkhtb	bcfb, bcfb, lr
	uxtb	lr, lr
	pkhtb	spfa, spfa, lr
	PREFIX0

popbc:	POPP	bcfb
	PREFIX0

popde:	POPP	defr
	PREFIX0

      if fast = 0
popxx:	movs	lr, arvpref, lsl 24
	beq	pophl
	bmi	popiy
      end if
popix:	POPP	ix
	PREFIX0
popiy:	POPP	iyi
	PREFIX0
pophl:	POPP	hlmp
	PREFIX0

      if fast = 0
exspxx: movs	lr, arvpref, lsl 24
	beq	exsphl
	bmi	exspiy
      end if
exspix: EXSPI	ix
	PREFIX0
exspiy: EXSPI	iyi
	PREFIX0
exsphl: EXSPI	hlmp
	PREFIX0

exafaf: TIME	4
	mov	lr, arvpref, lsr 24
	add	r11, mem, oa_
	swpb	lr, lr, [r11]
	bic	arvpref, 0xff000000
	orr	arvpref, lr, lsl 24
	pkhbt	r11, spfa, bcfb, lsl 16
	add	lr, mem, ofa_
	swp	r11, r11, [lr]
	pkhtb	spfa, spfa, r11
	pkhtb	bcfb, bcfb, r11, asr 16
	pkhbt	r11, pcff, defr, lsl 16
	add	lr, mem, off_
	swp	r11, r11, [lr]
	pkhtb	pcff, pcff, r11
	pkhtb	defr, defr, r11, asr 16
	PREFIX0

exdehl: TIME	4
	mov	lr, hlmp
	pkhbt	hlmp, hlmp, defr
	pkhbt	defr, defr, lr
	PREFIX0

exx:	TIME	4
	pkhtb	r10, defr, bcfb, asr 16
	add	lr, mem, oc_
	swp	r10, r10, [lr]
	pkhtb	defr, r10, defr
	pkhbt	bcfb, bcfb, r10, lsl 16
	add	lr, 4
	swp	r10, hlmp, [lr]
	pkhbt	hlmp, hlmp, r10
	PREFIX0

callpo: tst	spfa, 0x00000100
	beq	over1
	ldr	r11, [cb34]
	eor	lr, defr, defr, lsr 4
	tst	r11, r11, ror lr
	bmi	callnn
	TIME	10
	add	pcff, 0x00020000
	PREFIX0
over1:	eor	lr, spfa, defr
	eor	r11, bcfb, defr
	and	lr, r11
	tst	lr, 0x80
	CALLC

callpe: tst	spfa, 0x00000100
	beq	over2
	ldr	r11, [cb34]
	eor	lr, defr, defr, lsr 4
	tst	r11, r11, ror lr
	bpl	callnn
	TIME	10
	add	pcff, 0x00020000
	PREFIX0
over2:	eor	lr, spfa, defr
	eor	r11, bcfb, defr
	and	lr, r11
	tst	lr, 0x80
	CALLCI

retpo:	tst	spfa, 0x00000100
	beq	over3
	ldr	r11, [cb34]
	eor	lr, defr, defr, lsr 4
	tst	r11, r11, ror lr
	bmi	ret11
	TIME	5
	PREFIX0
over3:	eor	lr, spfa, defr
	eor	r11, bcfb, defr
	and	lr, r11
	tst	lr, 0x80
	RETC

retpe:	tst	spfa, 0x00000100
	beq	over4
	ldr	r11, [cb34]
	eor	lr, defr, defr, lsr 4
	tst	r11, r11, ror lr
	bpl	ret11
	TIME	5
	PREFIX0
over4:	eor	lr, spfa, defr
	eor	r11, bcfb, defr
	and	lr, r11
	tst	lr, 0x80
	RETCI

jppo:	tst	spfa, 0x00000100
	beq	over6
	ldr	r11, [cb34]
	eor	lr, defr, defr, lsr 4
	tst	r11, r11, ror lr
	bmi	jpnn
	TIME	10
	add	pcff, 0x00020000
	PREFIX0
over6:	eor	lr, spfa, defr
	eor	r11, bcfb, defr
	and	lr, r11
	tst	lr, 0x80
	JPC

jppe:	tst	spfa, 0x00000100
	beq	over7
	ldr	r11, [cb34]
	eor	lr, defr, defr, lsr 4
	tst	r11, r11, ror lr
	bpl	jpnn
	TIME	10
	add	pcff, 0x00020000
	PREFIX0
over7:	eor	lr, spfa, defr
	eor	r11, bcfb, defr
	and	lr, r11
	tst	lr, 0x80
	JPCI

oped:	mov	lr, 0x00010000
	uadd8	arvpref, arvpref, lr
	bic	arvpref, 0xff
	ldrb	lr, [mem, pcff, lsr 16]
	add	pcff, 0x00010000
	ldr	pc, [pc, lr, lsl 2]
cb34:	dw	0xcb34cb34
	dw	nop8			; 00 NOP8
	dw	nop8			; 01 NOP8
	dw	nop8			; 02 NOP8
	dw	nop8			; 03 NOP8
	dw	nop8			; 04 NOP8
	dw	nop8			; 05 NOP8
	dw	nop8			; 06 NOP8
	dw	nop8			; 07 NOP8
	dw	nop8			; 08 NOP8
	dw	nop8			; 09 NOP8
	dw	nop8			; 0a NOP8
	dw	nop8			; 0b NOP8
	dw	nop8			; 0c NOP8
	dw	nop8			; 0d NOP8
	dw	nop8			; 0e NOP8
	dw	nop8			; 0f NOP8
	dw	nop8			; 10 NOP8
	dw	nop8			; 11 NOP8
	dw	nop8			; 12 NOP8
	dw	nop8			; 13 NOP8
	dw	nop8			; 14 NOP8
	dw	nop8			; 15 NOP8
	dw	nop8			; 16 NOP8
	dw	nop8			; 17 NOP8
	dw	nop8			; 18 NOP8
	dw	nop8			; 19 NOP8
	dw	nop8			; 1a NOP8
	dw	nop8			; 1b NOP8
	dw	nop8			; 1c NOP8
	dw	nop8			; 1d NOP8
	dw	nop8			; 1e NOP8
	dw	nop8			; 1f NOP8
	dw	nop8			; 20 NOP8
	dw	nop8			; 21 NOP8
	dw	nop8			; 22 NOP8
	dw	nop8			; 23 NOP8
	dw	nop8			; 24 NOP8
	dw	nop8			; 25 NOP8
	dw	nop8			; 26 NOP8
	dw	nop8			; 27 NOP8
	dw	nop8			; 28 NOP8
	dw	nop8			; 29 NOP8
	dw	nop8			; 2a NOP8
	dw	nop8			; 2b NOP8
	dw	nop8			; 2c NOP8
	dw	nop8			; 2d NOP8
	dw	nop8			; 2e NOP8
	dw	nop8			; 2f NOP8
	dw	nop8			; 30 NOP8
	dw	nop8			; 31 NOP8
	dw	nop8			; 32 NOP8
	dw	nop8			; 33 NOP8
	dw	nop8			; 34 NOP8
	dw	nop8			; 35 NOP8
	dw	nop8			; 36 NOP8
	dw	nop8			; 37 NOP8
	dw	nop8			; 38 NOP8
	dw	nop8			; 39 NOP8
	dw	nop8			; 3a NOP8
	dw	nop8			; 3b NOP8
	dw	nop8			; 3c NOP8
	dw	nop8			; 3d NOP8
	dw	nop8			; 3e NOP8
	dw	nop8			; 3f NOP8
	dw	inbc			; 40 IN B,(C)
	dw	outcb			; 41 OUT (C),B
	dw	sbchlbc			; 42 SBC HL,BC
	dw	ldpnnbc			; 43 LD (NN),BC
	dw	neg_			; 44 NEG
	dw	ret14			; 45 RETN
	dw	im0			; 46 IM 0
	dw	ldia			; 47 LD I,A
	dw	in_cc			; 48 IN C,(C)
	dw	outcc			; 49 OUT (C),C
	dw	adchlbc			; 4a ADC HL,BC
	dw	ldbcpnn			; 4b LD BC,(NN)
	dw	neg_			; 4c NEG
	dw	ret14			; 4d RETI
	dw	im0			; 4e IM 0
	dw	ldra			; 4f LD R,A
	dw	indc			; 50 IN D,(C)
	dw	outcd			; 51 OUT (C),D
	dw	sbchlde			; 52 SBC HL,DE
	dw	ldpnnde			; 53 LD (NN),DE
	dw	neg_			; 54 NEG
	dw	ret14			; 55 RETN
	dw	im1			; 56 IM 1
	dw	ldai			; 57 LD A,I
	dw	inec			; 58 IN E,(C)
	dw	outce			; 59 OUT (C),E
	dw	adchlde			; 5a ADC HL,DE
	dw	lddepnn			; 5b LD DE,(NN)
	dw	neg_			; 5c NEG
	dw	ret14			; 5d RETI
	dw	im2			; 5e IM 2
	dw	ldar_			; 5f LD A,R
	dw	inhc			; 60 IN H,(C)
	dw	outch			; 61 OUT (C),H
	dw	sbchlhl			; 62 SBC HL,HL
	dw	ldpnnxe			; 63 LD (NN),HL
	dw	neg_			; 64 NEG
	dw	ret14			; 65 RETN
	dw	im0			; 66 IM 0
	dw	rrd			; 67 RRD
	dw	inlc			; 68 IN L,(C)
	dw	outcl			; 69 OUT (C),L
	dw	adchlhl			; 6a ADC HL,HL
	dw	ldxepnn			; 6b LD HL,(NN)
	dw	neg_			; 6c NEG
	dw	ret14			; 6d RETI
	dw	im0			; 6e IM 0
	dw	rld			; 6f RLD
	dw	inxc			; 70 IN X,(C)
	dw	outcx			; 71 OUT (C),X
	dw	sbchlsp			; 72 SBC HL,SP
	dw	ldpnnsp			; 73 LD (NN),SP
	dw	neg_			; 74 NEG
	dw	ret14			; 75 RETN
	dw	im1			; 76 IM 1
	dw	nop8			; 77 NOP
	dw	inac			; 78 IN A,(C)
	dw	outca			; 79 OUT (C),A
	dw	adchlsp			; 7a ADC HL,SP
	dw	ldsppnn			; 7b LD SP,(NN)
	dw	neg_			; 7c NEG
	dw	ret14			; 7d RETI
	dw	im2			; 7e IM 2
	dw	nop8			; 7f NOP8
	dw	nop8			; 80 NOP8
	dw	nop8			; 81 NOP8
	dw	nop8			; 82 NOP8
	dw	nop8			; 83 NOP8
	dw	nop8			; 84 NOP8
	dw	nop8			; 85 NOP8
	dw	nop8			; 86 NOP8
	dw	nop8			; 87 NOP8
	dw	nop8			; 88 NOP8
	dw	nop8			; 89 NOP8
	dw	nop8			; 8a NOP8
	dw	nop8			; 8b NOP8
	dw	nop8			; 8c NOP8
	dw	nop8			; 8d NOP8
	dw	nop8			; 8e NOP8
	dw	nop8			; 8f NOP8
	dw	nop8			; 90 NOP8
	dw	nop8			; 91 NOP8
	dw	nop8			; 92 NOP8
	dw	nop8			; 93 NOP8
	dw	nop8			; 94 NOP8
	dw	nop8			; 95 NOP8
	dw	nop8			; 96 NOP8
	dw	nop8			; 97 NOP8
	dw	nop8			; 98 NOP8
	dw	nop8			; 99 NOP8
	dw	nop8			; 9a NOP8
	dw	nop8			; 9b NOP8
	dw	nop8			; 9c NOP8
	dw	nop8			; 9d NOP8
	dw	nop8			; 9e NOP8
	dw	nop8			; 9f NOP8
	dw	ldi			; a0 LDI
	dw	cpi			; a1 CPI
	dw	ini			; a2 INI
	dw	outi			; a3 OUTI
	dw	nop8			; a4 NOP8
	dw	nop8			; a5 NOP8
	dw	nop8			; a6 NOP8
	dw	nop8			; a7 NOP8
	dw	ldd			; a8 LDD
	dw	cpd			; a9 CPD
	dw	ind			; aa IND
	dw	outd			; ab OUTD
	dw	nop8			; ac NOP8
	dw	nop8			; ad NOP8
	dw	nop8			; ae NOP8
	dw	nop8			; af NOP8
	dw	ldir			; b0 LDIR
	dw	cpir			; b1 CPIR
	dw	inir			; b2 INIR
	dw	otir			; b3 OTIR
	dw	nop8			; b4 NOP8
	dw	nop8			; b5 NOP8
	dw	nop8			; b6 NOP8
	dw	nop8			; b7 NOP8
	dw	lddr			; b8 LDDR
	dw	cpdr			; b9 CPDR
	dw	indr			; ba INDR
	dw	otdr			; bb OTDR
	dw	nop8			; bc NOP8
	dw	nop8			; bd NOP8
	dw	nop8			; be NOP8
	dw	nop8			; bf NOP8
	dw	nop8			; c0 NOP8
	dw	nop8			; c1 NOP8
	dw	nop8			; c2 NOP8
	dw	nop8			; c3 NOP8
	dw	nop8			; c4 NOP8
	dw	nop8			; c5 NOP8
	dw	nop8			; c6 NOP8
	dw	nop8			; c7 NOP8
	dw	nop8			; c8 NOP8
	dw	nop8			; c9 NOP8
	dw	nop8			; ca NOP8
	dw	nop8			; cb NOP8
	dw	nop8			; cc NOP8
	dw	nop8			; cd NOP8
	dw	nop8			; ce NOP8
	dw	nop8			; cf NOP8
	dw	nop8			; d0 NOP8
	dw	nop8			; d1 NOP8
	dw	nop8			; d2 NOP8
	dw	nop8			; d3 NOP8
	dw	nop8			; d4 NOP8
	dw	nop8			; d5 NOP8
	dw	nop8			; d6 NOP8
	dw	nop8			; d7 NOP8
	dw	nop8			; d8 NOP8
	dw	nop8			; d9 NOP8
	dw	nop8			; da NOP8
	dw	nop8			; db NOP8
	dw	nop8			; dc NOP8
	dw	nop8			; dd NOP8
	dw	nop8			; de NOP8
	dw	nop8			; df NOP8
	dw	nop8			; e0 NOP8
	dw	nop8			; e1 NOP8
	dw	nop8			; e2 NOP8
	dw	nop8			; e3 NOP8
	dw	nop8			; e4 NOP8
	dw	nop8			; e5 NOP8
	dw	nop8			; e6 NOP8
	dw	nop8			; e7 NOP8
	dw	nop8			; e8 NOP8
	dw	nop8			; e9 NOP8
	dw	nop8			; ea NOP8
	dw	nop8			; eb NOP8
	dw	nop8			; ec NOP8
	dw	nop8			; ed NOP8
	dw	nop8			; ee NOP8
	dw	nop8			; ef NOP8
	dw	nop8			; f0 NOP8
	dw	nop8			; f1 NOP8
	dw	nop8			; f2 NOP8
	dw	nop8			; f3 NOP8
	dw	nop8			; f4 NOP8
	dw	nop8			; f5 NOP8
	dw	nop8			; f6 NOP8
	dw	nop8			; f7 NOP8
	dw	nop8			; f8 NOP8
	dw	nop8			; f9 NOP8
	dw	nop8			; fa NOP8
	dw	nop8			; fb NOP8
	dw	nop8			; fc NOP8
	dw	nop8			; fd NOP8
	dw	nop8			; fe NOP8
	dw	nop8			; ff NOP8
nop8:	TIME	8
	PREFIX0

adchlbc:ADCHLRR bcfb
adchlde:ADCHLRR defr
adchlhl:ADCHLRR hlmp
adchlsp:ADCHLRR spfa

sbchlbc:SBCHLRR bcfb
sbchlde:SBCHLRR defr
sbchlhl:SBCHLRR hlmp
sbchlsp:SBCHLRR spfa

ldi:	TIME	16
	ldrb	lr, [mem, hlmp, lsr 16]
	strb	lr, [mem, defr, lsr 16]
	mov	r11, 0x00010000
	add	hlmp, r11
	add	defr, r11
	sub	bcfb, r11
	movs	r10, defr, lsl 16
	pkhtbne defr, defr, r11, asr 16
	add	lr, arvpref, lsr 24
	and	lr, 00001010b
	add	lr, lr, lsl 4
	eor	lr, pcff
	and	lr, 40
	eor	pcff, lr
	pkhtb	spfa, spfa, lr, asr 8
	movs	lr, bcfb, lsr 16
	eorne	spfa, 0x00000080
	pkhbt	bcfb, spfa, lr, lsl 16
	b	exit

ldd:	TIME	16
	ldrb	lr, [mem, hlmp, lsr 16]
	strb	lr, [mem, defr, lsr 16]
	mov	r11, 0x00010000
	sub	hlmp, r11
	sub	defr, r11
	sub	bcfb, r11
	movs	r10, defr, lsl 16
	pkhtbne defr, defr, r11, asr 16
	add	lr, arvpref, lsr 24
	and	lr, 00001010b
	add	lr, lr, lsl 4
	eor	lr, pcff
	and	lr, 40
	eor	pcff, lr
	pkhtb	spfa, spfa, lr, asr 8
	movs	lr, bcfb, lsr 16
	eorne	spfa, 0x00000080
	pkhbt	bcfb, spfa, lr, lsl 16
	b	exit

cpi:	TIME	16
	ldrb	lr, [mem, hlmp, lsr 16]
	rsb	r11, lr, arvpref, lsr 24
	uxtb	r11, r11
	mov	r10, 0x00000001
	orr	r10, 0x00010000
	uadd16	hlmp, hlmp, r10
	sub	bcfb, 0x00010000
	and	r10, r11, 0x0000007f
	orr	r10, r11, lsr 7
	pkhtb	defr, defr, r10
	orr	r10, lr, 0x00000080
	mvn	r10, r10
	pkhtb	bcfb, bcfb, r10
	mov	r10, arvpref, lsr 24
	and	r10, 0x0000007f
	pkhtb	spfa, spfa, r10
	movs	r10, bcfb, lsr 16
	orrne	bcfb, 0x00000080
	orrne	spfa, 0x00000080
	bic	pcff, 0x000000ff
	and	r10, r11, 0x000000d7
	uxtab	pcff, pcff, r10
	eor	r10, r11, lr
	eor	r10, arvpref, lsr 24
	tst	r10,  0x00000010
	subne	r11,  0x00000001
	tst	r11,  0x00000008
	orrne	pcff, 0x00000008
	tst	r11,  0x00000002
	orrne	pcff, 0x00000020
	b	exit

cpir:	TIME	16
	ldrb	lr, [mem, hlmp, lsr 16]
	rsb	r11, lr, arvpref, lsr 24
	uxtb	r11, r11
	mov	r10, 0x00000001
	orr	r10, 0x00010000
	uadd16	hlmp, hlmp, r10
	sub	bcfb, 0x00010000
	and	r10, r11, 0x0000007f
	orr	r10, r11, lsr 7
	pkhtb	defr, defr, r10
	orr	r10, lr, 0x00000080
	mvn	r10, r10
	pkhtb	bcfb, bcfb, r10
	mov	r10, arvpref, lsr 24
	and	r10, 0x0000007f
	pkhtb	spfa, spfa, r10
	movs	r10, bcfb, lsr 16
	beq	cpdr3
	orr	bcfb, 0x00000080
	orr	spfa, 0x00000080
	orrs	r11, r11
	beq	cpdr3
	TIME	5
	sub	pcff, 0x00010000
	pkhtb	hlmp, hlmp, pcff, asr 16
	sub	pcff, 0x00010000
cpdr3:	bic	pcff, 0x000000ff
	and	r10, r11, 0x000000d7
	uxtab	pcff, pcff, r10
	eor	r10, r11, lr
	eor	r10, arvpref, lsr 24
	tst	r10,  0x00000010
	subne	r11,  0x00000001
	tst	r11,  0x00000008
	orrne	pcff, 0x00000008
	tst	r11,  0x00000002
	orrne	pcff, 0x00000020
	b	exit

cpd:	TIME	16
	ldrb	lr, [mem, hlmp, lsr 16]
	rsb	r11, lr, arvpref, lsr 24
	uxtb	r11, r11
	mov	r10, 0x00000001
	orr	r10, 0x00010000
	usub16	hlmp, hlmp, r10
	sub	bcfb, 0x00010000
	and	r10, r11, 0x0000007f
	orr	r10, r11, lsr 7
	pkhtb	defr, defr, r10
	orr	r10, lr, 0x00000080
	mvn	r10, r10
	pkhtb	bcfb, bcfb, r10
	mov	r10, arvpref, lsr 24
	and	r10, 0x0000007f
	pkhtb	spfa, spfa, r10
	movs	r10, bcfb, lsr 16
	orrne	bcfb, 0x00000080
	orrne	spfa, 0x00000080
	bic	pcff, 0x000000ff
	and	r10, r11, 0x000000d7
	uxtab	pcff, pcff, r10
	eor	r10, r11, lr
	eor	r10, arvpref, lsr 24
	tst	r10,  0x00000010
	subne	r11,  0x00000001
	tst	r11,  0x00000008
	orrne	pcff, 0x00000008
	tst	r11,  0x00000002
	orrne	pcff, 0x00000020
	b	exit

cpdr:	TIME	16
	ldrb	lr, [mem, hlmp, lsr 16]
	rsb	r11, lr, arvpref, lsr 24
	uxtb	r11, r11
	mov	r10, 0x00000001
	orr	r10, 0x00010000
	usub16	hlmp, hlmp, r10
	sub	bcfb, 0x00010000
	and	r10, r11, 0x0000007f
	orr	r10, r11, lsr 7
	pkhtb	defr, defr, r10
	orr	r10, lr, 0x00000080
	mvn	r10, r10
	pkhtb	bcfb, bcfb, r10
	mov	r10, arvpref, lsr 24
	and	r10, 0x0000007f
	pkhtb	spfa, spfa, r10
	movs	r10, bcfb, lsr 16
	beq	cpdr2
	orr	bcfb, 0x00000080
	orr	spfa, 0x00000080
	orrs	r11, r11
	beq	cpdr2
	TIME	5
	sub	pcff, 0x00010000
	pkhtb	hlmp, hlmp, pcff, asr 16
	sub	pcff, 0x00010000
cpdr2:	bic	pcff, 0x000000ff
	and	r10, r11, 0x000000d7
	uxtab	pcff, pcff, r10
	eor	r10, r11, lr
	eor	r10, arvpref, lsr 24
	tst	r10,  0x00000010
	subne	r11,  0x00000001
	tst	r11,  0x00000008
	orrne	pcff, 0x00000008
	tst	r11,  0x00000002
	orrne	pcff, 0x00000020
	b	exit

ldir:	TIME	16
	ldrb	lr, [mem, hlmp, lsr 16]
	strb	lr, [mem, defr, lsr 16]
	mov	r11, 0x00010000
	add	hlmp, r11
	add	defr, r11
	sub	bcfb, r11
	movs	r10, defr, lsl 24
	pkhtbne defr, defr, r11, asr 16
	add	lr, arvpref, lsr 24
	and	lr, 00001010b
	add	lr, lr, lsl 4
	eor	lr, pcff
	and	lr, 40
	eor	pcff, lr
	pkhtb	spfa, spfa, lr, asr 8
	movs	lr, bcfb, lsr 16
	beq	ldir2
	eor	spfa, 0x00000080
	sub	pcff, 0x00010000
	pkhtb	hlmp, hlmp, pcff, asr 16
	sub	pcff, 0x00010000
	TIME	5
ldir2:	pkhbt	bcfb, spfa, lr, lsl 16
	b	exit

lddr:	TIME	16
	ldrb	lr, [mem, hlmp, lsr 16]
	strb	lr, [mem, defr, lsr 16]
	mov	r11, 0x00010000
	sub	hlmp, r11
	sub	defr, r11
	sub	bcfb, r11
	movs	r10, defr, lsl 24
	pkhtbne defr, defr, r11, asr 16
	add	lr, arvpref, lsr 24
	and	lr, 00001010b
	add	lr, lr, lsl 4
	eor	lr, pcff
	and	lr, 40
	eor	pcff, lr
	pkhtb	spfa, spfa, lr, asr 8
	movs	lr, bcfb, lsr 16
	beq	lddr2
	eor	spfa, 0x00000080
	sub	pcff, 0x00010000
	pkhtb	hlmp, hlmp, pcff, asr 16
	sub	pcff, 0x00010000
	TIME	5
lddr2:	pkhbt	bcfb, spfa, lr, lsl 16
	b	exit

ini:	TIME	16
	push	{r0-r3}
	mov	r0, bcfb, lsr 16
	add	r1, r0, 0x00000001
	pkhtb	hlmp, hlmp, r1
	bl	in_
	strb	r0, [mem, hlmp, lsr 16]
	add	hlmp, 0x00010000
	add	r1, bcfb, 0x00010000
	uxtab	r1, r0, r1, ror 24
	sub	bcfb, 0x01000000
	and	r11, r1, 0x00000007
	mov	r3, bcfb, lsr 24
	eor	r2, r11, r3
	and	r1, 0x00000100
	orr	r11, r1, r3
	pkhtb	defr, defr, r3
	eor	r3, defr, 0x00000080
	pkhtb	spfa, spfa, r3
	ldr	lr, [cb34]
	eor	r3, r2, r2, lsr 4
	eor	r3, bcfb, lsr 24
	tst	lr, lr, ror r3
	orrmi	r1, 0x00000800
	and	r0, 0x00000080
	mov	r0, r0, lsl 6
	orr	r0, r1
	pkhtb	bcfb, bcfb, r0, asr 4
	pop	{r0-r3}
	pkhtb	pcff, pcff, r11
	b	exit

ind:	TIME	16
	push	{r0-r3}
	mov	r0, bcfb, lsr 16
	sub	r1, r0, 0x00000001
	pkhtb	hlmp, hlmp, r1
	bl	in_
	strb	r0, [mem, hlmp, lsr 16]
	sub	hlmp, 0x00010000
	sub	r1, bcfb, 0x00010000
	uxtab	r1, r0, r1, ror 24
	sub	bcfb, 0x01000000
	and	r11, r1, 0x00000007
	mov	r3, bcfb, lsr 24
	eor	r2, r11, r3
	and	r1, 0x00000100
	orr	r11, r1, r3
	pkhtb	defr, defr, r3
	eor	r3, defr, 0x00000080
	pkhtb	spfa, spfa, r3
	ldr	lr, [cb34]
	eor	r3, r2, r2, lsr 4
	eor	r3, bcfb, lsr 24
	tst	lr, lr, ror r3
	orrmi	r1, 0x00000800
	and	r0, 0x00000080
	mov	r0, r0, lsl 6
	orr	r0, r1
	pkhtb	bcfb, bcfb, r0, asr 4
	pop	{r0-r3}
	pkhtb	pcff, pcff, r11
	b	exit

inir:	TIME	16
	mov	r10, stlo
	push	{r0-r3}
	mov	r0, bcfb, lsr 16
	add	r1, r0, 0x00000001
	pkhtb	hlmp, hlmp, r1
	bl	in_
	strb	r0, [mem, hlmp, lsr 16]
	add	hlmp, 0x00010000
	add	r1, bcfb, 0x00010000
	uxtab	r1, r0, r1, ror 24
	sub	bcfb, 0x01000000
	tst	bcfb, 0xff000000
	beq	inir2
	sub	pcff, 0x00010000
	pkhtb	hlmp, hlmp, pcff, asr 16
	sub	pcff, 0x00010000
	sub	r10, 0x00000005
inir2:	and	r11, r1, 0x00000007
	mov	r3, bcfb, lsr 24
	eor	r2, r11, r3
	and	r1, 0x00000100
	orr	r11, r1, r3
	pkhtb	defr, defr, r3
	eor	r3, defr, 0x00000080
	pkhtb	spfa, spfa, r3
	ldr	lr, [cb34]
	eor	r3, r2, r2, lsr 4
	eor	r3, bcfb, lsr 24
	tst	lr, lr, ror r3
	orrmi	r1, 0x00000800
	and	r0, 0x00000080
	mov	r0, r0, lsl 6
	orr	r0, r1
	pkhtb	bcfb, bcfb, r0, asr 4
	pop	{r0-r3}
	pkhtb	pcff, pcff, r11
	mov	stlo, r10
	b	exit

indr:	TIME	16
	mov	r10, stlo
	push	{r0-r3}
	mov	r0, bcfb, lsr 16
	sub	r1, r0, 0x00000001
	pkhtb	hlmp, hlmp, r1
	bl	in_
	strb	r0, [mem, hlmp, lsr 16]
	sub	hlmp, 0x00010000
	sub	r1, bcfb, 0x00010000
	uxtab	r1, r0, r1, ror 24
	sub	bcfb, 0x01000000
	tst	bcfb, 0xff000000
	beq	indr2
	sub	pcff, 0x00010000
	pkhtb	hlmp, hlmp, pcff, asr 16
	sub	pcff, 0x00010000
	sub	r10, 0x00000005
indr2:	and	r11, r1, 0x00000007
	mov	r3, bcfb, lsr 24
	eor	r2, r11, r3
	and	r1, 0x00000100
	orr	r11, r1, r3
	pkhtb	defr, defr, r3
	eor	r3, defr, 0x00000080
	pkhtb	spfa, spfa, r3
	ldr	lr, [cb34]
	eor	r3, r2, r2, lsr 4
	eor	r3, bcfb, lsr 24
	tst	lr, lr, ror r3
	orrmi	r1, 0x00000800
	and	r0, 0x00000080
	mov	r0, r0, lsl 6
	orr	r0, r1
	pkhtb	bcfb, bcfb, r0, asr 4
	pop	{r0-r3}
	pkhtb	pcff, pcff, r11
	mov	stlo, r10
	b	exit

outi:	TIME	16
	push	{r0-r3}
	sub	bcfb, 0x01000000
	mov	r0, bcfb, lsr 16
	add	r1, r0, 0x00000001
	pkhtb	hlmp, hlmp, r1
	ldrb	r1, [mem, hlmp, lsr 16]
	bl	out
	add	hlmp, 0x00010000
	and	r2, hlmp, 0x00ff0000
	add	r0, r1, r2, lsr 16
	and	r11, r0, 0x00000007
	mov	r3, bcfb, lsr 24
	eor	r2, r11, r3
	and	r0, 0x00000100
	orr	r11, r0, r3
	pkhtb	defr, defr, r3
	eor	r3, defr, 0x00000080
	pkhtb	spfa, spfa, r3
	ldr	lr, [cb34]
	eor	r3, r2, r2, lsr 4
	eor	r3, bcfb, lsr 24
	tst	lr, lr, ror r3
	orrmi	r0, 0x00000800
	and	r1, 0x00000080
	mov	r1, r1, lsl 6
	orr	r1, r0
	pkhtb	bcfb, bcfb, r1, asr 4
	pop	{r0-r3}
	pkhtb	pcff, pcff, r11
	b	exit

outd:	TIME	16
	push	{r0-r3}
	sub	bcfb, 0x01000000
	mov	r0, bcfb, lsr 16
	sub	r1, r0, 0x00000001
	pkhtb	hlmp, hlmp, r1
	ldrb	r1, [mem, hlmp, lsr 16]
	bl	out
	sub	hlmp, 0x00010000
	and	r2, hlmp, 0x00ff0000
	add	r0, r1, r2, lsr 16
	and	r11, r0, 0x00000007
	mov	r3, bcfb, lsr 24
	eor	r2, r11, r3
	and	r0, 0x00000100
	orr	r11, r0, r3
	pkhtb	defr, defr, r3
	eor	r3, defr, 0x00000080
	pkhtb	spfa, spfa, r3
	ldr	lr, [cb34]
	eor	r3, r2, r2, lsr 4
	eor	r3, bcfb, lsr 24
	tst	lr, lr, ror r3
	orrmi	r0, 0x00000800
	and	r1, 0x00000080
	mov	r1, r1, lsl 6
	orr	r1, r0
	pkhtb	bcfb, bcfb, r1, asr 4
	pop	{r0-r3}
	pkhtb	pcff, pcff, r11
	b	exit

otir:	TIME	16
	mov	r10, stlo
	push	{r0-r3}
	sub	bcfb, 0x01000000
	mov	r0, bcfb, lsr 16
	add	r1, r0, 0x00000001
	pkhtb	hlmp, hlmp, r1
	ldrb	r1, [mem, hlmp, lsr 16]
	bl	out
	add	hlmp, 0x00010000
	and	r2, hlmp, 0x00ff0000
	add	r0, r1, r2, lsr 16
	tst	bcfb, 0xff000000
	beq	otir2
	sub	pcff, 0x00010000
	pkhtb	hlmp, hlmp, pcff, asr 16
	sub	pcff, 0x00010000
	sub	r10, 0x00000005
otir2:	and	r11, r0, 0x00000007
	mov	r3, bcfb, lsr 24
	eor	r2, r11, r3
	and	r0, 0x00000100
	orr	r11, r0, r3
	pkhtb	defr, defr, r3
	eor	r3, defr, 0x00000080
	pkhtb	spfa, spfa, r3
	ldr	lr, [cb34]
	eor	r3, r2, r2, lsr 4
	eor	r3, bcfb, lsr 24
	tst	lr, lr, ror r3
	orrmi	r0, 0x00000800
	and	r1, 0x00000080
	mov	r1, r1, lsl 6
	orr	r1, r0
	pkhtb	bcfb, bcfb, r1, asr 4
	pop	{r0-r3}
	pkhtb	pcff, pcff, r11
	mov	stlo, r10
	b	exit

otdr:	TIME	16
	mov	r10, stlo
	push	{r0-r3}
	sub	bcfb, 0x01000000
	mov	r0, bcfb, lsr 16
	sub	r1, r0, 0x00000001
	pkhtb	hlmp, hlmp, r1
	ldrb	r1, [mem, hlmp, lsr 16]
	bl	out
	sub	hlmp, 0x00010000
	and	r2, hlmp, 0x00ff0000
	add	r0, r1, r2, lsr 16
	and	r11, r0, 0x00000007
	mov	r3, bcfb, lsr 24
	eor	r2, r11, r3
	and	r0, 0x00000100
	tst	bcfb, 0xff000000
	beq	otdr2
	sub	pcff, 0x00010000
	pkhtb	hlmp, hlmp, pcff, asr 16
	sub	pcff, 0x00010000
	sub	r10, 0x00000005
otdr2:	orr	r11, r0, r3
	pkhtb	defr, defr, r3
	eor	r3, defr, 0x00000080
	pkhtb	spfa, spfa, r3
	ldr	lr, [cb34]
	eor	r3, r2, r2, lsr 4
	eor	r3, bcfb, lsr 24
	tst	lr, lr, ror r3
	orrmi	r0, 0x00000800
	and	r1, 0x00000080
	mov	r1, r1, lsl 6
	orr	r1, r0
	pkhtb	bcfb, bcfb, r1, asr 4
	pop	{r0-r3}
	pkhtb	pcff, pcff, r11
	mov	stlo, r10
	b	exit

neg_:	TIME	8
	mvn	lr, arvpref, lsr 24
	pkhtb	bcfb, bcfb, lr
	add	lr, 0x00000001
	pkhtb	pcff, pcff, lr
	bic	arvpref, 0xff000000
	orr	arvpref, lr, lsl 24
	uxtb	lr, lr
	pkhtb	defr, defr, lr
	pkhtb	spfa, spfa, lr, asr 16
	b	exit

inbc:	INR	bcfb, 8
in_cc:	INR	bcfb, 0
indc:	INR	defr, 8
inec:	INR	defr, 0
inhc:	INR	hlmp, 8
inlc:	INR	hlmp, 0
inxc:	INR	arvpref, 0
inac:	INR	arvpref, 8

outcb:	OUTR	bcfb, 8
outcc:	OUTR	bcfb, 0
outcd:	OUTR	defr, 8
outce:	OUTR	defr, 0
outch:	OUTR	hlmp, 8
outcl:	OUTR	hlmp, 0
outcx:	OUTR	arvpref, 0
outca:	OUTR	arvpref, 8

ret14:	RET	14
	b	exit

im0:	TIME	8
	bic	arvpref, 0x00000300
	b	exit

im1:	TIME	8
	bic	arvpref, 0x00000200
	orr	arvpref, 0x00000100
	b	exit

im2:	TIME	8
	bic	arvpref, 0x00000100
	orr	arvpref, 0x00000200
	b	exit

ldai:	TIME	9
	bic	arvpref, 0xff000000
	ands	lr, iyi, 0x0000ff00
	orr	arvpref, lr, ror 16
	bic	pcff, 0x000000ff
	orr	pcff, lr, lsr 8
	orrne	lr, 0x00010000
	pkhtb	defr, defr, lr, asr 16
	and	lr, arvpref, 0x00000400
	pkhtb	spfa, spfa, lr, asr 3
	pkhtb	bcfb, bcfb, lr, asr 3
	b	exit

ldia:	TIME	9
	bic	iyi, 0x0000ff00
	and	lr, arvpref, 0xff000000
	orr	iyi, lr, ror 16
	b	exit

ldar_:	TIME	9
	bic	arvpref, 0xff000000
	and	lr, arvpref, 0x007f0000
	and	r11, arvpref, 0x00008000
	orrs	lr, r11, lsl 8
	orr	arvpref, lr, ror 24
	bic	pcff, 0x000000ff
	orr	pcff, lr, lsr 16
	orrne	lr, 0x01000000
	pkhtb	defr, defr, lr, asr 24
	and	lr, arvpref, 0x00000400
	pkhtb	spfa, spfa, lr, asr 3
	pkhtb	bcfb, bcfb, lr, asr 3
	b	exit

ldra:	TIME	9
	bic	arvpref, 0x00ff0000
	bic	arvpref, 0x00008000
	ands	lr, arvpref, 0xff000000
	orr	arvpref, lr, ror 8
	orrmi	arvpref, 0x00008000
	b	exit

rrd:	TIME	18
	ldrb	lr, [mem, hlmp, lsr 16]
	mov	r11, arvpref, lsr 24
	orr	lr, r11, lsl 8
	eor	arvpref, lr, lsl 24
	and	arvpref, 0xf0ffffff
	eor	arvpref, lr, lsl 24
	mov	r11, arvpref, lsr 24
	pkhtb	defr, defr, r11
	bic	pcff, 0x000000ff
	orr	pcff, r11
	orr	r11, 0x00000100
	pkhtb	spfa, spfa, r11
	pkhtb	bcfb, bcfb, r11, asr 16
	mov	lr, lr, lsr 4
	strb	lr, [mem, hlmp, lsr 16]
	add	lr, hlmp, 0x00010000
	pkhtb	hlmp, hlmp, lr, asr 16
	b	exit

rld:	TIME	18
	ldrb	lr, [mem, hlmp, lsr 16]
	and	r11, arvpref, 0x0f000000
	mov	lr, lr, lsl 4
	orr	lr, r11, lsr 24
	eor	arvpref, lr, lsl 16
	and	arvpref, 0xf0ffffff
	eor	arvpref, lr, lsl 16
	mov	r11, arvpref, lsr 24
	pkhtb	defr, defr, r11
	bic	pcff, 0x000000ff
	orr	pcff, r11
	orr	r11, 0x00000100
	pkhtb	spfa, spfa, r11
	pkhtb	bcfb, bcfb, r11, asr 16
	strb	lr, [mem, hlmp, lsr 16]
	add	lr, hlmp, 0x00010000
	pkhtb	hlmp, hlmp, lr, asr 16
	b	exit

opcb:	movs	lr, arvpref, lsl 24
	bne	opxdcb
	mov	lr, 0x00010000
	uadd8	arvpref, arvpref, lr
	ldrb	lr, [mem, pcff, lsr 16]
	add	pcff, 0x00010000
	ldr	pc, [pc, lr, lsl 2]
	dw	0			; filling
	dw	rlc_b			; 00 RLC B
	dw	rlc_c			; 01 RLC C
	dw	rlc_d			; 02 RLC D
	dw	rlc_e			; 03 RLC E
	dw	rlc_h			; 04 RLC H
	dw	rlc_l			; 05 RLC L
	dw	rlc_hl			; 06 RLC (HL)
	dw	rlc_a			; 07 RLC A
	dw	rrc_b			; 08 RRC B
	dw	rrc_c			; 09 RRC C
	dw	rrc_d			; 0a RRC D
	dw	rrc_e			; 0b RRC E
	dw	rrc_h			; 0c RRC H
	dw	rrc_l			; 0d RRC L
	dw	rrc_hl			; 0e RRC (HL)
	dw	rrc_a			; 0f RRC A
	dw	rl_b			; 10 RL B
	dw	rl_c			; 11 RL C
	dw	rl_d			; 12 RL D
	dw	rl_e			; 13 RL E
	dw	rl_h			; 14 RL H
	dw	rl_l			; 15 RL L
	dw	rl_hl			; 16 RL (HL)
	dw	rl_a			; 17 RL A
	dw	rr_b			; 18 RR B
	dw	rr_c			; 19 RR C
	dw	rr_d			; 1a RR D
	dw	rr_e			; 1b RR E
	dw	rr_h			; 1c RR H
	dw	rr_l			; 1d RR L
	dw	rr_hl			; 1e RR (HL)
	dw	rr_a			; 1f RR A
	dw	sla_b			; 20 SLA B
	dw	sla_c			; 21 SLA C
	dw	sla_d			; 22 SLA D
	dw	sla_e			; 23 SLA E
	dw	sla_h			; 24 SLA H
	dw	sla_l			; 25 SLA L
	dw	sla_hl			; 26 SLA (HL)
	dw	sla_a			; 27 SLA A
	dw	sra_b			; 28 SRA B
	dw	sra_c			; 29 SRA C
	dw	sra_d			; 2a SRA D
	dw	sra_e			; 2b SRA E
	dw	sra_h			; 2c SRA H
	dw	sra_l			; 2d SRA L
	dw	sra_hl			; 2e SRA (HL)
	dw	sra_a			; 2f SRA A
	dw	sll_b			; 30 SLL B
	dw	sll_c			; 31 SLL C
	dw	sll_d			; 32 SLL D
	dw	sll_e			; 33 SLL E
	dw	sll_h			; 34 SLL H
	dw	sll_l			; 35 SLL L
	dw	sll_hl			; 36 SLL (HL)
	dw	sll_a			; 37 SLL A
	dw	srl_b			; 38 SRL B
	dw	srl_c			; 39 SRL C
	dw	srl_d			; 3a SRL D
	dw	srl_e			; 3b SRL E
	dw	srl_h			; 3c SRL H
	dw	srl_l			; 3d SRL L
	dw	srl_hl			; 3e SRL (HL)
	dw	srl_a			; 3f SRL A
	dw	bit0b			; 40 BIT 0,B
	dw	bit0c			; 41 BIT 0,C
	dw	bit0d			; 42 BIT 0,D
	dw	bit0e			; 43 BIT 0,E
	dw	bit0h			; 44 BIT 0,H
	dw	bit0l			; 45 BIT 0,L
	dw	bit0hl			; 46 BIT 0,(HL)
	dw	bit0a			; 47 BIT 0,A
	dw	bit1b			; 48 BIT 1,B
	dw	bit1c			; 49 BIT 1,C
	dw	bit1d			; 4a BIT 1,D
	dw	bit1e			; 4b BIT 1,E
	dw	bit1h			; 4c BIT 1,H
	dw	bit1l			; 4d BIT 1,L
	dw	bit1hl			; 4e BIT 1,(HL)
	dw	bit1a			; 4f BIT 1,A
	dw	bit2b			; 50 BIT 2,B
	dw	bit2c			; 51 BIT 2,C
	dw	bit2d			; 52 BIT 2,D
	dw	bit2e			; 53 BIT 2,E
	dw	bit2h			; 54 BIT 2,H
	dw	bit2l			; 55 BIT 2,L
	dw	bit2hl			; 56 BIT 2,(HL)
	dw	bit2a			; 57 BIT 2,A
	dw	bit3b			; 58 BIT 3,B
	dw	bit3c			; 59 BIT 3,C
	dw	bit3d			; 5a BIT 3,D
	dw	bit3e			; 5b BIT 3,E
	dw	bit3h			; 5c BIT 3,H
	dw	bit3l			; 5d BIT 3,L
	dw	bit3hl			; 5e BIT 3,(HL)
	dw	bit3a			; 5f BIT 3,A
	dw	bit4b			; 60 BIT 4,B
	dw	bit4c			; 61 BIT 4,C
	dw	bit4d			; 62 BIT 4,D
	dw	bit4e			; 63 BIT 4,E
	dw	bit4h			; 64 BIT 4,H
	dw	bit4l			; 65 BIT 4,L
	dw	bit4hl			; 66 BIT 4,(HL)
	dw	bit4a			; 67 BIT 4,A
	dw	bit5b			; 68 BIT 5,B
	dw	bit5c			; 69 BIT 5,C
	dw	bit5d			; 6a BIT 5,D
	dw	bit5e			; 6b BIT 5,E
	dw	bit5h			; 6c BIT 5,H
	dw	bit5l			; 6d BIT 5,L
	dw	bit5hl			; 6e BIT 5,(HL)
	dw	bit5a			; 6f BIT 5,A
	dw	bit6b			; 70 BIT 6,B
	dw	bit6c			; 71 BIT 6,C
	dw	bit6d			; 72 BIT 6,D
	dw	bit6e			; 73 BIT 6,E
	dw	bit6h			; 74 BIT 6,H
	dw	bit6l			; 75 BIT 6,L
	dw	bit6hl			; 76 BIT 6,(HL)
	dw	bit6a			; 77 BIT 6,A
	dw	bit7b			; 78 BIT 7,B
	dw	bit7c			; 79 BIT 7,C
	dw	bit7d			; 7a BIT 7,D
	dw	bit7e			; 7b BIT 7,E
	dw	bit7h			; 7c BIT 7,H
	dw	bit7l			; 7d BIT 7,L
	dw	bit7hl			; 7e BIT 7,(HL)
	dw	bit7a			; 7f BIT 7,A
	dw	res0b			; 80 RES 0,B
	dw	res0c			; 81 RES 0,C
	dw	res0d			; 82 RES 0,D
	dw	res0e			; 83 RES 0,E
	dw	res0h			; 84 RES 0,H
	dw	res0l			; 85 RES 0,L
	dw	res0hl			; 86 RES 0,(HL)
	dw	res0a			; 87 RES 0,A
	dw	res1b			; 88 RES 1,B
	dw	res1c			; 89 RES 1,C
	dw	res1d			; 8a RES 1,D
	dw	res1e			; 8b RES 1,E
	dw	res1h			; 8c RES 1,H
	dw	res1l			; 8d RES 1,L
	dw	res1hl			; 8e RES 1,(HL)
	dw	res1a			; 8f RES 1,A
	dw	res2b			; 90 RES 2,B
	dw	res2c			; 91 RES 2,C
	dw	res2d			; 92 RES 2,D
	dw	res2e			; 93 RES 2,E
	dw	res2h			; 94 RES 2,H
	dw	res2l			; 95 RES 2,L
	dw	res2hl			; 96 RES 2,(HL)
	dw	res2a			; 97 RES 2,A
	dw	res3b			; 98 RES 3,B
	dw	res3c			; 99 RES 3,C
	dw	res3d			; 9a RES 3,D
	dw	res3e			; 9b RES 3,E
	dw	res3h			; 9c RES 3,H
	dw	res3l			; 9d RES 3,L
	dw	res3hl			; 9e RES 3,(HL)
	dw	res3a			; 9f RES 3,A
	dw	res4b			; a0 RES 4,B
	dw	res4c			; a1 RES 4,C
	dw	res4d			; a2 RES 4,D
	dw	res4e			; a3 RES 4,E
	dw	res4h			; a4 RES 4,H
	dw	res4l			; a5 RES 4,L
	dw	res4hl			; a6 RES 4,(HL)
	dw	res4a			; a7 RES 4,A
	dw	res5b			; a8 RES 5,B
	dw	res5c			; a9 RES 5,C
	dw	res5d			; aa RES 5,D
	dw	res5e			; ab RES 5,E
	dw	res5h			; ac RES 5,H
	dw	res5l			; ad RES 5,L
	dw	res5hl			; ae RES 5,(HL)
	dw	res5a			; af RES 5,A
	dw	res6b			; b0 RES 6,B
	dw	res6c			; b1 RES 6,C
	dw	res6d			; b2 RES 6,D
	dw	res6e			; b3 RES 6,E
	dw	res6h			; b4 RES 6,H
	dw	res6l			; b5 RES 6,L
	dw	res6hl			; b6 RES 6,(HL)
	dw	res6a			; b7 RES 6,A
	dw	res7b			; b8 RES 7,B
	dw	res7c			; b9 RES 7,C
	dw	res7d			; ba RES 7,D
	dw	res7e			; bb RES 7,E
	dw	res7h			; bc RES 7,H
	dw	res7l			; bd RES 7,L
	dw	res7hl			; be RES 7,(HL)
	dw	res7a			; bf RES 7,A
	dw	set0b			; c0 SET 0,B
	dw	set0c			; c1 SET 0,C
	dw	set0d			; c2 SET 0,D
	dw	set0e			; c3 SET 0,E
	dw	set0h			; c4 SET 0,H
	dw	set0l			; c5 SET 0,L
	dw	set0hl			; c6 SET 0,(HL)
	dw	set0a			; c7 SET 0,A
	dw	set1b			; c8 SET 1,B
	dw	set1c			; c9 SET 1,C
	dw	set1d			; ca SET 1,D
	dw	set1e			; cb SET 1,E
	dw	set1h			; cc SET 1,H
	dw	set1l			; cd SET 1,L
	dw	set1hl			; ce SET 1,(HL)
	dw	set1a			; cf SET 1,A
	dw	set2b			; d0 SET 2,B
	dw	set2c			; d1 SET 2,C
	dw	set2d			; d2 SET 2,D
	dw	set2e			; d3 SET 2,E
	dw	set2h			; d4 SET 2,H
	dw	set2l			; d5 SET 2,L
	dw	set2hl			; d6 SET 2,(HL)
	dw	set2a			; d7 SET 2,A
	dw	set3b			; d8 SET 3,B
	dw	set3c			; d9 SET 3,C
	dw	set3d			; da SET 3,D
	dw	set3e			; db SET 3,E
	dw	set3h			; dc SET 3,H
	dw	set3l			; dd SET 3,L
	dw	set3hl			; de SET 3,(HL)
	dw	set3a			; df SET 3,A
	dw	set4b			; e0 SET 4,B
	dw	set4c			; e1 SET 4,C
	dw	set4d			; e2 SET 4,D
	dw	set4e			; e3 SET 4,E
	dw	set4h			; e4 SET 4,H
	dw	set4l			; e5 SET 4,L
	dw	set4hl			; e6 SET 4,(HL)
	dw	set4a			; e7 SET 4,A
	dw	set5b			; e8 SET 5,B
	dw	set5c			; e9 SET 5,C
	dw	set5d			; ea SET 5,D
	dw	set5e			; eb SET 5,E
	dw	set5h			; ec SET 5,H
	dw	set5l			; ed SET 5,L
	dw	set5hl			; ee SET 5,(HL)
	dw	set5a			; ef SET 5,A
	dw	set6b			; f0 SET 6,B
	dw	set6c			; f1 SET 6,C
	dw	set6d			; f2 SET 6,D
	dw	set6e			; f3 SET 6,E
	dw	set6h			; f4 SET 6,H
	dw	set6l			; f5 SET 6,L
	dw	set6hl			; f6 SET 6,(HL)
	dw	set6a			; f7 SET 6,A
	dw	set7b			; f8 SET 7,B
	dw	set7c			; f9 SET 7,C
	dw	set7d			; fa SET 7,D
	dw	set7e			; fb SET 7,E
	dw	set7h			; fc SET 7,H
	dw	set7l			; fd SET 7,L
	dw	set7hl			; fe SET 7,(HL)
	dw	set7a			; ff SET 7,A

rlc_b:	RLC	bcfb, 8
rlc_c:	RLC	bcfb, 0
rlc_d:	RLC	defr, 8
rlc_e:	RLC	defr, 0
rlc_h:	RLC	hlmp, 8
rlc_l:	RLC	hlmp, 0
rlc_hl: TIME	15
	ldrb	lr, [mem, hlmp, lsr 16]
	add	lr, lr, lr, lsl 8
	pkhtb	pcff, pcff, lr, asr 7
	uxtb	lr, pcff
	pkhtb	defr, defr, lr
	orr	lr, 0x00000100
	pkhtb	spfa, spfa, lr
	pkhtb	bcfb, bcfb, lr, asr 16
	strb	lr, [mem, hlmp, lsr 16]
	b	exit
rlc_a:	RLC	arvpref, 8
rrc_b:	RRC	bcfb, 8
rrc_c:	RRC	bcfb, 0
rrc_d:	RRC	defr, 8
rrc_e:	RRC	defr, 0
rrc_h:	RRC	hlmp, 8
rrc_l:	RRC	hlmp, 0
rrc_hl: TIME	15
	ldrb	lr, [mem, hlmp, lsr 16]
	movs	lr, lr, lsr 1
	orrcs	lr, 0x00000180
	pkhtb	pcff, pcff, lr
	uxtb	lr, lr
	pkhtb	defr, defr, lr
	orr	lr, 0x00000100
	pkhtb	spfa, spfa, lr
	pkhtb	bcfb, bcfb, lr, asr 16
	strb	lr, [mem, hlmp, lsr 16]
	b	exit
rrc_a:	RRC	arvpref, 8
rl_b:	RL	bcfb, 8
rl_c:	RL	bcfb, 0
rl_d:	RL	defr, 8
rl_e:	RL	defr, 0
rl_h:	RL	hlmp, 8
rl_l:	RL	hlmp, 0
rl_hl:	TIME	15
	movs	lr, pcff, lsl 24
	ldrb	lr, [mem, hlmp, lsr 16]
	adc	lr, lr
	pkhtb	pcff, pcff, lr
	uxtb	lr, lr
	pkhtb	defr, defr, lr
	add	lr, 0x00000100
	pkhtb	spfa, spfa, lr
	pkhtb	bcfb, bcfb, lr, asr 16
	strb	lr, [mem, hlmp, lsr 16]
	b	exit
rl_a:	RL	arvpref, 8
rr_b:	RR	bcfb, 8
rr_c:	RR	bcfb, 0
rr_d:	RR	defr, 8
rr_e:	RR	defr, 0
rr_h:	RR	hlmp, 8
rr_l:	RR	hlmp, 0
rr_hl:	TIME	15
	ldrb	lr, [mem, hlmp, lsr 16]
	add	lr, lr, lr, lsl 9
	and	r10, pcff, 0x00000100
	orr	lr, r10
	pkhtb	pcff, pcff, lr, asr 1
	uxtb	lr, pcff
	pkhtb	defr, defr, lr
	add	lr, 0x00000100
	pkhtb	spfa, spfa, lr
	pkhtb	bcfb, bcfb, lr, asr 16
	strb	lr, [mem, hlmp, lsr 16]
	b	exit
rr_a:	RR	arvpref, 8
sla_b:	SLA	bcfb, 8
sla_c:	SLA	bcfb, 0
sla_d:	SLA	defr, 8
sla_e:	SLA	defr, 0
sla_h:	SLA	hlmp, 8
sla_l:	SLA	hlmp, 0
sla_hl: TIME	15
	ldrb	lr, [mem, hlmp, lsr 16]
	mov	lr, lr, lsl 1
	pkhtb	pcff, pcff, lr
	uxtb	lr, lr
	pkhtb	defr, defr, lr
	add	lr, 0x00000100
	pkhtb	spfa, spfa, lr
	pkhtb	bcfb, bcfb, lr, asr 16
	strb	lr, [mem, hlmp, lsr 16]
	b	exit
sla_a:	SLA	arvpref, 8
sra_b:	SRA	bcfb, 8
sra_c:	SRA	bcfb, 0
sra_d:	SRA	defr, 8
sra_e:	SRA	defr, 0
sra_h:	SRA	hlmp, 8
sra_l:	SRA	hlmp, 0
sra_hl: TIME	15
	ldrb	lr, [mem, hlmp, lsr 16]
	add	lr, lr, lr, lsl 9
	tst	lr, 0x00000080
	orrne	lr, 0x00000100
	pkhtb	pcff, pcff, lr, asr 1
	uxtb	lr, pcff
	pkhtb	defr, defr, lr
	add	lr, 0x00000100
	pkhtb	spfa, spfa, lr
	pkhtb	bcfb, bcfb, lr, asr 16
	strb	lr, [mem, hlmp, lsr 16]
	b	exit
sra_a:	SRA	arvpref, 8
sll_b:	SLL	bcfb, 8
sll_c:	SLL	bcfb, 0
sll_d:	SLL	defr, 8
sll_e:	SLL	defr, 0
sll_h:	SLL	hlmp, 8
sll_l:	SLL	hlmp, 0
sll_hl: TIME	15
	ldrb	lr, [mem, hlmp, lsr 16]
	mov	lr, lr, lsl 1
	orr	lr, 0x00000001
	pkhtb	pcff, pcff, lr
	uxtb	lr, lr
	pkhtb	defr, defr, lr
	add	lr, 0x00000100
	pkhtb	spfa, spfa, lr
	pkhtb	bcfb, bcfb, lr, asr 16
	strb	lr, [mem, hlmp, lsr 16]
	b	exit
sll_a:	SLL	arvpref, 8
srl_b:	SRL	bcfb, 8
srl_c:	SRL	bcfb, 0
srl_d:	SRL	defr, 8
srl_e:	SRL	defr, 0
srl_h:	SRL	hlmp, 8
srl_l:	SRL	hlmp, 0
srl_hl: TIME	15
	ldrb	lr, [mem, hlmp, lsr 16]
	add	lr, lr, lr, lsl 9
	pkhtb	pcff, pcff, lr, asr 1
	uxtb	lr, pcff
	pkhtb	defr, defr, lr
	add	lr, 0x00000100
	pkhtb	spfa, spfa, lr
	pkhtb	bcfb, bcfb, lr, asr 16
	strb	lr, [mem, hlmp, lsr 16]
	b	exit
srl_a:	SRL	arvpref, 8

bit0b:	BIT	0x01, bcfb, 8
bit0c:	BIT	0x01, bcfb, 0
bit0d:	BIT	0x01, defr, 8
bit0e:	BIT	0x01, defr, 0
bit0h:	BIT	0x01, hlmp, 8
bit0l:	BIT	0x01, hlmp, 0
bit0hl: BITHL	0x01
bit0a:	BIT	0x01, arvpref, 8
bit1b:	BIT	0x02, bcfb, 8
bit1c:	BIT	0x02, bcfb, 0
bit1d:	BIT	0x02, defr, 8
bit1e:	BIT	0x02, defr, 0
bit1h:	BIT	0x02, hlmp, 8
bit1l:	BIT	0x02, hlmp, 0
bit1hl: BITHL	0x02
bit1a:	BIT	0x02, arvpref, 8
bit2b:	BIT	0x04, bcfb, 8
bit2c:	BIT	0x04, bcfb, 0
bit2d:	BIT	0x04, defr, 8
bit2e:	BIT	0x04, defr, 0
bit2h:	BIT	0x04, hlmp, 8
bit2l:	BIT	0x04, hlmp, 0
bit2hl: BITHL	0x04
bit2a:	BIT	0x04, arvpref, 8
bit3b:	BIT	0x08, bcfb, 8
bit3c:	BIT	0x08, bcfb, 0
bit3d:	BIT	0x08, defr, 8
bit3e:	BIT	0x08, defr, 0
bit3h:	BIT	0x08, hlmp, 8
bit3l:	BIT	0x08, hlmp, 0
bit3hl: BITHL	0x08
bit3a:	BIT	0x08, arvpref, 8
bit4b:	BIT	0x10, bcfb, 8
bit4c:	BIT	0x10, bcfb, 0
bit4d:	BIT	0x10, defr, 8
bit4e:	BIT	0x10, defr, 0
bit4h:	BIT	0x10, hlmp, 8
bit4l:	BIT	0x10, hlmp, 0
bit4hl: BITHL	0x10
bit4a:	BIT	0x10, arvpref, 8
bit5b:	BIT	0x20, bcfb, 8
bit5c:	BIT	0x20, bcfb, 0
bit5d:	BIT	0x20, defr, 8
bit5e:	BIT	0x20, defr, 0
bit5h:	BIT	0x20, hlmp, 8
bit5l:	BIT	0x20, hlmp, 0
bit5hl: BITHL	0x20
bit5a:	BIT	0x20, arvpref, 8
bit6b:	BIT	0x40, bcfb, 8
bit6c:	BIT	0x40, bcfb, 0
bit6d:	BIT	0x40, defr, 8
bit6e:	BIT	0x40, defr, 0
bit6h:	BIT	0x40, hlmp, 8
bit6l:	BIT	0x40, hlmp, 0
bit6hl: BITHL	0x40
bit6a:	BIT	0x40, arvpref, 8
bit7b:	BIT	0x80, bcfb, 8
bit7c:	BIT	0x80, bcfb, 0
bit7d:	BIT	0x80, defr, 8
bit7e:	BIT	0x80, defr, 0
bit7h:	BIT	0x80, hlmp, 8
bit7l:	BIT	0x80, hlmp, 0
bit7hl: BITHL	0x80
bit7a:	BIT	0x80, arvpref, 8

res0b:	RES	0xfe, bcfb, 8
res0c:	RES	0xfe, bcfb, 0
res0d:	RES	0xfe, defr, 8
res0e:	RES	0xfe, defr, 0
res0h:	RES	0xfe, hlmp, 8
res0l:	RES	0xfe, hlmp, 0
res0hl: RESHL	0xfe
res0a:	RES	0xfe, arvpref, 8
res1b:	RES	0xfd, bcfb, 8
res1c:	RES	0xfd, bcfb, 0
res1d:	RES	0xfd, defr, 8
res1e:	RES	0xfd, defr, 0
res1h:	RES	0xfd, hlmp, 8
res1l:	RES	0xfd, hlmp, 0
res1hl: RESHL	0xfd
res1a:	RES	0xfd, arvpref, 8
res2b:	RES	0xfb, bcfb, 8
res2c:	RES	0xfb, bcfb, 0
res2d:	RES	0xfb, defr, 8
res2e:	RES	0xfb, defr, 0
res2h:	RES	0xfb, hlmp, 8
res2l:	RES	0xfb, hlmp, 0
res2hl: RESHL	0xfb
res2a:	RES	0xfb, arvpref, 8
res3b:	RES	0xf7, bcfb, 8
res3c:	RES	0xf7, bcfb, 0
res3d:	RES	0xf7, defr, 8
res3e:	RES	0xf7, defr, 0
res3h:	RES	0xf7, hlmp, 8
res3l:	RES	0xf7, hlmp, 0
res3hl: RESHL	0xf7
res3a:	RES	0xf7, arvpref, 8
res4b:	RES	0xef, bcfb, 8
res4c:	RES	0xef, bcfb, 0
res4d:	RES	0xef, defr, 8
res4e:	RES	0xef, defr, 0
res4h:	RES	0xef, hlmp, 8
res4l:	RES	0xef, hlmp, 0
res4hl: RESHL	0xef
res4a:	RES	0xef, arvpref, 8
res5b:	RES	0xdf, bcfb, 8
res5c:	RES	0xdf, bcfb, 0
res5d:	RES	0xdf, defr, 8
res5e:	RES	0xdf, defr, 0
res5h:	RES	0xdf, hlmp, 8
res5l:	RES	0xdf, hlmp, 0
res5hl: RESHL	0xdf
res5a:	RES	0xdf, arvpref, 8
res6b:	RES	0xbf, bcfb, 8
res6c:	RES	0xbf, bcfb, 0
res6d:	RES	0xbf, defr, 8
res6e:	RES	0xbf, defr, 0
res6h:	RES	0xbf, hlmp, 8
res6l:	RES	0xbf, hlmp, 0
res6hl: RESHL	0xbf
res6a:	RES	0xbf, arvpref, 8
res7b:	RES	0x7f, bcfb, 8
res7c:	RES	0x7f, bcfb, 0
res7d:	RES	0x7f, defr, 8
res7e:	RES	0x7f, defr, 0
res7h:	RES	0x7f, hlmp, 8
res7l:	RES	0x7f, hlmp, 0
res7hl: RESHL	0x7f
res7a:	RES	0x7f, arvpref, 8

set0b:	SET	0x01, bcfb, 8
set0c:	SET	0x01, bcfb, 0
set0d:	SET	0x01, defr, 8
set0e:	SET	0x01, defr, 0
set0h:	SET	0x01, hlmp, 8
set0l:	SET	0x01, hlmp, 0
set0hl: SETHL	0x01
set0a:	SET	0x01, arvpref, 8
set1b:	SET	0x02, bcfb, 8
set1c:	SET	0x02, bcfb, 0
set1d:	SET	0x02, defr, 8
set1e:	SET	0x02, defr, 0
set1h:	SET	0x02, hlmp, 8
set1l:	SET	0x02, hlmp, 0
set1hl: SETHL	0x02
set1a:	SET	0x02, arvpref, 8
set2b:	SET	0x04, bcfb, 8
set2c:	SET	0x04, bcfb, 0
set2d:	SET	0x04, defr, 8
set2e:	SET	0x04, defr, 0
set2h:	SET	0x04, hlmp, 8
set2l:	SET	0x04, hlmp, 0
set2hl: SETHL	0x04
set2a:	SET	0x04, arvpref, 8
set3b:	SET	0x08, bcfb, 8
set3c:	SET	0x08, bcfb, 0
set3d:	SET	0x08, defr, 8
set3e:	SET	0x08, defr, 0
set3h:	SET	0x08, hlmp, 8
set3l:	SET	0x08, hlmp, 0
set3hl: SETHL	0x08
set3a:	SET	0x08, arvpref, 8
set4b:	SET	0x10, bcfb, 8
set4c:	SET	0x10, bcfb, 0
set4d:	SET	0x10, defr, 8
set4e:	SET	0x10, defr, 0
set4h:	SET	0x10, hlmp, 8
set4l:	SET	0x10, hlmp, 0
set4hl: SETHL	0x10
set4a:	SET	0x10, arvpref, 8
set5b:	SET	0x20, bcfb, 8
set5c:	SET	0x20, bcfb, 0
set5d:	SET	0x20, defr, 8
set5e:	SET	0x20, defr, 0
set5h:	SET	0x20, hlmp, 8
set5l:	SET	0x20, hlmp, 0
set5hl: SETHL	0x20
set5a:	SET	0x20, arvpref, 8
set6b:	SET	0x40, bcfb, 8
set6c:	SET	0x40, bcfb, 0
set6d:	SET	0x40, defr, 8
set6e:	SET	0x40, defr, 0
set6h:	SET	0x40, hlmp, 8
set6l:	SET	0x40, hlmp, 0
set6hl: SETHL	0x40
set6a:	SET	0x40, arvpref, 8
set7b:	SET	0x80, bcfb, 8
set7c:	SET	0x80, bcfb, 0
set7d:	SET	0x80, defr, 8
set7e:	SET	0x80, defr, 0
set7h:	SET	0x80, hlmp, 8
set7l:	SET	0x80, hlmp, 0
set7hl: SETHL	0x80
set7a:	SET	0x80, arvpref, 8

;--------------------------------

b_rlcx: RLCX	bcfb, 8
c_rlcx: RLCX	bcfb, 0
d_rlcx: RLCX	defr, 8
e_rlcx: RLCX	defr, 0
h_rlcx: RLCX	hlmp, 8
l_rlcx: RLCX	hlmp, 0
rlcx:	RLCX	arvpref, 0
a_rlcx: RLCX	arvpref, 8
b_rrcx: RRCX	bcfb, 8
c_rrcx: RRCX	bcfb, 0
d_rrcx: RRCX	defr, 8
e_rrcx: RRCX	defr, 0
h_rrcx: RRCX	hlmp, 8
l_rrcx: RRCX	hlmp, 0
rrcx:	RRCX	arvpref, 0
a_rrcx: RRCX	arvpref, 8
b_rlx:	RLX	bcfb, 8
c_rlx:	RLX	bcfb, 0
d_rlx:	RLX	defr, 8
e_rlx:	RLX	defr, 0
h_rlx:	RLX	hlmp, 8
l_rlx:	RLX	hlmp, 0
rlx:	RLX	arvpref, 0
a_rlx:	RLX	arvpref, 8
b_rrx:	RRX	bcfb, 8
c_rrx:	RRX	bcfb, 0
d_rrx:	RRX	defr, 8
e_rrx:	RRX	defr, 0
h_rrx:	RRX	hlmp, 8
l_rrx:	RRX	hlmp, 0
rrx_:	RRX	arvpref, 0
a_rrx:	RRX	arvpref, 8
b_slax: SLAX	bcfb, 8
c_slax: SLAX	bcfb, 0
d_slax: SLAX	defr, 8
e_slax: SLAX	defr, 0
h_slax: SLAX	hlmp, 8
l_slax: SLAX	hlmp, 0
slax:	SLAX	arvpref, 0
a_slax: SLAX	arvpref, 8
b_srax: SRAX	bcfb, 8
c_srax: SRAX	bcfb, 0
d_srax: SRAX	defr, 8
e_srax: SRAX	defr, 0
h_srax: SRAX	hlmp, 8
l_srax: SRAX	hlmp, 0
srax:	SRAX	arvpref, 0
a_srax: SRAX	arvpref, 8
b_sllx: SLLX	bcfb, 8
c_sllx: SLLX	bcfb, 0
d_sllx: SLLX	defr, 8
e_sllx: SLLX	defr, 0
h_sllx: SLLX	hlmp, 8
l_sllx: SLLX	hlmp, 0
sllx:	SLLX	arvpref, 0
a_sllx: SLLX	arvpref, 8
b_srlx: SRLX	bcfb, 8
c_srlx: SRLX	bcfb, 0
d_srlx: SRLX	defr, 8
e_srlx: SRLX	defr, 0
h_srlx: SRLX	hlmp, 8
l_srlx: SRLX	hlmp, 0
srlx:	SRLX	arvpref, 0
a_srlx: SRLX	arvpref, 8
biti0:	BITI	0x01
biti1:	BITI	0x02
biti2:	BITI	0x04
biti3:	BITI	0x08
biti4:	BITI	0x10
biti5:	BITI	0x20
biti6:	BITI	0x40
biti7:	BITI	0x80
b_res0x:RESXD	0xfffffffe, bcfb, 8
c_res0x:RESXD	0xfffffffe, bcfb, 0
d_res0x:RESXD	0xfffffffe, defr, 8
e_res0x:RESXD	0xfffffffe, defr, 0
h_res0x:RESXD	0xfffffffe, hlmp, 8
l_res0x:RESXD	0xfffffffe, hlmp, 0
res0x:	RESXD	0xfffffffe, arvpref, 0
a_res0x:RESXD	0xfffffffe, arvpref, 8
b_res1x:RESXD	0xfffffffd, bcfb, 8
c_res1x:RESXD	0xfffffffd, bcfb, 0
d_res1x:RESXD	0xfffffffd, defr, 8
e_res1x:RESXD	0xfffffffd, defr, 0
h_res1x:RESXD	0xfffffffd, hlmp, 8
l_res1x:RESXD	0xfffffffd, hlmp, 0
res1x:	RESXD	0xfffffffd, arvpref, 0
a_res1x:RESXD	0xfffffffd, arvpref, 8
b_res2x:RESXD	0xfffffffb, bcfb, 8
c_res2x:RESXD	0xfffffffb, bcfb, 0
d_res2x:RESXD	0xfffffffb, defr, 8
e_res2x:RESXD	0xfffffffb, defr, 0
h_res2x:RESXD	0xfffffffb, hlmp, 8
l_res2x:RESXD	0xfffffffb, hlmp, 0
res2x:	RESXD	0xfffffffb, arvpref, 0
a_res2x:RESXD	0xfffffffb, arvpref, 8
b_res3x:RESXD	0xfffffff7, bcfb, 8
c_res3x:RESXD	0xfffffff7, bcfb, 0
d_res3x:RESXD	0xfffffff7, defr, 8
e_res3x:RESXD	0xfffffff7, defr, 0
h_res3x:RESXD	0xfffffff7, hlmp, 8
l_res3x:RESXD	0xfffffff7, hlmp, 0
res3x:	RESXD	0xfffffff7, arvpref, 0
a_res3x:RESXD	0xfffffff7, arvpref, 8
b_res4x:RESXD	0xffffffef, bcfb, 8
c_res4x:RESXD	0xffffffef, bcfb, 0
d_res4x:RESXD	0xffffffef, defr, 8
e_res4x:RESXD	0xffffffef, defr, 0
h_res4x:RESXD	0xffffffef, hlmp, 8
l_res4x:RESXD	0xffffffef, hlmp, 0
res4x:	RESXD	0xffffffef, arvpref, 0
a_res4x:RESXD	0xffffffef, arvpref, 8
b_res5x:RESXD	0xffffffdf, bcfb, 8
c_res5x:RESXD	0xffffffdf, bcfb, 0
d_res5x:RESXD	0xffffffdf, defr, 8
e_res5x:RESXD	0xffffffdf, defr, 0
h_res5x:RESXD	0xffffffdf, hlmp, 8
l_res5x:RESXD	0xffffffdf, hlmp, 0
res5x:	RESXD	0xffffffdf, arvpref, 0
a_res5x:RESXD	0xffffffdf, arvpref, 8
b_res6x:RESXD	0xffffffbf, bcfb, 8
c_res6x:RESXD	0xffffffbf, bcfb, 0
d_res6x:RESXD	0xffffffbf, defr, 8
e_res6x:RESXD	0xffffffbf, defr, 0
h_res6x:RESXD	0xffffffbf, hlmp, 8
l_res6x:RESXD	0xffffffbf, hlmp, 0
res6x:	RESXD	0xffffffbf, arvpref, 0
a_res6x:RESXD	0xffffffbf, arvpref, 8
b_res7x:RESXD	0xffffff7f, bcfb, 8
c_res7x:RESXD	0xffffff7f, bcfb, 0
d_res7x:RESXD	0xffffff7f, defr, 8
e_res7x:RESXD	0xffffff7f, defr, 0
h_res7x:RESXD	0xffffff7f, hlmp, 8
l_res7x:RESXD	0xffffff7f, hlmp, 0
res7x:	RESXD	0xffffff7f, arvpref, 0
a_res7x:RESXD	0xffffff7f, arvpref, 8
b_set0x:SETXD	0x01, bcfb, 8
c_set0x:SETXD	0x01, bcfb, 0
d_set0x:SETXD	0x01, defr, 8
e_set0x:SETXD	0x01, defr, 0
h_set0x:SETXD	0x01, hlmp, 8
l_set0x:SETXD	0x01, hlmp, 0
set0x:	SETXD	0x01, arvpref, 0
a_set0x:SETXD	0x01, arvpref, 8
b_set1x:SETXD	0x02, bcfb, 8
c_set1x:SETXD	0x02, bcfb, 0
d_set1x:SETXD	0x02, defr, 8
e_set1x:SETXD	0x02, defr, 0
h_set1x:SETXD	0x02, hlmp, 8
l_set1x:SETXD	0x02, hlmp, 0
set1x:	SETXD	0x02, arvpref, 0
a_set1x:SETXD	0x02, arvpref, 8
b_set2x:SETXD	0x04, bcfb, 8
c_set2x:SETXD	0x04, bcfb, 0
d_set2x:SETXD	0x04, defr, 8
e_set2x:SETXD	0x04, defr, 0
h_set2x:SETXD	0x04, hlmp, 8
l_set2x:SETXD	0x04, hlmp, 0
set2x:	SETXD	0x04, arvpref, 0
a_set2x:SETXD	0x04, arvpref, 8
b_set3x:SETXD	0x08, bcfb, 8
c_set3x:SETXD	0x08, bcfb, 0
d_set3x:SETXD	0x08, defr, 8
e_set3x:SETXD	0x08, defr, 0
h_set3x:SETXD	0x08, hlmp, 8
l_set3x:SETXD	0x08, hlmp, 0
set3x:	SETXD	0x08, arvpref, 0
a_set3x:SETXD	0x08, arvpref, 8
b_set4x:SETXD	0x10, bcfb, 8
c_set4x:SETXD	0x10, bcfb, 0
d_set4x:SETXD	0x10, defr, 8
e_set4x:SETXD	0x10, defr, 0
h_set4x:SETXD	0x10, hlmp, 8
l_set4x:SETXD	0x10, hlmp, 0
set4x:	SETXD	0x10, arvpref, 0
a_set4x:SETXD	0x10, arvpref, 8
b_set5x:SETXD	0x20, bcfb, 8
c_set5x:SETXD	0x20, bcfb, 0
d_set5x:SETXD	0x20, defr, 8
e_set5x:SETXD	0x20, defr, 0
h_set5x:SETXD	0x20, hlmp, 8
l_set5x:SETXD	0x20, hlmp, 0
set5x:	SETXD	0x20, arvpref, 0
a_set5x:SETXD	0x20, arvpref, 8
b_set6x:SETXD	0x40, bcfb, 8
c_set6x:SETXD	0x40, bcfb, 0
d_set6x:SETXD	0x40, defr, 8
e_set6x:SETXD	0x40, defr, 0
h_set6x:SETXD	0x40, hlmp, 8
l_set6x:SETXD	0x40, hlmp, 0
set6x:	SETXD	0x40, arvpref, 0
a_set6x:SETXD	0x40, arvpref, 8
b_set7x:SETXD	0x80, bcfb, 8
c_set7x:SETXD	0x80, bcfb, 0
d_set7x:SETXD	0x80, defr, 8
e_set7x:SETXD	0x80, defr, 0
h_set7x:SETXD	0x80, hlmp, 8
l_set7x:SETXD	0x80, hlmp, 0
set7x:	SETXD	0x80, arvpref, 0
a_set7x:SETXD	0x80, arvpref, 8

opxdcb: bmi	opfdcb
opddcb: TIME	11
	ldr	lr, [mem, pcff, lsr 16]
	sxtb	r11, lr
	add	r11, ix, lsr 16
	b	contcb
opfdcb: TIME	11
	ldr	lr, [mem, pcff, lsr 16]
	sxtb	r11, lr
	add	r11, iyi, lsr 16
contcb: bic	arvpref, 0xff
	pkhtb	hlmp, hlmp, r11
	ldrb	r10, [mem, r11]
	uxtb	lr, lr, ror 8
	add	pcff, 0x00020000
	ldr	pc, [pc, lr, lsl 2]
c18003: dw	0x00018003
	dw	b_rlcx		    ; 00 LD B,RLC (IX + d) // LD B,RLC (IY + d)
	dw	c_rlcx		    ; 01 LD C,RLC (IX + d) // LD C,RLC (IY + d)
	dw	d_rlcx		    ; 02 LD D,RLC (IX + d) // LD D,RLC (IY + d)
	dw	e_rlcx		    ; 03 LD E,RLC (IX + d) // LD E,RLC (IY + d)
	dw	h_rlcx		    ; 04 LD H,RLC (IX + d) // LD H,RLC (IY + d)
	dw	l_rlcx		    ; 05 LD L,RLC (IX + d) // LD L,RLC (IY + d)
	dw	rlcx		    ; 06 RLC (IX + d) // RLC (IY + d)
	dw	a_rlcx		    ; 07 LD A,RLC (IX + d) // LD A,RLC (IY + d)
	dw	b_rrcx		    ; 08 LD B,RRC (IX + d) // LD B,RRC (IY + d)
	dw	c_rrcx		    ; 09 LD C,RRC (IX + d) // LD C,RRC (IY + d)
	dw	d_rrcx		    ; 0a LD D,RRC (IX + d) // LD D,RRC (IY + d)
	dw	e_rrcx		    ; 0b LD E,RRC (IX + d) // LD E,RRC (IY + d)
	dw	h_rrcx		    ; 0c LD H,RRC (IX + d) // LD H,RRC (IY + d)
	dw	l_rrcx		    ; 0d LD L,RRC (IX + d) // LD L,RRC (IY + d)
	dw	rrcx		    ; 0e RRC (IX + d) // RRC (IY + d)
	dw	a_rrcx		    ; 0f LD A,RRC (IX + d) // LD A,RRC (IY + d)
	dw	b_rlx		    ; 10 LD B,RL (IX + d) // LD B,RL (IY + d)
	dw	c_rlx		    ; 11 LD C,RL (IX + d) // LD C,RL (IY + d)
	dw	d_rlx		    ; 12 LD D,RL (IX + d) // LD D,RL (IY + d)
	dw	e_rlx		    ; 13 LD E,RL (IX + d) // LD E,RL (IY + d)
	dw	h_rlx		    ; 14 LD H,RL (IX + d) // LD H,RL (IY + d)
	dw	l_rlx		    ; 15 LD L,RL (IX + d) // LD L,RL (IY + d)
	dw	rlx		    ; 16 RL (IX + d) // RL (IY + d)
	dw	a_rlx		    ; 17 LD A,RL (IX + d) // LD A,RL (IY + d)
	dw	b_rrx		    ; 18 LD B,RR (IX + d) // LD B,RR (IY + d)
	dw	c_rrx		    ; 19 LD C,RR (IX + d) // LD C,RR (IY + d)
	dw	d_rrx		    ; 1a LD D,RR (IX + d) // LD D,RR (IY + d)
	dw	e_rrx		    ; 1b LD E,RR (IX + d) // LD E,RR (IY + d)
	dw	h_rrx		    ; 1c LD H,RR (IX + d) // LD H,RR (IY + d)
	dw	l_rrx		    ; 1d LD L,RR (IX + d) // LD L,RR (IY + d)
	dw	rrx_		     ; 1e RR (IX + d) // RR (IY + d)
	dw	a_rrx		    ; 1f LD A,RR (IX + d) // LD A,RR (IY + d)
	dw	b_slax		    ; 20 LD B,SLA (IX + d) // LD B,SLA (IY + d)
	dw	c_slax		    ; 21 LD C,SLA (IX + d) // LD C,SLA (IY + d)
	dw	d_slax		    ; 22 LD D,SLA (IX + d) // LD D,SLA (IY + d)
	dw	e_slax		    ; 23 LD E,SLA (IX + d) // LD E,SLA (IY + d)
	dw	h_slax		    ; 24 LD H,SLA (IX + d) // LD H,SLA (IY + d)
	dw	l_slax		    ; 25 LD L,SLA (IX + d) // LD L,SLA (IY + d)
	dw	slax		    ; 26 SLA (IX + d) // SLA (IY + d)
	dw	a_slax		    ; 27 LD A,SLA (IX + d) // LD A,SLA (IY + d)
	dw	b_srax		    ; 28 LD B,SRA (IX + d) // LD B,SRA (IY + d)
	dw	c_srax		    ; 29 LD C,SRA (IX + d) // LD C,SRA (IY + d)
	dw	d_srax		    ; 2a LD D,SRA (IX + d) // LD D,SRA (IY + d)
	dw	e_srax		    ; 2b LD E,SRA (IX + d) // LD E,SRA (IY + d)
	dw	h_srax		    ; 2c LD H,SRA (IX + d) // LD H,SRA (IY + d)
	dw	l_srax		    ; 2d LD L,SRA (IX + d) // LD L,SRA (IY + d)
	dw	srax		    ; 2e SRA (IX + d) // SRA (IY + d)
	dw	a_srax		    ; 2f LD A,SRA (IX + d) // LD A,SRA (IY + d)
	dw	b_sllx		    ; 30 LD B,SLL (IX + d) // LD B,SLL (IY + d)
	dw	c_sllx		    ; 31 LD C,SLL (IX + d) // LD C,SLL (IY + d)
	dw	d_sllx		    ; 32 LD D,SLL (IX + d) // LD D,SLL (IY + d)
	dw	e_sllx		    ; 33 LD E,SLL (IX + d) // LD E,SLL (IY + d)
	dw	h_sllx		    ; 34 LD H,SLL (IX + d) // LD H,SLL (IY + d)
	dw	l_sllx		    ; 35 LD L,SLL (IX + d) // LD L,SLL (IY + d)
	dw	sllx		    ; 36 SLL (IX + d) // SLL (IY + d)
	dw	a_sllx		    ; 37 LD A,SLL (IX + d) // LD A,SLL (IY + d)
	dw	b_srlx		    ; 38 LD B,SRL (IX + d) // LD B,SRL (IY + d)
	dw	c_srlx		    ; 39 LD C,SRL (IX + d) // LD C,SRL (IY + d)
	dw	d_srlx		    ; 3a LD D,SRL (IX + d) // LD D,SRL (IY + d)
	dw	e_srlx		    ; 3b LD E,SRL (IX + d) // LD E,SRL (IY + d)
	dw	h_srlx		    ; 3c LD H,SRL (IX + d) // LD H,SRL (IY + d)
	dw	l_srlx		    ; 3d LD L,SRL (IX + d) // LD L,SRL (IY + d)
	dw	srlx		    ; 3e SRL (IX + d) // SRL (IY + d)
	dw	a_srlx		    ; 3f LD A,SRL (IX + d) // LD A,SRL (IY + d)
	dw	biti0		    ; 40 BIT 0,(IX + d) // BIT 0,(IY + d)
	dw	biti0		    ; 41 BIT 0,(IX + d) // BIT 0,(IY + d)
	dw	biti0		    ; 42 BIT 0,(IX + d) // BIT 0,(IY + d)
	dw	biti0		    ; 43 BIT 0,(IX + d) // BIT 0,(IY + d)
	dw	biti0		    ; 44 BIT 0,(IX + d) // BIT 0,(IY + d)
	dw	biti0		    ; 45 BIT 0,(IX + d) // BIT 0,(IY + d)
	dw	biti0		    ; 46 BIT 0,(IX + d) // BIT 0,(IY + d)
	dw	biti0		    ; 47 BIT 0,(IX + d) // BIT 0,(IY + d)
	dw	biti1		    ; 48 BIT 1,(IX + d) // BIT 1,(IY + d)
	dw	biti1		    ; 49 BIT 1,(IX + d) // BIT 1,(IY + d)
	dw	biti1		    ; 4a BIT 1,(IX + d) // BIT 1,(IY + d)
	dw	biti1		    ; 4b BIT 1,(IX + d) // BIT 1,(IY + d)
	dw	biti1		    ; 4c BIT 1,(IX + d) // BIT 1,(IY + d)
	dw	biti1		    ; 4d BIT 1,(IX + d) // BIT 1,(IY + d)
	dw	biti1		    ; 4e BIT 1,(IX + d) // BIT 1,(IY + d)
	dw	biti1		    ; 4f BIT 1,(IX + d) // BIT 1,(IY + d)
	dw	biti2		    ; 50 BIT 2,(IX + d) // BIT 2,(IY + d)
	dw	biti2		    ; 51 BIT 2,(IX + d) // BIT 2,(IY + d)
	dw	biti2		    ; 52 BIT 2,(IX + d) // BIT 2,(IY + d)
	dw	biti2		    ; 53 BIT 2,(IX + d) // BIT 2,(IY + d)
	dw	biti2		    ; 54 BIT 2,(IX + d) // BIT 2,(IY + d)
	dw	biti2		    ; 55 BIT 2,(IX + d) // BIT 2,(IY + d)
	dw	biti2		    ; 56 BIT 2,(IX + d) // BIT 2,(IY + d)
	dw	biti2		    ; 57 BIT 2,(IX + d) // BIT 2,(IY + d)
	dw	biti3		    ; 58 BIT 3,(IX + d) // BIT 3,(IY + d)
	dw	biti3		    ; 59 BIT 3,(IX + d) // BIT 3,(IY + d)
	dw	biti3		    ; 5a BIT 3,(IX + d) // BIT 3,(IY + d)
	dw	biti3		    ; 5b BIT 3,(IX + d) // BIT 3,(IY + d)
	dw	biti3		    ; 5c BIT 3,(IX + d) // BIT 3,(IY + d)
	dw	biti3		    ; 5d BIT 3,(IX + d) // BIT 3,(IY + d)
	dw	biti3		    ; 5e BIT 3,(IX + d) // BIT 3,(IY + d)
	dw	biti3		    ; 5f BIT 3,(IX + d) // BIT 3,(IY + d)
	dw	biti4		    ; 60 BIT 4,(IX + d) // BIT 4,(IY + d)
	dw	biti4		    ; 61 BIT 4,(IX + d) // BIT 4,(IY + d)
	dw	biti4		    ; 62 BIT 4,(IX + d) // BIT 4,(IY + d)
	dw	biti4		    ; 63 BIT 4,(IX + d) // BIT 4,(IY + d)
	dw	biti4		    ; 64 BIT 4,(IX + d) // BIT 4,(IY + d)
	dw	biti4		    ; 65 BIT 4,(IX + d) // BIT 4,(IY + d)
	dw	biti4		    ; 66 BIT 4,(IX + d) // BIT 4,(IY + d)
	dw	biti4		    ; 67 BIT 4,(IX + d) // BIT 4,(IY + d)
	dw	biti5		    ; 68 BIT 5,(IX + d) // BIT 5,(IY + d)
	dw	biti5		    ; 69 BIT 5,(IX + d) // BIT 5,(IY + d)
	dw	biti5		    ; 6a BIT 5,(IX + d) // BIT 5,(IY + d)
	dw	biti5		    ; 6b BIT 5,(IX + d) // BIT 5,(IY + d)
	dw	biti5		    ; 6c BIT 5,(IX + d) // BIT 5,(IY + d)
	dw	biti5		    ; 6d BIT 5,(IX + d) // BIT 5,(IY + d)
	dw	biti5		    ; 6e BIT 5,(IX + d) // BIT 5,(IY + d)
	dw	biti5		    ; 6f BIT 5,(IX + d) // BIT 5,(IY + d)
	dw	biti6		    ; 70 BIT 6,(IX + d) // BIT 6,(IY + d)
	dw	biti6		    ; 71 BIT 6,(IX + d) // BIT 6,(IY + d)
	dw	biti6		    ; 72 BIT 6,(IX + d) // BIT 6,(IY + d)
	dw	biti6		    ; 73 BIT 6,(IX + d) // BIT 6,(IY + d)
	dw	biti6		    ; 74 BIT 6,(IX + d) // BIT 6,(IY + d)
	dw	biti6		    ; 75 BIT 6,(IX + d) // BIT 6,(IY + d)
	dw	biti6		    ; 76 BIT 6,(IX + d) // BIT 6,(IY + d)
	dw	biti6		    ; 77 BIT 6,(IX + d) // BIT 6,(IY + d)
	dw	biti7		    ; 78 BIT 7,(IX + d) // BIT 7,(IY + d)
	dw	biti7		    ; 79 BIT 7,(IX + d) // BIT 7,(IY + d)
	dw	biti7		    ; 7a BIT 7,(IX + d) // BIT 7,(IY + d)
	dw	biti7		    ; 7b BIT 7,(IX + d) // BIT 7,(IY + d)
	dw	biti7		    ; 7c BIT 7,(IX + d) // BIT 7,(IY + d)
	dw	biti7		    ; 7d BIT 7,(IX + d) // BIT 7,(IY + d)
	dw	biti7		    ; 7e BIT 7,(IX + d) // BIT 7,(IY + d)
	dw	biti7		    ; 7f BIT 7,(IX + d) // BIT 7,(IY + d)
	dw	b_res0x		    ; 80 LD B,RES 0,(IX + d) // LD B,RES 0,(IY + d)
	dw	c_res0x		    ; 81 LD C,RES 0,(IX + d) // LD C,RES 0,(IY + d)
	dw	d_res0x		    ; 82 LD D,RES 0,(IX + d) // LD D,RES 0,(IY + d)
	dw	e_res0x		    ; 83 LD E,RES 0,(IX + d) // LD E,RES 0,(IY + d)
	dw	h_res0x		    ; 84 LD H,RES 0,(IX + d) // LD H,RES 0,(IY + d)
	dw	l_res0x		    ; 85 LD L,RES 0,(IX + d) // LD L,RES 0,(IY + d)
	dw	res0x		    ; 86 RES 0,(IX + d) // RES 0,(IY + d)
	dw	a_res0x		    ; 87 LD A,RES 0,(IX + d) // LD A,RES 0,(IY + d)
	dw	b_res1x		    ; 88 LD B,RES 1,(IX + d) // LD B,RES 1,(IY + d)
	dw	c_res1x		    ; 89 LD C,RES 1,(IX + d) // LD C,RES 1,(IY + d)
	dw	d_res1x		    ; 8a LD D,RES 1,(IX + d) // LD D,RES 1,(IY + d)
	dw	e_res1x		    ; 8b LD E,RES 1,(IX + d) // LD E,RES 1,(IY + d)
	dw	h_res1x		    ; 8c LD H,RES 1,(IX + d) // LD H,RES 1,(IY + d)
	dw	l_res1x		    ; 8d LD L,RES 1,(IX + d) // LD L,RES 1,(IY + d)
	dw	res1x		    ; 8e RES 1,(IX + d) // RES 1,(IY + d)
	dw	a_res1x		    ; 8f LD A,RES 1,(IX + d) // LD A,RES 1,(IY + d)
	dw	b_res2x		    ; 90 LD B,RES 2,(IX + d) // LD B,RES 2,(IY + d)
	dw	c_res2x		    ; 91 LD C,RES 2,(IX + d) // LD C,RES 2,(IY + d)
	dw	d_res2x		    ; 92 LD D,RES 2,(IX + d) // LD D,RES 2,(IY + d)
	dw	e_res2x		    ; 93 LD E,RES 2,(IX + d) // LD E,RES 2,(IY + d)
	dw	h_res2x		    ; 94 LD H,RES 2,(IX + d) // LD H,RES 2,(IY + d)
	dw	l_res2x		    ; 95 LD L,RES 2,(IX + d) // LD L,RES 2,(IY + d)
	dw	res2x		    ; 96 RES 2,(IX + d) // RES 2,(IY + d)
	dw	a_res2x		    ; 97 LD A,RES 2,(IX + d) // LD A,RES 2,(IY + d)
	dw	b_res3x		    ; 98 LD B,RES 3,(IX + d) // LD B,RES 3,(IY + d)
	dw	c_res3x		    ; 99 LD C,RES 3,(IX + d) // LD C,RES 3,(IY + d)
	dw	d_res3x		    ; 9a LD D,RES 3,(IX + d) // LD D,RES 3,(IY + d)
	dw	e_res3x		    ; 9b LD E,RES 3,(IX + d) // LD E,RES 3,(IY + d)
	dw	h_res3x		    ; 9c LD H,RES 3,(IX + d) // LD H,RES 3,(IY + d)
	dw	l_res3x		    ; 9d LD L,RES 3,(IX + d) // LD L,RES 3,(IY + d)
	dw	res3x		    ; 9e RES 3,(IX + d) // RES 3,(IY + d)
	dw	a_res3x		    ; 9f LD A,RES 3,(IX + d) // LD A,RES 3,(IY + d)
	dw	b_res4x		    ; a0 LD B,RES 4,(IX + d) // LD B,RES 4,(IY + d)
	dw	c_res4x		    ; a1 LD C,RES 4,(IX + d) // LD C,RES 4,(IY + d)
	dw	d_res4x		    ; a2 LD D,RES 4,(IX + d) // LD D,RES 4,(IY + d)
	dw	e_res4x		    ; a3 LD E,RES 4,(IX + d) // LD E,RES 4,(IY + d)
	dw	h_res4x		    ; a4 LD H,RES 4,(IX + d) // LD H,RES 4,(IY + d)
	dw	l_res4x		    ; a5 LD L,RES 4,(IX + d) // LD L,RES 4,(IY + d)
	dw	res4x		    ; a6 RES 4,(IX + d) // RES 4,(IY + d)
	dw	a_res4x		    ; a7 LD A,RES 4,(IX + d) // LD A,RES 4,(IY + d)
	dw	b_res5x		    ; a8 LD B,RES 5,(IX + d) // LD B,RES 5,(IY + d)
	dw	c_res5x		    ; a9 LD C,RES 5,(IX + d) // LD C,RES 5,(IY + d)
	dw	d_res5x		    ; aa LD D,RES 5,(IX + d) // LD D,RES 5,(IY + d)
	dw	e_res5x		    ; ab LD E,RES 5,(IX + d) // LD E,RES 5,(IY + d)
	dw	h_res5x		    ; ac LD H,RES 5,(IX + d) // LD H,RES 5,(IY + d)
	dw	l_res5x		    ; ad LD L,RES 5,(IX + d) // LD L,RES 5,(IY + d)
	dw	res5x		    ; ae RES 5,(IX + d) // RES 5,(IY + d)
	dw	a_res5x		    ; af LD A,RES 5,(IX + d) // LD A,RES 5,(IY + d)
	dw	b_res6x		    ; b0 LD B,RES 6,(IX + d) // LD B,RES 6,(IY + d)
	dw	c_res6x		    ; b1 LD C,RES 6,(IX + d) // LD C,RES 6,(IY + d)
	dw	d_res6x		    ; b2 LD D,RES 6,(IX + d) // LD D,RES 6,(IY + d)
	dw	e_res6x		    ; b3 LD E,RES 6,(IX + d) // LD E,RES 6,(IY + d)
	dw	h_res6x		    ; b4 LD H,RES 6,(IX + d) // LD H,RES 6,(IY + d)
	dw	l_res6x		    ; b5 LD L,RES 6,(IX + d) // LD L,RES 6,(IY + d)
	dw	res6x		    ; b6 RES 6,(IX + d) // RES 6,(IY + d)
	dw	a_res6x		    ; b7 LD A,RES 6,(IX + d) // LD A,RES 6,(IY + d)
	dw	b_res7x		    ; b8 LD B,RES 7,(IX + d) // LD B,RES 7,(IY + d)
	dw	c_res7x		    ; b9 LD C,RES 7,(IX + d) // LD C,RES 7,(IY + d)
	dw	d_res7x		    ; ba LD D,RES 7,(IX + d) // LD D,RES 7,(IY + d)
	dw	e_res7x		    ; bb LD E,RES 7,(IX + d) // LD E,RES 7,(IY + d)
	dw	h_res7x		    ; bc LD H,RES 7,(IX + d) // LD H,RES 7,(IY + d)
	dw	l_res7x		    ; bd LD L,RES 7,(IX + d) // LD L,RES 7,(IY + d)
	dw	res7x		    ; be RES 7,(IX + d) // RES 7,(IY + d)
	dw	a_res7x		    ; bf LD A,RES 7,(IX + d) // LD A,RES 7,(IY + d)
	dw	b_set0x		    ; c0 LD B,SET 0,(IX + d) // LD B,SET 0,(IY + d)
	dw	c_set0x		    ; c1 LD C,SET 0,(IX + d) // LD C,SET 0,(IY + d)
	dw	d_set0x		    ; c2 LD D,SET 0,(IX + d) // LD D,SET 0,(IY + d)
	dw	e_set0x		    ; c3 LD E,SET 0,(IX + d) // LD E,SET 0,(IY + d)
	dw	h_set0x		    ; c4 LD H,SET 0,(IX + d) // LD H,SET 0,(IY + d)
	dw	l_set0x		    ; c5 LD L,SET 0,(IX + d) // LD L,SET 0,(IY + d)
	dw	set0x		    ; c6 SET 0,(IX + d) // SET 0,(IY + d)
	dw	a_set0x		    ; c7 LD A,SET 0,(IX + d) // LD A,SET 0,(IY + d)
	dw	b_set1x		    ; c8 LD B,SET 1,(IX + d) // LD B,SET 1,(IY + d)
	dw	c_set1x		    ; c9 LD C,SET 1,(IX + d) // LD C,SET 1,(IY + d)
	dw	d_set1x		    ; ca LD D,SET 1,(IX + d) // LD D,SET 1,(IY + d)
	dw	e_set1x		    ; cb LD E,SET 1,(IX + d) // LD E,SET 1,(IY + d)
	dw	h_set1x		    ; cc LD H,SET 1,(IX + d) // LD H,SET 1,(IY + d)
	dw	l_set1x		    ; cd LD L,SET 1,(IX + d) // LD L,SET 1,(IY + d)
	dw	set1x		    ; ce SET 1,(IX + d) // SET 1,(IY + d)
	dw	a_set1x		    ; cf LD A,SET 1,(IX + d) // LD A,SET 1,(IY + d)
	dw	b_set2x		    ; d0 LD B,SET 2,(IX + d) // LD B,SET 2,(IY + d)
	dw	c_set2x		    ; d1 LD C,SET 2,(IX + d) // LD C,SET 2,(IY + d)
	dw	d_set2x		    ; d2 LD D,SET 2,(IX + d) // LD D,SET 2,(IY + d)
	dw	e_set2x		    ; d3 LD E,SET 2,(IX + d) // LD E,SET 2,(IY + d)
	dw	h_set2x		    ; d4 LD H,SET 2,(IX + d) // LD H,SET 2,(IY + d)
	dw	l_set2x		    ; d5 LD L,SET 2,(IX + d) // LD L,SET 2,(IY + d)
	dw	set2x		    ; d6 SET 2,(IX + d) // SET 2,(IY + d)
	dw	a_set2x		    ; d7 LD A,SET 2,(IX + d) // LD A,SET 2,(IY + d)
	dw	b_set3x		    ; d8 LD B,SET 3,(IX + d) // LD B,SET 3,(IY + d)
	dw	c_set3x		    ; d9 LD C,SET 3,(IX + d) // LD C,SET 3,(IY + d)
	dw	d_set3x		    ; da LD D,SET 3,(IX + d) // LD D,SET 3,(IY + d)
	dw	e_set3x		    ; db LD E,SET 3,(IX + d) // LD E,SET 3,(IY + d)
	dw	h_set3x		    ; dc LD H,SET 3,(IX + d) // LD H,SET 3,(IY + d)
	dw	l_set3x		    ; dd LD L,SET 3,(IX + d) // LD L,SET 3,(IY + d)
	dw	set3x		    ; de SET 3,(IX + d) // SET 3,(IY + d)
	dw	a_set3x		    ; df LD A,SET 3,(IX + d) // LD A,SET 3,(IY + d)
	dw	b_set4x		    ; e0 LD B,SET 4,(IX + d) // LD B,SET 4,(IY + d)
	dw	c_set4x		    ; e1 LD C,SET 4,(IX + d) // LD C,SET 4,(IY + d)
	dw	d_set4x		    ; e2 LD D,SET 4,(IX + d) // LD D,SET 4,(IY + d)
	dw	e_set4x		    ; e3 LD E,SET 4,(IX + d) // LD E,SET 4,(IY + d)
	dw	h_set4x		    ; e4 LD H,SET 4,(IX + d) // LD H,SET 4,(IY + d)
	dw	l_set4x		    ; e5 LD L,SET 4,(IX + d) // LD L,SET 4,(IY + d)
	dw	set4x		    ; e6 SET 4,(IX + d) // SET 4,(IY + d)
	dw	a_set4x		    ; e7 LD A,SET 4,(IX + d) // LD A,SET 4,(IY + d)
	dw	b_set5x		    ; e8 LD B,SET 5,(IX + d) // LD B,SET 5,(IY + d)
	dw	c_set5x		    ; e9 LD C,SET 5,(IX + d) // LD C,SET 5,(IY + d)
	dw	d_set5x		    ; ea LD D,SET 5,(IX + d) // LD D,SET 5,(IY + d)
	dw	e_set5x		    ; eb LD E,SET 5,(IX + d) // LD E,SET 5,(IY + d)
	dw	h_set5x		    ; ec LD H,SET 5,(IX + d) // LD H,SET 5,(IY + d)
	dw	l_set5x		    ; ed LD L,SET 5,(IX + d) // LD L,SET 5,(IY + d)
	dw	set5x		    ; ee SET 5,(IX + d) // SET 5,(IY + d)
	dw	a_set5x		    ; ef LD A,SET 5,(IX + d) // LD A,SET 5,(IY + d)
	dw	b_set6x		    ; f0 LD B,SET 6,(IX + d) // LD B,SET 6,(IY + d)
	dw	c_set6x		    ; f1 LD C,SET 6,(IX + d) // LD C,SET 6,(IY + d)
	dw	d_set6x		    ; f2 LD D,SET 6,(IX + d) // LD D,SET 6,(IY + d)
	dw	e_set6x		    ; f3 LD E,SET 6,(IX + d) // LD E,SET 6,(IY + d)
	dw	h_set6x		    ; f4 LD H,SET 6,(IX + d) // LD H,SET 6,(IY + d)
	dw	l_set6x		    ; f5 LD L,SET 6,(IX + d) // LD L,SET 6,(IY + d)
	dw	set6x		    ; f6 SET 6,(IX + d) // SET 6,(IY + d)
	dw	a_set6x		    ; f7 LD A,SET 6,(IX + d) // LD A,SET 6,(IY + d)
	dw	b_set7x		    ; f8 LD B,SET 7,(IX + d) // LD B,SET 7,(IY + d)
	dw	c_set7x		    ; f9 LD C,SET 7,(IX + d) // LD C,SET 7,(IY + d)
	dw	d_set7x		    ; fa LD D,SET 7,(IX + d) // LD D,SET 7,(IY + d)
	dw	e_set7x		    ; fb LD E,SET 7,(IX + d) // LD E,SET 7,(IY + d)
	dw	h_set7x		    ; fc LD H,SET 7,(IX + d) // LD H,SET 7,(IY + d)
	dw	l_set7x		    ; fd LD L,SET 7,(IX + d) // LD L,SET 7,(IY + d)
	dw	set7x		    ; fe SET 7,(IX + d) // SET 7,(IY + d)
	dw	a_set7x		    ; ff LD A,SET 7,(IX + d) // LD A,SET 7,(IY + d)

exit:	orrs	stlo, stlo
	bpl	exec1
      if fast = 0
	movs	lr, arvpref, lsl 24
	bne	exec1
      end if
	pop	{pc}
