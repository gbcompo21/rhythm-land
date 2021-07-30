INCLUDE "constants/hardware.inc"
INCLUDE "constants/rating.inc"
INCLUDE "constants/games.inc"
INCLUDE "constants/transition.inc"
INCLUDE "macros/misc.inc"

SECTION "Overall Rating Screen Setup", ROM0

SetupRatingScreen::
    ; Set palettes
    ld      a, RATING_SCREEN_BGP
    ldh     [hBGP], a
    
    ; Set appropriate LCDC flags
    ld      a, LCDCF_ON | LCDCF_BG8800 | LCDCF_BG9800 | LCDCF_BGON
    ldh     [hLCDC], a
    
    ; Reset scroll
    xor     a, a
    ldh     [hSCX], a
    ldh     [hSCY], a
    
    ; Clear a tile
    ld      hl, $9000
    lb      bc, 0, 16
    call    LCDMemsetSmall
    ; Clear the background map
    ld      hl, _SCRN0
    lb      de, SCRN_Y_B, LOW(SCRN_VX_B - SCRN_X_B)
.loop
    ; b = 0
    ld      c, SCRN_X_B
    call    LCDMemsetSmall
    dec     d
    jr      z, .doneClearing
    ld      a, d
    ld      d, HIGH(SCRN_VX_B - SCRN_X_B)
    add     hl, de  ; e = LOW(SCRN_VX_B - SCRN_X_B)
    ld      d, a
    jr      .loop
.doneClearing
    
    ; Set up text engine for rating text
    ld      a, RATING_TEXT_LINE_LENGTH * 8 + 1
    ld      [wTextLineLength], a
    ; Each entry is 1 line
    ld      a, RATING_TEXT_NUM_LINES
    ld      [wTextNbLines], a
    ld      [wTextRemainingLines], a
    ld      [wNewlinesUntilFull], a
    xor     a, a
    ld      [wTextStackSize], a
    ld      [wTextFlags], a
    ld      a, RATING_TEXT_LETTER_DELAY
    ld      [wTextLetterDelay], a
    ; Set up text tiles
    ld      a, RATING_TEXT_TILES_START
    ld      [wTextCurTile], a
    ld      [wWrapTileID], a
    ld      a, RATING_TEXT_LAST_TILE
    ld      [wLastTextTile], a
    ld      a, HIGH(vRatingTextTiles) & $F0
    ld      [wTextTileBlock], a
    
    ; Next hit number after the last is the total number of hits in the
    ; current game
    ldh     a, [hNextHitNumber]
    ld      d, a
    add     a, a    ; Double total to give weights in 1/2s
    ld      c, a    ; c = denominator
    
    ; Miss: Weight -0.5
    ld      hl, hHitPerfectCount
    ld      a, [hld]
    ASSERT hHitOkCount == hHitPerfectCount - 1
    add     a, [hl]
    ; a = Perfects + OKs
    cpl
    inc     a
    ; a = -(Perfects + OKs)
    add     a, d
    ; a = Total - Perfects - OKs = Misses
    cpl
    inc     a       ; Weight -0.5
    
    ; OK: Weight 0.5
    add     a, [hl]
    
    ASSERT hHitPerfectCount == hHitOkCount + 1
    inc     l
    ; Perfect: Weight 1
    add     a, [hl]
    add     a, [hl]
    
    ld      l, LOW(hHitBadCount)
    ld      b, a
    ; Bad: Weight -0.5
    ld      a, [hld]
    cpl
    inc     a
    add     a, b
    
    ; Score is negative -> go straight to Bad
    bit     7, a
    ld      b, RATING_BAD
    jr      nz, .getText
    
    ; Numerator must be less than denominator, but that's fine since
    ; it'll be 100 anyway
    cp      a, c
    ld      b, RATING_PERFECT
    jr      nc, .getText
    
    ld      b, a
    ; b = numerator, c = denominator
    call    CalcPercentDigit
    ; a = tens digit
    
    ld      b, RATING_BAD
    cp      a, RATING_OK_MIN
    jr      c, .getText
    
    ASSERT RATING_OK == RATING_BAD + 1
    inc     b
    cp      a, RATING_GREAT_MIN
    jr      c, .getText
    
    ASSERT RATING_GREAT == RATING_OK + 1
    inc     b

