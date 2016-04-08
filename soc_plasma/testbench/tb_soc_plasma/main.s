	.file	1 "main.c"
	.section .mdebug.abi32
	.previous
	.gnu_attribute 4, 3
	.section	.rodata.str1.4,"aMS",@progbits,1
	.align	2
$LC0:
	.ascii	"\012\000"
	.text
	.align	2
	.globl	my_printf
	.set	nomips16
	.ent	my_printf
	.type	my_printf, @function
my_printf:
	.frame	$sp,32,$31		# vars= 8, regs= 1/0, args= 16, gp= 0
	.mask	0x80000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-32
	sw	$31,28($sp)
	jal	puts
	sw	$5,16($sp)

	lw	$5,16($sp)
	jal	print_int
	move	$4,$5

	lui	$4,%hi($LC0)
	lw	$31,28($sp)
	addiu	$4,$4,%lo($LC0)
	j	puts
	addiu	$sp,$sp,32

	.set	macro
	.set	reorder
	.end	my_printf
	.size	my_printf, .-my_printf
	.section	.rodata.str1.4
	.align	2
$LC1:
	.ascii	" = \000"
	.text
	.align	2
	.globl	my_printfh
	.set	nomips16
	.ent	my_printfh
	.type	my_printfh, @function
my_printfh:
	.frame	$sp,32,$31		# vars= 8, regs= 1/0, args= 16, gp= 0
	.mask	0x80000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-32
	sw	$31,28($sp)
	sw	$6,20($sp)
	jal	puts
	sw	$5,16($sp)

	lw	$5,16($sp)
	jal	print_hex
	move	$4,$5

	lui	$2,%hi($LC1)
	jal	puts
	addiu	$4,$2,%lo($LC1)

	lw	$6,20($sp)
	jal	print_int
	move	$4,$6

	lui	$4,%hi($LC0)
	lw	$31,28($sp)
	addiu	$4,$4,%lo($LC0)
	j	puts
	addiu	$sp,$sp,32

	.set	macro
	.set	reorder
	.end	my_printfh
	.size	my_printfh, .-my_printfh
	.align	2
	.globl	my_printh
	.set	nomips16
	.ent	my_printh
	.type	my_printh, @function
my_printh:
	.frame	$sp,24,$31		# vars= 0, regs= 2/0, args= 16, gp= 0
	.mask	0x80010000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-24
	sw	$31,20($sp)
	sw	$16,16($sp)
	jal	print_hex
	move	$16,$4

	lui	$2,%hi($LC1)
	jal	puts
	addiu	$4,$2,%lo($LC1)

	lw	$4,0($16)
	jal	print_hex
	nop

	lui	$4,%hi($LC0)
	lw	$31,20($sp)
	lw	$16,16($sp)
	addiu	$4,$4,%lo($LC0)
	j	puts
	addiu	$sp,$sp,24

	.set	macro
	.set	reorder
	.end	my_printh
	.size	my_printh, .-my_printh
	.section	.rodata.str1.4
	.align	2
$LC2:
	.ascii	"tps soft=\000"
	.align	2
$LC3:
	.ascii	"l \000"
	.align	2
$LC4:
	.ascii	"tps exec :\000"
	.align	2
$LC5:
	.ascii	"fin du programme:\012\000"
	.text
	.align	2
	.globl	main
	.set	nomips16
	.ent	main
	.type	main, @function
