INCLUDE "constants/hardware.inc"
INCLUDE "constants/actors.inc"
INCLUDE "constants/transition.inc"
INCLUDE "constants/games/pancake.inc"

SECTION UNION "Game Variables", HRAM

; How cooked the last pancake was, for using an appropriate cel after
; flipped onto the counter
hLastPancakeCooked:
    DS 1

; Number of frames to keep the pancake on the counter for longer
hCounterCountdown:
    DS 1

SECTION "Pancake Game Setup", ROMX

xGameSetupPancake::
    ; Set palettes
    ld      a, BGP_PANCAKE
    ldh     [hBGP], a
    ld      a, OBP0_PANCAKE
    ldh     [hOBP0], a
    
    ; Set appropriate LCDC flags
    ld      a, LCDCF_ON | LCDCF_BG8800 | LCDCF_BG9800 | LCDCF_BGON | LCDCF_OBJ16 | LCDCF_OBJON
    ldh     [hLCDC], a
    
    ; Load background tiles
    ASSERT BANK(xBackgroundTiles9000) == BANK(@)
    ld      de, xBackgroundTiles9000
    ld      hl, $9000
    ld      bc, xBackgroundTiles9000.end - xBackgroundTiles9000
    rst     LCDMemcopy
    ASSERT BANK(xBackgroundTiles8800) == BANK(@)
    ASSERT xBackgroundTiles8800 == xBackgroundTiles9000.end
    ; de = xBackgroundTiles8800
    ld      hl, $8800
    ld      bc, xBackgroundTiles8800.end - xBackgroundTiles8800
    rst     LCDMemcopy
    
    ; Load background map
    ASSERT BANK(xMap) == BANK(@)
    ASSERT xMap == xBackgroundTiles8800.end
    ; de = xMap
    ld      hl, _SCRN0
    ld      c, SCRN_Y_B
    call    LCDMemcopyMap
    
    ; Enable tile streaming
    ; a = 1
    ldh     [hTileStreamingEnable], a
    
    ; No pancake is waiting on the counter
    ld      a, -1
    ldh     [hCounterCountdown], a
    
    ; Set up game data
    ld      c, BANK(xHitTablePancake)
    ld      hl, xHitTablePancake
    jp      EngineInit

xBackgroundTiles9000:
    INCBIN "res/pancake/background-normal.bg.2bpp", 0, 128 * 16
.end
xBackgroundTiles8800:
    INCBIN "res/pancake/background-normal.bg.2bpp", 128 * 16
.end

xMap:
    INCBIN "res/pancake/background-normal.bg.tilemap"

SECTION "Pancake Game Loop", ROMX

xGamePancake::
    rst     WaitVBlank
    
    ; Check if currently transitioning to another screen
    ldh     a, [hTransitionState]
    ASSERT TRANSITION_STATE_OFF == 0
    and     a, a
    jr      z, .noTransition
    
    call    TransitionUpdate
    
    ; Check if the transition just ended
    ldh     a, [hTransitionState]
    ASSERT TRANSITION_STATE_OFF == 0
    and     a, a
    jr      nz, xGamePancake
    
    ; Start music
    ld      c, BANK(Inst_Pancake)
    ld      de, Inst_Pancake
    call    Music_PrepareInst
    ld      c, BANK(Music_Pancake)
    ld      de, Music_Pancake
    call    Music_Play
    jr      xGamePancake

.noTransition
    call    EngineUpdate
    call    ActorsUpdate
    jr      xGamePancake

SECTION "Large Pancake Cue", ROMX

xCueLargePancake::
    ; Create a Large Pancake actor
    ASSERT BANK(xActorLargePancakeDefinition) == BANK(@)
    ld      de, xActorLargePancakeDefinition
    jp      ActorNew

xActorLargePancakeDefinition:
    DB ACTOR_LARGE_PANCAKE
    DB PANCAKE_X, PANCAKE_START_Y
    DB 0, PANCAKE_FALL_SPEED

SECTION "Small Pancake Cue", ROMX

xCueSmallPancake::
    ; Create a Small Pancake actor
    ASSERT BANK(xActorSmallPancakeDefinition) == BANK(@)
    ld      de, xActorSmallPancakeDefinition
    jp      ActorNew

