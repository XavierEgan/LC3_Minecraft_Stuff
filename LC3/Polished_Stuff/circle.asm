; laser -a LC3/Polished_Stuff/circle.asm && lc3 LC3/Polished_Stuff/circle.obj

; dont try this one (it wont work probably)
; laser -a My_Stuff/LC3/Polished_Stuff/circle.asm && lc3 My_Stuff/LC3/Polished_Stuff/circle.obj

.ORIG x3000

JSR CALC_RADII_SQUARED

GETP
ST R0 P_X
ST R1 P_Y
ST R2 P_Z


LD R0 RADII
ST R0 X_
ST R0 Y_
ST R0 Z_

AND R0 R0 #0
AND R1 R1 #0
AND R2 R2 #0
AND R3 R3 #0
AND R4 R4 #0
AND R5 R5 #0
AND R6 R6 #0
AND R7 R7 #0

LOOPX .FILL #0
    ; reset y
    LD R0 RADII
    ST R0 Y_
    LOOPY .FILL #0
        ; reset z
        LD R0 RADII
        ST R0 Z_
        LOOPZ .FILL #0

            JSR SHOULD_PLACE_BLOCK

            LD R0 PLACE_BLOCK_FLAG
            ADD R0 R0 #0
            BRz DONT_PLACE_BLOCK
                LD R3 BLOCK_TYPE
                LD R4 USE_RANDOM_BLOCKS_FLAG
                ADD R4 R4 #0
                BRz DONT_USE_RANDOM_BLOCK
                    JSR GET_RANDOM_BLOCK
                    LD R3 RANDOM_BLOCK
                DONT_USE_RANDOM_BLOCK

                LD R0 P_X
                LD R1 P_Y
                LD R2 P_Z

                LD R4 X_
                ADD R0 R0 R4
                LD R4 Y_
                ADD R1 R1 R4
                LD R4 Z_
                ADD R2 R2 R4

                SETB
            DONT_PLACE_BLOCK .FILL #0

            LD R0 RADII
            LD R1 Z_
            ADD R1 R1 #-1
            ST R1 Z_
            ADD R1 R1 R0
        BRzp LOOPZ

        LD R0 RADII
        LD R1 Y_
        ADD R1 R1 #-1
        ST R1 Y_
        ADD R1 R1 R0
    BRzp LOOPY

    LD R0 RADII
    LD R1 X_
    ADD R1 R1 #-1
    ST R1 X_
    ADD R1 R1 R0
BRzp LOOPX


HALT

RADII .FILL #10 ; radii of the circle
BLOCK_TYPE .FILL #1 ; type of block to use if its not random
BLOCK_RAND_BITMASK .FILL x00FF ; will use blocks from 0 to BLOCK_RAND_BITMASK
USE_RANDOM_BLOCKS_FLAG .FILL #0 ; if we randomise each block placed
EXCLUDE_WATER_AND_LAVA_FLAG .FILL #0 ; this removes water and lava, however it makes 12, 13, 14 and 15 twice as likely as any other block (since it changes water/lava into these)


RADII_2 .FILL #0
RADII_SQUARED .FILL #0
X_ .FILL #0
Y_ .FILL #0
Z_ .FILL #0
P_X .FILL #0
P_Y .FILL #0
P_Z .FILL #0
RANDOM_BLOCK .FILL #0

Y_OFFSET .FILL #100

X_SQUARED .FILL #0
Y_SQUARED .FILL #0
Z_SQUARED .FILL #0
BLOCK_RADII_SQUARED .FILL #0

MULTIPLY_A .FILL #0
MULTIPLY_B .FILL #0
MULTIPLY_RESULT .FILL #0

RAND_SEED .FILL #47935
RAND_MULT .FILL x32D1
RAND_ADD .FILL xEA79
ABS_MASK .FILL x7FFF

PLACE_BLOCK_FLAG .FILL #0 ; 0 means false, 1 means true

SPB_RET .FILL #0
CRS_RET .FILL #0
CBRS_RET .FILL #0
RAND_RET .FILL #0
GRB_RET .FILL #0


SHOULD_PLACE_BLOCK .FILL #0
    ST R7 SPB_RET


    JSR CALC_BLOCK_RADII_SQUARED
    LD R1 BLOCK_RADII_SQUARED
    LD R2 RADII_SQUARED
    NOT R2 R2
    ADD R2 R2 #1
    AND R0 R0 #0
    ADD R3 R1 R2
    BRp DONT_SET_PLACE_BLOCK_FLAG
        ADD R0 R0 #1

        ST R0 PLACE_BLOCK_FLAG
    DONT_SET_PLACE_BLOCK_FLAG

    ST R0 PLACE_BLOCK_FLAG


    LD R7 SPB_RET ; load so we know where to go back to