; @param    b   Rating type ID
.getText
    ; Find current game's part of the rating text table
    ldh     a, [hCurrentGame]
    sub     a, ID_GAMES_START
    ASSERT NUM_RATING_TYPES == 4
    add     a, a    ; game ID * 2
    add     a, a    ; game ID * 4
    ld      c, a
    add     a, a    ; game ID * NUM_RATING_TYPES + game ID * 2 (Pointer)
    add     a, c    ; game ID * NUM_RATING_TYPES + game ID * 3 (+Bank)
    ASSERT HIGH((NUM_GAMES - 1) * 12) == 0
    ld      c, a
    
    ; Find pointer to text for this type of rating
    ld      a, b
    add     a, a    ; rating type * 2 (Pointer)
    add     a, b    ; rating type * 3 (+Bank)
    add     a, c    ; c = game offset
    add     a, LOW(RatingTextTable)
    ld      l, a
    ASSERT HIGH(RatingTextTable.end - 1) == HIGH(RatingTextTable)
    ld      h, HIGH(RatingTextTable)
    
    ; Get pointer to text
    ld      b, [hl] ; b = bank number
    ASSERT HIGH(RatingTextTable.end - 1) == HIGH(RatingTextTable)
    inc     l
    ld      a, [hli]
    ld      h, [hl]
    ld      l, a
    ; hl = pointer to text
    ld      a, TEXT_NEW_STR
    call    PrintVWFText
    ld      hl, vRatingText
    jp      SetPenPosition

SECTION "Overall Rating Screen", ROM0

RatingScreen::
    rst     WaitVBlank
    
    ldh     a, [hTransitionState]
    ASSERT TRANSITION_STATE_OFF == 0
    and     a, a
    call    nz, TransitionUpdate
    
    call    PrintVWFChar
    call    DrawVWFChars
    
    ; Text engine sets the high byte of the source pointer to $FF when
    ; the end command (terminator) is reached
    ld      a, [wTextSrcPtr + 1]
    inc     a   ; ($FF + 1) & $FF == 0
    jr      nz, RatingScreen

.wait
    rst     WaitVBlank
    
    ldh     a, [hTransitionState]
    ASSERT TRANSITION_STATE_OFF == 0
    and     a, a
    jr      z, .noTransition
    
    call    TransitionUpdate
    ; Transitioning -> don't take player input
    jr      .wait
    
.noTransition
    ldh     a, [hNewKeys]
    and     a, PADF_A | PADF_START
    jr      z, .wait
    
    ld      a, ID_GAME_SELECT
    call    TransitionStart
    jr      .wait

SECTION "Percentage Calculation", ROM0

; Original code copyright 2018 Damian Yerrick
; Taken from Libbet and the Magic Floor
; <https://github.com/pinobatch/libbet>
; Formatting modified in this file

; Calculates one digit of converting a fraction to a percentage
; @param    b   Numerator, less than c
; @param    c   Denominator, greater than 0
; @return   a   floor(10 * b / c)
; @return   b   10 * b % c
CalcPercentDigit::
    ld      de, $1000
    
    ; Bit 3: A.E = B * 1.25
    ld      a, b
    srl     a
    rr      e
    srl     a
    rr      e
    add     a, b
    jr      .firstCarry
    
    ; Bits 2-0: mul A.E by 2
.bitLoop
    rl      e
    adc     a
.firstCarry
    jr      c, .sub
    cp      a, c
    jr      c, .noSub
.sub
    ; Usually A >= C so subtracting C won't borrow. But if we arrived
    ; via .sub, A > 256 so even though 256 + A >= C, A < C.
    sub     a, c
    and     a, a
.noSub
    rl      d
    jr      nc, .bitLoop
    
    ld      b, a
    ; Binary to decimal subtracts if trial subtraction has no borrow.
    ; 6502/ARM carry: 0: borrow; 1: no borrow
    ; 8080 carry: 1: borrow; 0: no borrow
    ; The 6502 interpretation is more convenient for binary to decimal
    ; conversion, so convert to 6502 discipline
    ld      a, $0F
    xor     a, d
    ret