main:
	.frame	$sp,224,$31		# vars= 144, regs= 10/0, args= 40, gp= 0
	.mask	0xc0ff0000,-4
	.fmask	0x00000000,0
	addiu	$sp,$sp,-224
	addiu	$4,$sp,40
	move	$5,$0
	li	$6,2457			# 0x999
	li	$7,7680			# 0x1e00
	sw	$31,220($sp)
	sw	$fp,216($sp)
	sw	$23,212($sp)
	sw	$22,208($sp)
	sw	$21,204($sp)
	sw	$20,200($sp)
	sw	$19,196($sp)
	sw	$18,192($sp)
	sw	$17,188($sp)
	.set	noreorder
	.set	nomacro
	jal	MathVec3Set
	sw	$16,184($sp)
	.set	macro
	.set	reorder

	lw	$4,40($sp)
	lw	$5,44($sp)
	lw	$6,48($sp)
	li	$11,4			# 0x4
	li	$7,204			# 0xcc
	.set	noreorder
	.set	nomacro
	jal	RenderSetup
	sw	$11,16($sp)
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	RenderReset
	li	$16,512			# 0x200
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	SphereAdd
	li	$19,1024			# 0x400
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	SphereAdd
	move	$17,$2
	.set	macro
	.set	reorder

	addiu	$4,$sp,64
	move	$5,$0
	li	$6,2048			# 0x800
	move	$7,$0
	.set	noreorder
	.set	nomacro
	jal	MathVec3Set
	sw	$2,168($sp)
	.set	macro
	.set	reorder

	lw	$8,72($sp)
	lw	$10,64($sp)
	lw	$9,68($sp)
	li	$3,1			# 0x1
	move	$4,$17
	li	$5,-1228			# 0xfffffffffffffb34
	li	$6,2048			# 0x800
	li	$7,8192			# 0x2000
	sw	$8,28($sp)
	sw	$3,32($sp)
	sw	$10,20($sp)
	sw	$9,24($sp)
	.set	noreorder
	.set	nomacro
	jal	SphereSet
	sw	$16,16($sp)
	.set	macro
	.set	reorder

	addiu	$4,$sp,76
	move	$5,$0
	move	$6,$0
	.set	noreorder
	.set	nomacro
	jal	MathVec3Set
	li	$7,2048			# 0x800
	.set	macro
	.set	reorder

	lw	$5,168($sp)
	lw	$25,84($sp)
	lw	$2,76($sp)
	lw	$22,80($sp)
	move	$4,$5
	li	$6,-2048			# 0xfffffffffffff800
	li	$5,-1228			# 0xfffffffffffffb34
	li	$7,7168			# 0x1c00
	sw	$25,28($sp)
	sw	$19,16($sp)
	sw	$2,20($sp)
	sw	$22,24($sp)
	.set	noreorder
	.set	nomacro
	jal	SphereSet
	sw	$0,32($sp)
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	PlaneAdd
	lui	$19,%hi($LC0)
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	PlaneAdd
	move	$fp,$2
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	PlaneAdd
	move	$21,$2
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	PlaneAdd
	move	$18,$2
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	PlaneAdd
	move	$17,$2
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	PlaneAdd
	move	$16,$2
	.set	macro
	.set	reorder

	addiu	$4,$sp,88
	move	$5,$0
	li	$6,2048			# 0x800
	move	$7,$0
	.set	noreorder
	.set	nomacro
	jal	MathVec3Set
	sw	$2,168($sp)
	.set	macro
	.set	reorder

	lw	$24,92($sp)
	lw	$23,96($sp)
	lw	$7,88($sp)
	move	$4,$fp
	move	$5,$0
	li	$6,3072			# 0xc00
	sw	$24,16($sp)
	.set	noreorder
	.set	nomacro
	jal	PlaneSet
	sw	$23,20($sp)
	.set	macro
	.set	reorder

	addiu	$4,$sp,100
	li	$5,2048			# 0x800
	li	$6,2048			# 0x800
	.set	noreorder
	.set	nomacro
	jal	MathVec3Set
	li	$7,2048			# 0x800
	.set	macro
	.set	reorder

	lw	$15,108($sp)
	lw	$20,104($sp)
	lw	$7,100($sp)
	move	$4,$21
	li	$5,1			# 0x1
	li	$6,-3072			# 0xfffffffffffff400
	sw	$15,20($sp)
	.set	noreorder
	.set	nomacro
	jal	PlaneSet
	sw	$20,16($sp)
	.set	macro
	.set	reorder

	addiu	$4,$sp,112
	li	$5,2048			# 0x800
	move	$6,$0
	.set	noreorder
	.set	nomacro
	jal	MathVec3Set
	move	$7,$0
	.set	macro
	.set	reorder

	lw	$14,116($sp)
	lw	$13,120($sp)
	lw	$7,112($sp)
	move	$4,$18
	move	$5,$0
	li	$6,-3072			# 0xfffffffffffff400
	sw	$14,16($sp)
	.set	noreorder
	.set	nomacro
	jal	PlaneSet
	sw	$13,20($sp)
	.set	macro
	.set	reorder

	addiu	$4,$sp,124
	li	$5,2048			# 0x800
	li	$6,2048			# 0x800
	.set	noreorder
	.set	nomacro
	jal	MathVec3Set
	li	$7,2048			# 0x800
	.set	macro
	.set	reorder

	lw	$12,128($sp)
	lw	$11,132($sp)
	lw	$7,124($sp)
	move	$4,$17
	li	$5,1			# 0x1
	li	$6,3072			# 0xc00
	sw	$12,16($sp)
	.set	noreorder
	.set	nomacro
	jal	PlaneSet
	sw	$11,20($sp)
	.set	macro
	.set	reorder

	addiu	$4,$sp,136
	li	$5,2048			# 0x800
	li	$6,2048			# 0x800
	.set	noreorder
	.set	nomacro
	jal	MathVec3Set
	li	$7,2048			# 0x800
	.set	macro
	.set	reorder

	lw	$10,140($sp)
	lw	$9,144($sp)
	lw	$7,136($sp)
	move	$4,$16
	li	$5,2			# 0x2
	li	$6,10240			# 0x2800
	sw	$10,16($sp)
	.set	noreorder
	.set	nomacro
	jal	PlaneSet
	sw	$9,20($sp)
	.set	macro
	.set	reorder

	addiu	$4,$sp,148
	li	$5,2048			# 0x800
	li	$6,2048			# 0x800
	.set	noreorder
	.set	nomacro
	jal	MathVec3Set
	li	$7,2048			# 0x800
	.set	macro
	.set	reorder

	lw	$8,152($sp)
	lw	$3,156($sp)
	lw	$7,148($sp)
	lw	$4,168($sp)
	li	$5,2			# 0x2
	li	$6,-1024			# 0xfffffffffffffc00
	sw	$8,16($sp)
	.set	noreorder
	.set	nomacro
	jal	PlaneSet
	sw	$3,20($sp)
	.set	macro
	.set	reorder

	lui	$22,%hi($LC2)
	li	$2,1073741824			# 0x40000000
	addiu	$19,$19,%lo($LC0)
	sw	$0,144($2)
	move	$18,$0
	addiu	$23,$sp,52
	li	$17,536870912			# 0x20000000
	addiu	$22,$22,%lo($LC2)
	li	$21,-16			# 0xfffffffffffffff0
	li	$20,1073741824			# 0x40000000
	move	$16,$0
