.section    .start
.global     _start

_start:

# Test 1
lw $t0, 268435456($0)		#read DMEM address0
lw $t1, 2147483660($0)		#read IO
lb $t2, 1($0)
lbu $t3, 1($0)
sw $t0, 268435464($0)		#sw DMEM address8
sw $t0, 536870916($0)		#sw IMEM address4
sw $t0,	805306380($0)		#sw IMEM+DMEM address12
sw $t0, 2147483656($0)		#sw IO


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
