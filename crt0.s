//-----------------------------------------------
.set noat
.set noreorder

.set arch = r5900

.global ENTRYPOINT
.global __start
.global _start
.global _exit
.global __main

#define STACKSIZE 0x80000
#define HEAPSIZE 0x100000

//-----------------------------------------------
.ent	__start
.text
nop
nop
ENTRYPOINT:
__start:
_start:

// clear .bss
zerobss:
	lui	$2, %hi(__bss_start)
	lui	$3, %hi(_end)
	addiu	$2, $2, %lo(__bss_start)
	addiu	$3, $3, %lo(_end)
1:
	sw	$0, ($2)
	sw	$0, 4($2)
	sw	$0, 8($2)
	sw	$0, 12($2)
	sltu	$1, $2, $3
	nop
	bne	$1, $0, 1b
	addiu	$2, $2, 16

// initialize main thread
	lui	$4, %hi(_gp)
	lui	$5, %hi(_end)
	lui	$6, %hi(STACKSIZE)
	lui	$7, %hi(_args)
	lui	$8, %hi(_root)
	addiu	$4, $4, %lo(_gp)
	addiu	$5, $5, %lo(_end)
	addiu	$6, $6, %lo(STACKSIZE)
	addiu	$7, $7, %lo(_args)
	addiu	$8, $8, %lo(_root)
	move	$28, $4
	addiu	$3, $0, 60
	syscall
	move	$29, $2

// initialize heap area
	lui	$4, %hi(_end + STACKSIZE)
	lui	$5, %hi(HEAPSIZE)
	addiu	$4, $4, %lo(_end + STACKSIZE)
	addiu	$5, $5, %lo(HEAPSIZE)
	addiu	$3, $0, 61
	syscall

	lui	$28, %hi(_gp)
	addiu	$28, %lo(_gp)

// flush data cache
	move	$4, $0
	la	$25, ps2_flush_cache
	jalr	$25
	nop

// call main program
	ei
	lui	$2, %hi(_args)
	addiu	$2, $2, %lo(_args)
	lw	$4, ($2)
	la	$25, main
	jalr	$25
	addiu	$5, $2, 4

	j	Exit
	move	$4, $2
.end	__start

//-----------------------------------------------
.align	3
.ent	_exit
_exit:
	j	Exit
	move	$4, $0
.end	_exit
    
//-----------------------------------------------
.align	3
.ent	_root
_root:
	addiu	$3, $0, 35		# ExitThread();
	syscall
.end	_root

//-----------------------------------------------
.align	3
.ent	__main
__main:
	jr	$31
	nop
.end	__main

//-----------------------------------------------
Exit:
	li	$3,4
	syscall
	jr	$31
	nop

//-----------------------------------------------
.bss
.align	6
_args:
	.space	256 + 16*4 + 1*4