xActorSmallPancakeDefinition:
    DB ACTOR_SMALL_PANCAKE
    DB PANCAKE_X, PANCAKE_START_Y
    DB 0, PANCAKE_FALL_SPEED

SECTION "Pancake Actor", ROMX

xActorPancake::
    ; Check if the pancake is finished falling (landed on the pan)
    ld      hl, wActorYPosTable
    add     hl, bc
    ; Negative -> still above the pan
    bit     7, [hl]
    jr      nz, .noLand
    ld      a, [hl]
    ; Add 1 to check for <= instead of <
    cp      a, PANCAKE_Y + 1
    jr      c, .noLand
    
    ; Ensure the position is correct before resetting speed
    ld      [hl], PANCAKE_Y
    ; Land on the pan -> stop falling
    ld      hl, wActorYSpeedTable
    add     hl, bc
    ASSERT HIGH(MAX_ACTOR_COUNT - 1) == 0
    ld      [hl], b     ; b = 0
    
.noLand
    ; Check if the pancake has landed on the counter
    ld      hl, wActorXPosTable
    add     hl, bc
    ld      a, [hl]
    ; Add 1 to check for <= instead of <
    cp      a, PANCAKE_COUNTER_X + 1
    jr      c, .noLandCounter
    
    ; Ensure the position is correct before resetting speed
    ld      [hl], PANCAKE_COUNTER_X
    ; Land on the counter -> stop moving
    ld      hl, wActorXSpeedTable
    add     hl, bc
    ASSERT HIGH(MAX_ACTOR_COUNT - 1) == 0
    ld      [hl], b     ; b = 0
    ; The pancake is no longer cooking -> stop (freeze) the animation
    ldh     a, [hLastPancakeCooked]
    call    ActorSetCel
    ld      hl, wActorCelCountdownTable
    add     hl, bc
    ld      [hl], ANIMATION_DURATION_FOREVER
    
    ; Set the counter countdown -> only keep the pancake on the counter
    ; for so long
    ld      a, PANCAKE_COUNTER_TIME
    ldh     [hCounterCountdown], a
    
.noLandCounter
    ; If pancake is done staying on the counter, kill it
    ld      hl, hCounterCountdown
    ; If countdown is -1, the pancake is not waiting on the counter
    ld      a, [hl]
    inc     a
    jr      z, .notOnCounter
    dec     [hl]
    jp      z, ActorKill
    
.notOnCounter
    ; Check if the pancake is being flipped
    ldh     a, [hNewKeys]
    ASSERT PADB_A == 0
    rra     ; Move bit 0 to carry
    ret     nc
    
    ; If this is an odd-numbered (zero-indexed) hit, the pancake comes
    ; off the pan
    ldh     a, [hLastPlayerHitNumber]
    rra     ; Move bit 0 to carry
    jr      nc, .stayOnPan
    
    ; Move to the right; onto the counter
    ld      hl, wActorXSpeedTable
    add     hl, bc
    ld      [hl], PANCAKE_DONE_X_SPEED
    
.stayOnPan
    ; Decide how cooked the pancake is
    ld      hl, wActorCelTable
    add     hl, bc
    ld      a, [hl]
    cp      a, CEL_PANCAKE_OK
    jr      c, .undercooked
    cp      a, CEL_PANCAKE_OVERCOOKED
    jr      nc, .overcooked
    ; OK
    ld      a, CEL_PANCAKE_COOKED_OK
    ldh     [hLastPancakeCooked], a
    ld      a, CEL_PANCAKE_FLIP_OK
    jp      ActorSetCel
.undercooked
    ld      a, CEL_PANCAKE_COOKED_UNDERCOOKED
    ldh     [hLastPancakeCooked], a
    ld      a, CEL_PANCAKE_FLIP_UNDERCOOKED
    jp      ActorSetCel
.overcooked
    ld      a, CEL_PANCAKE_COOKED_OVERCOOKED
    ldh     [hLastPancakeCooked], a
    ld      a, CEL_PANCAKE_FLIP_OVERCOOKED
    jp      ActorSetCel