RET

CALC_RADII_SQUARED .FILL #0
    ST R7 CRS_RET


    LD R0 RADII
    ST R0 MULTIPLY_A
    ST R0 MULTIPLY_B
    JSR MULTIPLY
    LD R0 MULTIPLY_RESULT
    ST R0 RADII_SQUARED


    LD R7 CRS_RET
RET

CALC_BLOCK_RADII_SQUARED .FILL #0
    ST R7 CBRS_RET


    ; C^2 = X^2 + Y^2 + Z^2
    LD R0 X_
    LD R1 X_
    ST R0 MULTIPLY_A
    ST R1 MULTIPLY_B
    JSR MULTIPLY
    LD R0 MULTIPLY_RESULT
    ST R0 X_SQUARED

    LD R0 Y_
    LD R1 Y_
    ST R0 MULTIPLY_A
    ST R1 MULTIPLY_B
    JSR MULTIPLY
    LD R0 MULTIPLY_RESULT
    ST R0 Y_SQUARED

    LD R0 Z_
    LD R1 Z_
    ST R0 MULTIPLY_A
    ST R1 MULTIPLY_B
    JSR MULTIPLY
    LD R0 MULTIPLY_RESULT
    ST R0 Z_SQUARED

    LD R1 X_SQUARED
    LD R2 Y_SQUARED
    AND R0 R0 #0
    ADD R0 R1 R2
    LD R1 Z_SQUARED
    ADD R0 R0 R1

    ST R0 BLOCK_RADII_SQUARED

    LD R7 CBRS_RET
RET

MULTIPLY .FILL #0
    LD R0 MULTIPLY_A
    AND R3 R3 #0 ; R3 is a flag for if A is negative
    ADD R0 R0 #0
    BRzp DONT_NEGATE
        NOT R0 R0
        ADD R0 R0 #1
        ADD R3 R3 #1
    DONT_NEGATE .FILL #0

    LD R1 MULTIPLY_B
    AND R2 R2 #0

    LOOP0 .FILL #0
        ADD R2 R2 R1
        ADD R0 R0 #-1
    BRp LOOP0

    ADD R3 R3 #0
    BRz DONT_NEGATE_END
        NOT R2 R2
        ADD R2 R2 #1
    DONT_NEGATE_END .FILL #0

    ST R2 MULTIPLY_RESULT
RET

RAND .FILL #0
    ST R7 RAND_RET


    LD R0 RAND_SEED
    LD R1 RAND_MULT
    ST R0 MULTIPLY_A
    ST R1 MULTIPLY_B
    JSR MULTIPLY

    LD R0 MULTIPLY_RESULT
    LD R1 RAND_ADD
    ADD R0 R0 R1
    LD R1 ABS_MASK
    AND R0 R0 R1

    ST R0 RAND_SEED

    LD R7 RAND_RET
RET

GET_RANDOM_BLOCK .FILL #0
    ST R7 GRB_RET


    JSR RAND

    LD R3 RAND_SEED
    LD R4 BLOCK_RAND_BITMASK
    AND R3 R3 R4

    LD R4 EXCLUDE_WATER_AND_LAVA_FLAG
    ADD R4 R4 #0
    BRz DONT_EXCLUDE_WATER_AND_LAVA
        ; make sure its not flowing water
        ADD R4 R3 #-8
        BRnp NOT_FLOWING_WATER
            ADD R3 R3 #4
            ST R3 RANDOM_BLOCK
            LD R7 GRB_RET
            RET
        NOT_FLOWING_WATER .FILL #0

        ; make sure its not water
        ADD R4 R3 #-9
        BRnp NOT_WATER
            ADD R3 R3 #4
            ST R3 RANDOM_BLOCK
            LD R7 GRB_RET
            RET
        NOT_WATER .FILL #0

        ; make sure its not flowing lava
        ADD R4 R3 #-10
        BRnp NOT_FLOWING_LAVA
            ADD R3 R3 #4
            ST R3 RANDOM_BLOCK
            LD R7 GRB_RET
            RET
        NOT_FLOWING_LAVA .FILL #0

        ; make sure its not lava
        ADD R4 R3 #-11
        BRnp NOT_LAVA
            ADD R3 R3 #4
            ST R3 RANDOM_BLOCK
            LD R7 GRB_RET
            RET
        NOT_LAVA .FILL #0
    DONT_EXCLUDE_WATER_AND_LAVA

    ST R3 RANDOM_BLOCK

    LD R7 GRB_RET
RET

.END