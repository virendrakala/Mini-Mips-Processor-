    .data
prompt:     .asciiz "Enter x in degrees: "
str_tan:    .asciiz "tan(x) = "
newline:    .asciiz "\n"
pi_bits:    .word   0x40490fdb
f180:       .float  180.0
f1:         .float  1.0

    .text
    .globl main

# compute_sin: 10-term Maclaurin for sin(x)
# Input: $f12 = x (radians)    Output: $f0 = sin(x)
compute_sin:
    mov.s  $f6, $f12
    mov.s  $f2, $f12
    mul.s  $f4, $f12, $f12
    li     $t0, 1
sin_loop:
    bgt    $t0, 9, sin_done
    sll    $t1, $t0, 1
    addi   $t2, $t1, 1
    mul    $t3, $t1, $t2
    mtc1   $t3, $f8
    cvt.s.w $f8, $f8
    neg.s  $f10, $f4
    mul.s  $f2, $f2, $f10
    div.s  $f2, $f2, $f8
    add.s  $f6, $f6, $f2
    addi   $t0, $t0, 1
    j      sin_loop
sin_done:
    mov.s  $f0, $f6
    jr     $ra

# compute_cos: 10-term Maclaurin for cos(x)
# Input: $f12 = x (radians)    Output: $f0 = cos(x)
compute_cos:
    lwc1   $f6, f1
    lwc1   $f2, f1
    mul.s  $f4, $f12, $f12
    li     $t0, 1
cos_loop:
    bgt    $t0, 9, cos_done
    sll    $t1, $t0, 1
    addi   $t2, $t1, -1
    mul    $t3, $t2, $t1
    mtc1   $t3, $f8
    cvt.s.w $f8, $f8
    neg.s  $f10, $f4
    mul.s  $f2, $f2, $f10
    div.s  $f2, $f2, $f8
    add.s  $f6, $f6, $f2
    addi   $t0, $t0, 1
    j      cos_loop
cos_done:
    mov.s  $f0, $f6
    jr     $ra

main:
    la     $a0, prompt
    li     $v0, 4
    syscall

    li     $v0, 6
    syscall

    lw     $t0, pi_bits
    mtc1   $t0, $f2
    lwc1   $f4, f180
    div.s  $f2, $f2, $f4
    mul.s  $f20, $f0, $f2

    mov.s  $f12, $f20
    jal    compute_sin
    mov.s  $f22, $f0

    mov.s  $f12, $f20
    jal    compute_cos
    mov.s  $f24, $f0

    div.s  $f26, $f22, $f24

    la     $a0, str_tan
    li     $v0, 4
    syscall

    mov.s  $f12, $f26
    li     $v0, 2
    syscall

    la     $a0, newline
    li     $v0, 4
    syscall

    li     $v0, 10
    syscall
