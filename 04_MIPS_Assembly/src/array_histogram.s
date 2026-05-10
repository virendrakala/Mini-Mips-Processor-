    .data
filename:   .asciiz "/home/CHANGE_THIS/lab11/q1_input.txt"
buf:        .space 1
histogram:  .word 0,0,0,0,0,0,0,0,0,0,0
newline:    .asciiz "\n"
hdr:        .asciiz "Histogram:\n"
lbl0:       .asciiz "[1, 10]: "
lbl1:       .asciiz "[11, 20]: "
lbl2:       .asciiz "[21, 30]: "
lbl3:       .asciiz "[31, 40]: "
lbl4:       .asciiz "[41, 50]: "
lbl5:       .asciiz "[51, 60]: "
lbl6:       .asciiz "[61, 70]: "
lbl7:       .asciiz "[71, 80]: "
lbl8:       .asciiz "[81, 90]: "
lbl9:       .asciiz "[91, 100]: "
lbl10:      .asciiz "> 100: "

    .text
    .globl main
main:
    la   $a0, filename
    li   $a1, 0
    li   $a2, 0
    li   $v0, 13
    syscall
    move $s0, $v0
    li   $s1, 0
    li   $s2, 0

read_loop:
    move $a0, $s0
    la   $a1, buf
    li   $a2, 1
    li   $v0, 14
    syscall
    blez $v0, end_of_file
    lb   $t0, buf
    li   $t1, 10
    beq  $t0, $t1, end_of_line
    li   $t1, 48
    sub  $t0, $t0, $t1
    mul  $s1, $s1, 10
    add  $s1, $s1, $t0
    li   $s2, 1
    j    read_loop

end_of_line:
    beqz $s2, skip_line
    beqz $s1, end_of_file
    bgt  $s1, 100, bucket_over100
    li   $t1, 1
    sub  $t0, $s1, $t1
    li   $t1, 10
    div  $t0, $t1
    mflo $t2
    la   $t3, histogram
    sll  $t2, $t2, 2
    add  $t3, $t3, $t2
    lw   $t4, 0($t3)
    addi $t4, $t4, 1
    sw   $t4, 0($t3)
    j    reset_line

bucket_over100:
    la   $t3, histogram
    lw   $t4, 40($t3)
    addi $t4, $t4, 1
    sw   $t4, 40($t3)

reset_line:
    li   $s1, 0
    li   $s2, 0
skip_line:
    j    read_loop

end_of_file:
    move $a0, $s0
    li   $v0, 16
    syscall

    la   $a0, hdr
    li   $v0, 4
    syscall

    la   $t5, histogram
    li   $t6, 0

print_loop:
    bge  $t6, 11, done
    beq  $t6, 0,  pl0
    beq  $t6, 1,  pl1
    beq  $t6, 2,  pl2
    beq  $t6, 3,  pl3
    beq  $t6, 4,  pl4
    beq  $t6, 5,  pl5
    beq  $t6, 6,  pl6
    beq  $t6, 7,  pl7
    beq  $t6, 8,  pl8
    beq  $t6, 9,  pl9
    beq  $t6, 10, pl10
pl0:  la $a0, lbl0;  j print_lbl
pl1:  la $a0, lbl1;  j print_lbl
pl2:  la $a0, lbl2;  j print_lbl
pl3:  la $a0, lbl3;  j print_lbl
pl4:  la $a0, lbl4;  j print_lbl
pl5:  la $a0, lbl5;  j print_lbl
pl6:  la $a0, lbl6;  j print_lbl
pl7:  la $a0, lbl7;  j print_lbl
pl8:  la $a0, lbl8;  j print_lbl
pl9:  la $a0, lbl9;  j print_lbl
pl10: la $a0, lbl10; j print_lbl

print_lbl:
    li   $v0, 4
    syscall
    sll  $t9, $t6, 2
    add  $t9, $t5, $t9
    lw   $a0, 0($t9)
    li   $v0, 1
    syscall
    la   $a0, newline
    li   $v0, 4
    syscall
    addi $t6, $t6, 1
    j    print_loop

done:
    li   $v0, 10
    syscall
