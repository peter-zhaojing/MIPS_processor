.section    .start
.global     _start

_start:

# Test 1
lw $t0, 0($0)
lw $t1, 1($0)
lw $t2, 2($0)
lw $t3, 3($0)


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
