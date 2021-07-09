INCLUDE "defines.inc"

SECTION UNION "Game Variables", HRAM

; Delay after the game is finished to allow for a late last hit
hEndDelay:
    DS 1

SECTION "Test Game", ROMX

xGameTest::
    ld      a, 60
    ldh     [hEndDelay], a
    
    ; Start music
    ld      bc, BANK(Inst_FileSelect)
    ld      de, Inst_FileSelect
    call    Music_PrepareInst
    ld      bc, BANK(Music_FileSelect)
    ld      de, Music_FileSelect
    call    Music_Play
    
    ; Set up game data
    lb      bc, BANK(xGameTestHitTable), BANK(xGameTestCueTable)
    ld      de, xGameTestCueTable
    ld      hl, xGameTestHitTable
    call    EngineInit

.loop
    ; Wait for VBlank
    halt
    ldh     a, [hVBlankFlag]
    and     a, a
    jr      z, .loop
    xor     a, a
    ldh     [hVBlankFlag], a
    
    call    EngineUpdate
    
    ldh     a, [hHitTableBank]
    and     a, a
    jr      nz, .drawValues
    
    ld      hl, hEndDelay
    dec     [hl]
    ; Finished, go to the rating screen
    jp      z, RatingScreen
    
.drawValues
    ld      hl, _SCRN0 + (SCRN_X_B - 2)
    ld      a, [wMusicSyncData]
    call    LCDDrawHex
    
    ld      a, [wMusicSyncData]
    and     a, a
    jr      z, .noData
    
    ld      hl, _SCRN0 + (1 * SCRN_VX_B) + (SCRN_X_B - 2)
    ld      a, [wMusicSyncData]
    call    LCDDrawHex
    
    ldh     a, [rBGP]
    cpl
    ldh     [rBGP], a
    
    xor     a, a
    ld      [wMusicSyncData], a
    
.noData
    ld      hl, _SCRN0
    ld      de, SCRN_VX_B - (2 * 2 + 1)
    
    ldh     a, [hLastHit]
    call    LCDDrawHex
    inc     l
    ldh     a, [hNextHit]
    call    LCDDrawHex
    
    add     hl, de
    
    ldh     a, [hLastHitKeys]
    call    LCDDrawHex
    inc     l
    ldh     a, [hNextHitKeys]
    call    LCDDrawHex
    
    add     hl, de
    
    ldh     a, [hHitPerfectCount]
    call    LCDDrawHex
    inc     l
    ldh     a, [hHitOkCount]
    call    LCDDrawHex
    inc     l
    ldh     a, [hHitBadCount]
    call    LCDDrawHex
    
    ldh     a, [hLastHit.low]
    and     a, a
    jr      nz, .loop
    ldh     a, [hLastHit.high]
    and     a, a
    jr      nz, .loop
    
    ld      b, SFX_BEEP
    call    SFX_Play
    jr      .loop

SECTION "Test Cue", ROMX

xCueTest::
    ; Play a placeholder sound effect
    ld      b, SFX_TEST_CUE
    jp      SFX_Play
