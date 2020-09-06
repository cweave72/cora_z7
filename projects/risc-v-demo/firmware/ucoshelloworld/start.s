
.section .text.startup
.global _init
.global IrqCtlr_ISR

_reset_vec:
        nop
        nop
        nop
        j _start

.balign 16
_irq_entry:
        /* Context switch ... */
        addi sp, sp, -32 * 4

        sw x1,  0*4(sp)
        sw x2,  1*4(sp)
        sw x3,  2*4(sp)
        sw x4,  3*4(sp)
        sw x5,  4*4(sp)
        sw x6,  5*4(sp)
        sw x7,  6*4(sp)
        sw x8,  7*4(sp)
        sw x9,  8*4(sp)
        sw x10, 9*4(sp)
        sw x11, 10*4(sp)
        sw x12, 11*4(sp)
        sw x13, 12*4(sp)
        sw x14, 13*4(sp)
        sw x15, 14*4(sp)
        sw x16, 15*4(sp)
        sw x17, 16*4(sp)
        sw x18, 17*4(sp)
        sw x19, 18*4(sp)
        sw x20, 19*4(sp)
        sw x21, 20*4(sp)
        sw x22, 21*4(sp)
        sw x23, 22*4(sp)
        sw x24, 23*4(sp)
        sw x25, 24*4(sp)
        sw x26, 25*4(sp)
        sw x27, 26*4(sp)
        sw x28, 27*4(sp)
        sw x29, 28*4(sp)
        sw x30, 29*4(sp)
        sw x31, 30*4(sp)

        /* Push interrupt return address onto the stack being saved. */
        csrr t0, mepc
        sw t0, 31*4(sp)

        /* Pass stack pointer through mscratch csr 
         * (expected by Software_IRQHandler()). */
        csrw mscratch, sp

        /* Call Primary IRQ C handler */
        jal IrqCtlr_ISR

        /* Restore register context. */
        lw x1,  0*4(sp)
        lw x2,  1*4(sp)
        lw x3,  2*4(sp)
        lw x4,  3*4(sp)
        lw x5,  4*4(sp)
        lw x6,  5*4(sp)
        lw x7,  6*4(sp)
        lw x8,  7*4(sp)
        lw x9,  8*4(sp)
        lw x10, 9*4(sp)
        lw x11, 10*4(sp)
        lw x12, 11*4(sp)
        lw x13, 12*4(sp)
        lw x14, 13*4(sp)
        lw x15, 14*4(sp)
        lw x16, 15*4(sp)
        lw x17, 16*4(sp)
        lw x18, 17*4(sp)
        lw x19, 18*4(sp)
        lw x20, 19*4(sp)
        lw x21, 20*4(sp)
        lw x22, 21*4(sp)
        lw x23, 22*4(sp)
        lw x24, 23*4(sp)
        lw x25, 24*4(sp)
        lw x26, 25*4(sp)
        lw x27, 26*4(sp)
        lw x28, 27*4(sp)
        lw x29, 28*4(sp)
        lw x30, 29*4(sp)
        lw x31, 30*4(sp)

        addi sp, sp, 32*4
        mret

# zero-initialize register file
_start:  
        # Set the interrupt vector
        csrwi mtvec, 0x10
        # Init machine registers.
        # Disable interrupts to start.  Will be enables on os startup.
        csrwi mstatus, 0
        csrwi mepc, 0
        csrwi mscratch, 0

        # Clear registers.
        addi x1, zero, 0
        addi x2, zero, 0
        addi x3, zero, 0
        addi x4, zero, 0
        addi x5, zero, 0
        addi x6, zero, 0
        addi x7, zero, 0
        addi x8, zero, 0
        addi x9, zero, 0
        addi x10, zero, 0
        addi x11, zero, 0
        addi x12, zero, 0
        addi x13, zero, 0
        addi x14, zero, 0
        addi x15, zero, 0
        addi x16, zero, 0
        addi x17, zero, 0
        addi x18, zero, 0
        addi x19, zero, 0
        addi x20, zero, 0
        addi x21, zero, 0
        addi x22, zero, 0
        addi x23, zero, 0
        addi x24, zero, 0
        addi x25, zero, 0
        addi x26, zero, 0
        addi x27, zero, 0
        addi x28, zero, 0
        addi x29, zero, 0
        addi x30, zero, 0
        addi x31, zero, 0

        la sp, _stack_top
        call _init

        # call main
        call main

loop:   j loop

