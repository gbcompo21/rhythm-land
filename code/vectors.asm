INCLUDE "defines.inc"

SECTION "VBlank Flag", HRAM

; Non-zero after a VBlank interrupt has occurred
hVBlankFlag::
    DS 1

SECTION "VBlank Interrupt Vector", ROM0[$0040]

    push    af
    ; Signal VBlank occurred
    ld      a, 1
    ldh     [hVBlankFlag], a
    jp      VBlankHandler
    
    ; Ensure no space is wasted
    ASSERT @ - $0040 == 8

SECTION "VBlank Interrupt Handler", ROM0

VBlankHandler:
    ei      ; Timing-insensitive stuff follows
    
    push    bc
    
    ; Read the joypad
    
    ; Read D-Pad
    ld      a, P1F_GET_DPAD
    call    .readPadNibble
    swap    a           ; Move directions to high nibble
    ld      b, a
    
    ; Read buttons
    ld      a, P1F_GET_BTN
    call    .readPadNibble
    xor     a, b        ; Combine buttons and directions + complement
    ld      b, a
    
    ; Update hNewKeys
    ld      a, [hPressedKeys]
    xor     a, b        ; a = keys that changed state
    and     a, b        ; a = keys that changed to pressed
    ld      [hNewKeys], a
    ld      a, b
    ld      [hPressedKeys], a
    
    ; Done reading
    ld      a, P1F_GET_NONE
    ldh     [rP1], a
    
    pop     bc
    pop     af
    ret         ; Interrupts already enabled

; @param    a   Value to write to rP1
; @return   a   Reading from rP1, ignoring non-input bits (forced high)
.readPadNibble
    ldh     [rP1], a
    ; Burn 16 cycles between write and read
    call    .ret        ; 10 cycles
    ldh     a, [rP1]    ; 3 cycles
    ldh     a, [rP1]    ; 3 cycles
    ldh     a, [rP1]    ; Read
    or      a, $F0      ; Ignore non-input bits
.ret
    ret

SECTION "STAT Interrupt Vector", ROM0[$0048]

STATHandler:
    ; Just updating sound, which is interruptable
    ei
    
    push    af
    push    bc
    push    de
    push    hl
    
    call    SoundSystem_Process
    
    pop     hl
    pop     de
    pop     bc
    pop     af
    ret     ; Interrupts already enabled
