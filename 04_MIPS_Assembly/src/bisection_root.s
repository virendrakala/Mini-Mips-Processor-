    .data
str_sol:    .asciiz "Solution: "
str_calls:  .asciiz "\nNumber of calls: "
newline:    .asciiz "\n"
call_count: .word  0
threshold:  .float 0.0000076293945
x0_init:    .float 0.0
x1_init:    .float 1.0
const2:     .float 2.0
const1pt5:  .float 1.5

    .text
    .globl main

# f_eval: computes x^3 + x^2 + x - 1.5
# Input: $f12 = x    Output: $f0 = f(x)
f_eval:
    mul.s  $f2, $f12, $f12
    mul.s  $f4, $f2,  $f12
    add.s  $f0, $f4,  $f2
    add.s  $f0, $f0,  $f12
    lwc1   $f6, const1pt5
    sub.s  $f0, $f0,  $f6
    jr     $ra

# bisect: recursive bisection
# Input: $f12 = x0, $f14 = x1    Output: $f0 = root
bisect:
    addi   $sp, $sp, -24
    sw     $ra,  0($sp)
    swc1   $f20, 8($sp)
    swc1   $f22, 12($sp)
    swc1   $f24, 16($sp)

    lw     $t0, call_count
    addi   $t0, $t0, 1
    sw     $t0, call_count

    mov.s  $f20, $f12
    mov.s  $f22, $f14

    add.s  $f24, $f20, $f22
    lwc1   $f6, const2
    div.s  $f24, $f24, $f6

    mov.s  $f12, $f24
    jal    f_eval
    abs.s  $f2, $f0
    lwc1   $f4, threshold
    c.le.s $f2, $f4
    bc1t   found_root

    mov.s  $f12, $f20
    jal    f_eval
    mov.s  $f10, $f0

    mov.s  $f12, $f24
    jal    f_eval
    mul.s  $f8, $f10, $f0
    mfc1   $t1, $f8
    slt    $t2, $t1, $zero
    bne    $t2, $zero, go_left

    mov.s  $f12, $f24
    mov.s  $f14, $f22
    jal    bisect
    j      ret

go_left:
    mov.s  $f12, $f20
    mov.s  $f14, $f24
    jal    bisect
    j      ret

found_root:
    mov.s  $f0, $f24

ret:
    lw     $ra,  0($sp)
    lwc1   $f20, 8($sp)
    lwc1   $f22, 12($sp)
    lwc1   $f24, 16($sp)
    addi   $sp, $sp, 24
    jr     $ra

main:
    sw     $zero, call_count
    lwc1   $f12, x0_init
    lwc1   $f14, x1_init
    jal    bisect

    la     $a0, str_sol
    li     $v0, 4
    syscall

    mov.s  $f12, $f0
    li     $v0, 2
    syscall

    la     $a0, str_calls
    li     $v0, 4
    syscall

    lw     $a0, call_count
    li     $v0, 1
    syscall

    la     $a0, newline
    li     $v0, 4
    syscall

    li     $v0, 10
    syscall
