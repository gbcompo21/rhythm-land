INCLUDE "defines.inc"

SECTION "Entry Point", ROM0[$0100]

EntryPoint:
    di
    jp      Initialize
    
    ; Ensure no space is wasted
    ASSERT @ == $0104

SECTION "Cartridge Header", ROM0[$0104]

; Leave room for the cartridge header, filled in by RGBFIX
CartridgeHeader:
    DS $0150 - $0104, 0

SECTION "Stack", WRAM0

    DS STACK_SIZE
wStackBottom::

SECTION "Global Variables", HRAM

; Currently pressed keys (1 = Pressed, 0 = Not pressed)
hPressedKeys::
    DS 1
; Keys that were just pressed this frame
hNewKeys::
    DS 1

; Current bank number of the $4000-$7FFF range, for interrupt handlers
; to restore
hCurrentBank::
    DS 1

; Temporary variable for whatever
hScratch::
    DS 1
