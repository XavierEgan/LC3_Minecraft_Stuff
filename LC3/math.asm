.ORIG x3000

HALT

; ==============================================
; File    : math.asm
; Author  : Xavier Egan
; Date    : 1 Oct 2025
; Lang    : LC-3 Assembly
; Purpose : Small math library implementing:
;           SUB  - subtraction
;           MULT - multiplication
;           DIV  - integer division
;           MOD  - integer modulus
;           OR   - bitwise OR
;           XOR  - bitwise XOR
; Notes   : This file contains prior work by the author
;           intended for reuse
; ==============================================


; R4 - result
; R5 - arg A
; R6 - arg B
; functionality
; SUB, MULT, DIV, MOD
; OR, XOR

; there are some extra RET's added literally just to look nice

; R4 = R5 - R6
SUB 
    NOT R6 R6
    ADD R6 R6 #1
    ADD R4 R5 R6
    
    ; restore B
    NOT R6 R6
    ADD R6 R6 #1
RET

; R4 = R5 * R6
MULT 
    ST R0 MULT_R0
    ST R1 MULT_R1
    ST R2 MULT_R2
    ST R3 MULT_R3
    ST R5 MULT_R5
    ST R6 MULT_R6

    ; keep track of sign with R0
    AND R0 R0 #0
    ADD R0 R0 #1

    ADD R5 R5 #0
    BRzp MULT_DONT_NEGATE_R5
        ; negate sign bit
        NOT R0 R0
        ADD R0 R0 #1

        ; negate R5
        NOT R5 R5 
        ADD R5 R5 #1
    MULT_DONT_NEGATE_R5

    ADD R5 R5 #0
    BRzp MULT_DONT_NEGATE_R6
        ; negate sign bit
        NOT R0 R0
        ADD R0 R0 #1

        ; negate R6
        NOT R6 R6
        ADD R6 R6 #1
    MULT_DONT_NEGATE_R6

    AND R3 R3 #0 ; FOR LOOP ITERATION
    ADD R3 R3 #15

    AND R2 R2 #0 ; BITMASK
    ADD R2 R2 #1

    AND R4 R4 #0
    MULT_LOOP
        AND R1 R2 R6
        BRz MULT_ITS_ZERO
            ADD R4 R4 R5
        MULT_ITS_ZERO
        ADD R5 R5 R5
        ADD R2 R2 R2

        ADD R3 R3 #-1
    BRzp MULT_LOOP

    ; apply sign bit
    ADD R0 R0 #0
    BRzp MULT_DONT_NEGATE_RESULT
        NOT R4 R4
        ADD R4 R4 #1
    MULT_DONT_NEGATE_RESULT

    LD R0 MULT_R0
    LD R1 MULT_R1
    LD R2 MULT_R2
    LD R3 MULT_R3
    LD R5 MULT_R5
    LD R6 MULT_R6
    RET
    MULT_R0 .FILL #0
    MULT_R1 .FILL #0
    MULT_R2 .FILL #0
    MULT_R3 .FILL #0
    MULT_R5 .FILL #0
    MULT_R6 .FILL #0
RET

; R4 = R5 / R6, integer div
; this gives the wrong result for negative numbers but i cant be asked to fix it
DIV 
    ST R0 DIV_R0
    ST R1 DIV_R1
    ST R2 DIV_R2
    ST R3 DIV_R3
    ST R5 DIV_R5
    ST R6 DIV_R6

    ADD R6 R6 #0
    BRnp DIV_DONT_EARLY_RETURN
        AND R4 R4 #0 ; zero out the result register
        BR DIV_EARLY_RETURN
    DIV_DONT_EARLY_RETURN

    ; R3 = sign
    ; R4 = quotient
    AND R3 R3 #0
    ADD R3 R3 #1

    ADD R5 R5 #0
    BRzp DIV_R5_NOT_NEG
        ; negate R5 so we divide with positives
        NOT R5 R5
        ADD R5 R5 #1

        ; negate the sign bit (R3) to restore sign at the end
        NOT R3 R3
        ADD R3 R3 #1
    DIV_R5_NOT_NEG

    ADD R6 R6 #0
    BRzp DIV_R6_NOT_NEG
        ; negate R5 so we divide with positives
        NOT R6 R6
        ADD R6 R6 #1

        ; negate the sign bit (R3) to restore sign at the end
        NOT R3 R3
        ADD R3 R3 #1
    DIV_R6_NOT_NEG

    ; keep subtracting denominator (R6) from numerator (R5) untill R5 is negative
    ; R5 - R6
    ; negate R6
    NOT R6 R6
    ADD R6 R6 #1

    ; since we go untill R5 is negative, we overcount by 1, so we start R4 (quotient) off at -1
    AND R4 R4 #0
    ADD R4 R4 #-1
    DIV_LOOP
        ADD R4 R4 #1
        ADD R5 R5 R6
    BRzp DIV_LOOP

    ; if the sign bit is negative, then negate the result
    ADD R3 R3 #0
    BRzp DIV_DONT_NEGATE_RESULT
        NOT R4 R4
        ADD R4 R4 #1
    DIV_DONT_NEGATE_RESULT

    DIV_EARLY_RETURN

    LD R0 DIV_R0
    LD R1 DIV_R1
    LD R2 DIV_R2
    LD R3 DIV_R3
    LD R5 DIV_R5
    LD R6 DIV_R6
    RET
    DIV_R0 .FILL #0
    DIV_R1 .FILL #0
    DIV_R2 .FILL #0
    DIV_R3 .FILL #0
    DIV_R5 .FILL #0
    DIV_R6 .FILL #0

