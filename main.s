
        INCLUDE stm32l476xx_constants.s

        IMPORT OLED_Setup
        IMPORT OLED_Motor_Status

; Motor configuration
MOTOR_SET  EQU 0x51400

; Full-step patterns
STEP_1     EQU 0x220
STEP_2     EQU 0x320
STEP_3     EQU 0x140
STEP_4     EQU 0x60

; Half-step patterns
HSTEP_1    EQU 0x200
HSTEP_2    EQU 0x40
HSTEP_3    EQU 0x100
HSTEP_4    EQU 0x20

; Reset all four motor pins (PC5, PC6, PC8, PC9)
MOTOR_RESET EQU 0x03600000

        AREA main, CODE, READONLY
        EXPORT __main
        ENTRY

;************************************************
; MAIN
;************************************************

__main PROC

        ; Initialize clock and OLED
        BL OLED_Setup

        ; Initialize motor pins
        BL Stepper_Pin_Init

        ; FULL STEP
        MOV r0, #1
        BL OLED_Motor_Status

        LDR r0, =360
        BL Full_Stepping

        ; HALF STEP
        MOV r0, #2
        BL OLED_Motor_Status

        LDR r0, =360
        BL Half_Stepping

        ; COMPLETE
        MOV r0, #3
        BL OLED_Motor_Status

deadloop
        B deadloop

        ENDP

;************************************************
; STEPPER PIN INITIALIZATION
;************************************************

Stepper_Pin_Init PROC

        ; Enable GPIOA and GPIOC clocks
        LDR r0, =RCC_BASE
        LDR r1, [r0, #RCC_AHB2ENR]

        ORR r1, r1, #RCC_AHB2ENR_GPIOAEN
        ORR r1, r1, #RCC_AHB2ENR_GPIOCEN

        STR r1, [r0, #RCC_AHB2ENR]

        ; Configure motor pins as outputs
        LDR r0, =GPIOC_BASE
        LDR r1, [r0, #GPIO_MODER]

        LDR r2, =0x000F3C00
        BIC r1, r1, r2

        LDR r2, =MOTOR_SET
        ORR r1, r1, r2

        STR r1, [r0, #GPIO_MODER]

        BX LR

        ENDP

;************************************************
; FULL STEPPING
;************************************************

Full_Stepping PROC

        PUSH {r4, LR}

        ; repetitions = angle * 512 / 360
        LDR r1, =512
        MUL r0, r0, r1
        LDR r1, =360
        UDIV r0, r0, r1

        MOV r2, r0
        MOV r3, #0

Full_Step

        ; STEP 1
        LDR r0, =GPIOC_BASE
        LDR r1, =STEP_1
        STR r1, [r0, #GPIO_BSRR]

        LDR r0, =250000
        BL Delay

        LDR r0, =GPIOC_BASE
        LDR r1, =MOTOR_RESET
        STR r1, [r0, #GPIO_BSRR]

        ; STEP 2
        LDR r1, =STEP_2
        STR r1, [r0, #GPIO_BSRR]

        LDR r0, =250000
        BL Delay

        LDR r0, =GPIOC_BASE
        LDR r1, =MOTOR_RESET
        STR r1, [r0, #GPIO_BSRR]

        ; STEP 3
        LDR r1, =STEP_3
        STR r1, [r0, #GPIO_BSRR]

        LDR r0, =250000
        BL Delay

        LDR r0, =GPIOC_BASE
        LDR r1, =MOTOR_RESET
        STR r1, [r0, #GPIO_BSRR]

        ; STEP 4
        LDR r1, =STEP_4
        STR r1, [r0, #GPIO_BSRR]

        LDR r0, =250000
        BL Delay

        LDR r0, =GPIOC_BASE
        LDR r1, =MOTOR_RESET
        STR r1, [r0, #GPIO_BSRR]

        ADD r3, r3, #1
        CMP r3, r2
        BLO Full_Step

        POP {r4, LR}
        BX LR

        ENDP

;************************************************
; DELAY
;************************************************

Delay PROC

delay_loop
        SUBS r0, r0, #1
        BNE delay_loop

        BX LR

        ENDP

;************************************************
; HALF STEPPING
;************************************************

Half_Stepping PROC

        PUSH {r4, LR}

        ; repetitions = angle * 512 / 360
        LDR r1, =512
        MUL r0, r0, r1
        LDR r1, =360
        UDIV r0, r0, r1

        MOV r2, r0
        MOV r3, #0

Half_Step

        ; STEP 1
        LDR r0, =GPIOC_BASE
        LDR r1, =STEP_1
        STR r1, [r0, #GPIO_BSRR]

        LDR r0, =180000
        BL Delay

        LDR r0, =GPIOC_BASE
        LDR r1, =MOTOR_RESET
        STR r1, [r0, #GPIO_BSRR]

        ; HSTEP 1
        LDR r1, =HSTEP_1
        STR r1, [r0, #GPIO_BSRR]

        LDR r0, =180000
        BL Delay

        LDR r0, =GPIOC_BASE
        LDR r1, =MOTOR_RESET
        STR r1, [r0, #GPIO_BSRR]

        ; STEP 2
        LDR r1, =STEP_2
        STR r1, [r0, #GPIO_BSRR]

        LDR r0, =180000
        BL Delay

        LDR r0, =GPIOC_BASE
        LDR r1, =MOTOR_RESET
        STR r1, [r0, #GPIO_BSRR]

        ; HSTEP 2
        LDR r1, =HSTEP_2
        STR r1, [r0, #GPIO_BSRR]

        LDR r0, =180000
        BL Delay

        LDR r0, =GPIOC_BASE
        LDR r1, =MOTOR_RESET
        STR r1, [r0, #GPIO_BSRR]

        ; STEP 3
        LDR r1, =STEP_3
        STR r1, [r0, #GPIO_BSRR]

        LDR r0, =180000
        BL Delay

        LDR r0, =GPIOC_BASE
        LDR r1, =MOTOR_RESET
        STR r1, [r0, #GPIO_BSRR]

        ; HSTEP 3
        LDR r1, =HSTEP_3
        STR r1, [r0, #GPIO_BSRR]

        LDR r0, =180000
        BL Delay

        LDR r0, =GPIOC_BASE
        LDR r1, =MOTOR_RESET
        STR r1, [r0, #GPIO_BSRR]

        ; STEP 4
        LDR r1, =STEP_4
        STR r1, [r0, #GPIO_BSRR]

        LDR r0, =180000
        BL Delay

        LDR r0, =GPIOC_BASE
        LDR r1, =MOTOR_RESET
        STR r1, [r0, #GPIO_BSRR]

        ; HSTEP 4
        LDR r1, =HSTEP_4
        STR r1, [r0, #GPIO_BSRR]

        LDR r0, =180000
        BL Delay

        LDR r0, =GPIOC_BASE
        LDR r1, =MOTOR_RESET
        STR r1, [r0, #GPIO_BSRR]

        ADD r3, r3, #1
        CMP r3, r2
        BLO Half_Step

        POP {r4, LR}
        BX LR

        ENDP

        END
