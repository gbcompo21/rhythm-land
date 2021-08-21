INCLUDE "constants/hardware.inc"
INCLUDE "constants/games/seagull-serenade.inc"
INCLUDE "constants/actors.inc"
INCLUDE "macros/actors.inc"

SECTION "Seagull Serenade Seagull 1 Actor Animation Data", ROMX

xActorSeagull1Animation::
    animation Seagull1, SEAGULL

    set_tiles resting, 6
.bobLoop
    cel resting4, 5
    cel resting2, MUSIC_SEAGULL_SERENADE_SPEED * 2 - 5
    goto_cel .bobLoop

.groove
    ; Only used when ending an override animation
    set_tiles resting, 6
.grooveLoop
    cel resting1, MUSIC_SEAGULL_SERENADE_SPEED * 2 - 5
    cel resting2, 5
    cel resting3, MUSIC_SEAGULL_SERENADE_SPEED * 2 - 5
    cel resting2, 5
    goto_cel .grooveLoop

.high
    cel resting2, 3
    cel resting1, 3
    set_tiles high1, 6
    cel high1, 3
    set_tiles high2, 8
    cel high2, MUSIC_SEAGULL_SERENADE_SPEED * 2 - 3 * 4
    set_tiles high1, 6
    cel high1, 3
    override_end .groove

.mid
    cel resting1, 3
    cel resting2, 3
    set_tiles mid1, 6
    cel mid1, 3
    set_tiles mid2, 6
    cel mid2, MUSIC_SEAGULL_SERENADE_SPEED * 2 - 3 * 4
    set_tiles mid1, 6
    cel mid1, 3
    override_end .groove

.low
    cel resting2, 3
    cel resting3, 3
    set_tiles low1, 6
    cel low1, 3
    set_tiles low2, 6
    cel low2, MUSIC_SEAGULL_SERENADE_SPEED * 2 - 3 * 4
    set_tiles low1, 6
    cel low1, 3
    override_end .groove

.missedNote
    set_tiles missedNote, 6
    override_end

    ; Cel constant definitions
    def_cel .grooveLoop, GROOVE
    def_cel .high, HIGH
    def_cel .mid, MID
    def_cel .low, LOW
    def_cel .missedNote, MISSED_NOTE

xActorSeagull1Tiles:
.resting
    INCBIN "res/seagull-serenade/seagull-1/resting.obj.2bpp"
.missedNote
    INCBIN "res/seagull-serenade/seagull-1/missed-note.obj.2bpp"
.high1
    INCBIN "res/seagull-serenade/seagull-1/high-1.obj.2bpp"
.high2
    INCBIN "res/seagull-serenade/seagull-1/high-2.obj.2bpp"
.mid1
    INCBIN "res/seagull-serenade/seagull-1/mid-1.obj.2bpp"
.mid2
    INCBIN "res/seagull-serenade/seagull-1/mid-2.obj.2bpp"
.low1
    INCBIN "res/seagull-serenade/seagull-1/low-1.obj.2bpp"
.low2
    INCBIN "res/seagull-serenade/seagull-1/low-2.obj.2bpp"

SECTION "Seagull Serenade Seagull 1 Actor Meta-Sprite Data", ROMX

xActorSeagull1Metasprites::
    metasprite .resting1
    metasprite .resting2
    metasprite .resting3
    metasprite .resting4
    metasprite .high1
    metasprite .high2
    metasprite .mid1
    metasprite .mid2
    metasprite .low1
    metasprite .low2

.resting1
; Also used for missed note (data happens to be identical)
    obj 0, -1, $00, 0
    obj 0, 7, $02, 0
    obj 0, 15, $04, 0
    DB METASPRITE_END
.resting2
    obj -1, 0, $00, 0
    obj -1, 8, $02, 0
    obj -1, 16, $04, 0
    DB METASPRITE_END
.resting3
    obj 0, 1, $00, 0
    obj 0, 9, $02, 0
    obj 0, 17, $04, 0
    DB METASPRITE_END
.resting4
    obj 0, 0, $00, 0
    obj 0, 8, $02, 0
    obj 0, 16, $04, 0
    DB METASPRITE_END

.high1
    obj -1, -3, $00, 0
    obj -1, 5, $02, 0
    obj -1, 13, $04, 0
    DB METASPRITE_END
.high2
    obj 0, -5, $00, 0
    obj 0, 3, $02, 0
    obj 0, 11, $04, 0
    obj -16, 7, $06, 0
    DB METASPRITE_END

.mid1
    obj 0, 0, $00, 0
    obj 0, 8, $02, 0
    obj 0, 16, $04, 0
    DB METASPRITE_END
.mid2
    obj 0, 0, $00, 0
    obj 0, 8, $02, 0
    obj 0, 16, $04, 0
    DB METASPRITE_END

.low1
    obj -1, 3, $00, 0
    obj -1, 11, $02, 0
    obj -1, 19, $04, 0
    DB METASPRITE_END
.low2
    obj -1, 3, $00, 0
    obj -1, 11, $02, 0
    obj 2, 18, $04, 0
    DB METASPRITE_END