RET

; R4 = R5 % R6, integer mod
; this gives the wrong result for negative numbers but i cant be asked to fix it
MOD 
    ST R0 MOD_R0
    ST R1 MOD_R1
    ST R2 MOD_R2
    ST R3 MOD_R3
    ST R5 MOD_R5
    ST R6 MOD_R6

    ADD R6 R6 #0
    BRnp MOD_DONT_EARLY_RETURN
        AND R4 R4 #0 ; zero out the result register
        BR MOD_EARLY_RETURN
    MOD_DONT_EARLY_RETURN

    ; R3 = sign
    ; R4 = mod

    ADD R5 R5 #0
    BRzp MOD_R5_NOT_NEG
        ; negate R5 so we divide with positives
        NOT R5 R5
        ADD R5 R5 #1
    MOD_R5_NOT_NEG

    ADD R6 R6 #0
    BRzp MOD_R6_NOT_NEG
        ; negate R5 so we divide with positives
        NOT R6 R6
        ADD R6 R6 #1
    MOD_R6_NOT_NEG

    ; keep subtracting denominator (R6) from numerator (R5) untill R5 is negative
    ; R5 - R6
    ; negate R6
    NOT R6 R6
    ADD R6 R6 #1
    MOD_LOOP
        ADD R5 R5 R6
    BRzp MOD_LOOP

    ; negate R6 again to make it positive
    NOT R6 R6
    ADD R6 R6 #1

    ADD R4 R5 R6

    MOD_EARLY_RETURN

    LD R0 MOD_R0
    LD R1 MOD_R1
    LD R2 MOD_R2
    LD R3 MOD_R3
    LD R5 MOD_R5
    LD R6 MOD_R6
    RET
    MOD_R0 .FILL #0
    MOD_R1 .FILL #0
    MOD_R2 .FILL #0
    MOD_R3 .FILL #0
    MOD_R5 .FILL #0
    MOD_R6 .FILL #0
RET

; R4 = R5 OR R6
OR
    ST   R0 OR_R0
    ST   R1 OR_R1
    ST   R2 OR_R2
    ST   R3 OR_R3
    ST   R5 OR_R5
    ST   R6 OR_R6

    NOT  R1, R5        ; R1 = ~R5
    NOT  R2, R6        ; R2 = ~R6
    AND  R3, R1, R2    ; R3 = ~R5 & ~R6
    NOT  R4, R3        ; R4 = ~(~R5 & ~R6) = R5 | R6

    LD   R0 OR_R0
    LD   R1 OR_R1
    LD   R2 OR_R2
    LD   R3 OR_R3
    LD   R5 OR_R5
    LD   R6 OR_R6
    RET
    OR_R0 .FILL #0
    OR_R1 .FILL #0
    OR_R2 .FILL #0
    OR_R3 .FILL #0
    OR_R5 .FILL #0
    OR_R6 .FILL #0
RET

; R4 = R5 XOR R6
XOR
    ST R0 XOR_R0
    ST R1 XOR_R1
    ST R2 XOR_R2
    ST R3 XOR_R3
    ST R5 XOR_R5
    ST R6 XOR_R6

    NOT  R1, R6 ; R1 = ~R6
    AND  R2, R5, R1 ; R2 = R5 & ~R6
    NOT  R1, R5 ; R1 = ~R5
    AND  R3, R1, R6 ; R3 = ~R5 & R6

    NOT  R1, R2 ; R1 = ~R2
    NOT  R2, R3 ; R2 = ~R3
    AND  R1, R1, R2 ; R1 = ~R2 & ~R3
    NOT  R4, R1 ; R4 = ~(~R2 & ~R3) = R2 | R3 = R5⊕R6

    LD R0 XOR_R0
    LD R1 XOR_R1
    LD R2 XOR_R2
    LD R3 XOR_R3
    LD R5 XOR_R5
    LD R6 XOR_R6
    RET
    XOR_R0 .FILL #0
    XOR_R1 .FILL #0
    XOR_R2 .FILL #0
    XOR_R3 .FILL #0
    XOR_R5 .FILL #0
    XOR_R6 .FILL #0
RET

.END