$L12:
	move	$6,$16
$L11:
	li	$5,500			# 0x1f4
	move	$7,$18
	.set	noreorder
	.set	nomacro
	jal	RenderComputePixelColor
	move	$4,$23
	.set	macro
	.set	reorder

	lw	$15,96($17)
	lw	$25,52($sp)
	lw	$14,96($17)
	lw	$24,60($sp)
	move	$4,$22
	sw	$14,168($sp)
	lw	$fp,56($sp)
	sw	$25,180($sp)
	sw	$24,176($sp)
	.set	noreorder
	.set	nomacro
	jal	puts
	sw	$15,172($sp)
	.set	macro
	.set	reorder

	lw	$12,172($sp)
	lw	$13,168($sp)
	.set	noreorder
	.set	nomacro
	jal	print_int
	subu	$4,$13,$12
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	puts
	move	$4,$19
	.set	macro
	.set	reorder

	lw	$7,180($sp)
	lw	$11,176($sp)
	mult	$7,$fp
	sra	$9,$7,3
	sra	$6,$fp,3
	sra	$5,$11,7
	and	$fp,$6,$21
	or	$25,$5,$fp
	addiu	$6,$16,1
	li	$5,500			# 0x1f4
	move	$7,$18
	move	$4,$23
	addiu	$16,$16,2
	addiu	$fp,$17,96
	mflo	$10
	sra	$8,$10,11
	addu	$3,$8,$9
	sra	$2,$3,4
	sll	$24,$2,8
	or	$15,$25,$24
	sw	$15,148($20)
	jal	RenderComputePixelColor
	lw	$14,96($17)
	lw	$4,96($17)
	lw	$12,52($sp)
	lw	$13,56($sp)
	lw	$7,60($sp)
	sw	$4,160($sp)
	move	$4,$22
	sw	$14,164($sp)
	sw	$13,180($sp)
	sw	$12,176($sp)
	.set	noreorder
	.set	nomacro
	jal	puts
	sw	$7,172($sp)
	.set	macro
	.set	reorder

	lw	$6,164($sp)
	lw	$11,160($sp)
	.set	noreorder
	.set	nomacro
	jal	print_int
	subu	$4,$11,$6
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	puts
	move	$4,$19
	.set	macro
	.set	reorder

	lw	$9,180($sp)
	lw	$10,176($sp)
	lw	$8,172($sp)
	mult	$10,$9
	sra	$15,$10,3
	sra	$3,$9,3
	sra	$2,$8,7
	and	$5,$3,$21
	or	$4,$2,$5
	li	$6,640			# 0x280
	mflo	$25
	sra	$24,$25,11
	addu	$14,$24,$15
	sra	$13,$14,4
	sll	$12,$13,8
	or	$7,$4,$12
	sw	$7,148($20)
	.set	noreorder
	.set	nomacro
	bne	$16,$6,$L11
	move	$6,$16
	.set	macro
	.set	reorder

	lui	$31,%hi($LC3)
	addiu	$4,$31,%lo($LC3)
	.set	noreorder
	.set	nomacro
	jal	puts
	addiu	$18,$18,1
	.set	macro
	.set	reorder

	lw	$4,160($sp)
	.set	noreorder
	.set	nomacro
	jal	print_int
	li	$16,480			# 0x1e0
	.set	macro
	.set	reorder

	lui	$4,%hi($LC0)
	.set	noreorder
	.set	nomacro
	jal	puts
	addiu	$4,$4,%lo($LC0)
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	bne	$18,$16,$L12
	move	$16,$0
	.set	macro
	.set	reorder

	lui	$23,%hi($LC4)
	addiu	$4,$23,%lo($LC4)
	lw	$21,0($fp)
	.set	noreorder
	.set	nomacro
	jal	puts
	lui	$18,%hi($LC5)
	.set	macro
	.set	reorder

	lw	$20,164($sp)
	.set	noreorder
	.set	nomacro
	jal	print_int
	subu	$4,$21,$20
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	puts
	move	$4,$19
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	puts
	addiu	$4,$18,%lo($LC5)
	.set	macro
	.set	reorder

 #APP
 # 4 "../../c_plasma/ray_tracer_v3/Sources/../../shared/plasmaMisc.h" 1
	break 1
	
 # 0 "" 2
 #NO_APP
	lw	$31,220($sp)
	li	$2,1			# 0x1
	lw	$fp,216($sp)
	lw	$23,212($sp)
	lw	$22,208($sp)
	lw	$21,204($sp)
	lw	$20,200($sp)
	lw	$19,196($sp)
	lw	$18,192($sp)
	lw	$17,188($sp)
	lw	$16,184($sp)
	.set	noreorder
	.set	nomacro
	j	$31
	addiu	$sp,$sp,224
	.set	macro
	.set	reorder

	.end	main
	.size	main, .-main
	.ident	"GCC: (GNU) 4.5.2"
