.section    .start
.global     _start

_start:

# Test 1
lw $t0, 268435456($0)		#read DMEM address0
lw $t1, 268435460($0)		#read DMEM address1
lb $t2, 1($0)
lbu $t3, 1($0)
addiu $t4, $t0, 1
addu $t5, $t0, $t1
subu $t6, $t0, $t1
and $t7, $t0, $t1
or	$t8, $t0, $t1
xor $t9, $t0, $t1
nor $s0, $t0, $t1
slt $s1, $t0, $t1
sltu $s2, $t0, $t1
sll $s3, $t0, 5
srl $s4, $t0, 5
sra $s5, $t0, 5
sllv $s6, $t0, $t1
srlv $s7, $t0, $t1
srav $t3, $t0, $t1

# Test 1
#lw $t0, 268435456($0)		#read DMEM address0
#lw $t1, 2147483660($0)		#read IO
#lb $t2, 1($0)
#lbu $t3, 1($0)
#addiu $t4, $t0, 1
#slti $t5, $t0, 3648
#sltiu $t6, $t0, 3648
#andi $t7, $t1, 49392
#ori	$t8, $t1, 49392
#xori $t9, $t1, 49392

#sw $t0, 268435464($0)		#sw DMEM address8
#sw $t0, 536870916($0)		#sw IMEM address4
#sw $t0,	805306380($0)		#sw IMEM+DMEM address12
#sw $t0, 2147483656($0)		#sw IO


# Test I instruction
#lw $t0, 0($0)		#read DMEM address0
#lw $t1, 1($0)		
#lw $t2, 2($0)
#addiu $t3, $0, 1

#li $s0, 0x00000020 addiu $t0, $0, 0x20
#addiu $s7, $s7, 1 # register to hold the test number (in case of failure)
#bne $t0, $s0, Error
#j Done
#
#Error:
## Perhaps write the test number over serial
#
#Done:
## Write success over serial
