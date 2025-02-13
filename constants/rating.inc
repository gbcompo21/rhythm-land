; Rating contants

; Percentage score 0-59 -> Bad
; Percentage score 60-79 -> OK
DEF RATING_OK_MIN EQU 6
; Percentage score 80-99 -> Great
DEF RATING_GREAT_MIN EQU 8
; Percentage score 100 -> Perfect

; Rating type IDs, just for the order of the rating text pointer table
RSRESET
DEF RATING_BAD RB 1
DEF RATING_OK RB 1
DEF RATING_GREAT RB 1
DEF RATING_PERFECT RB 1
DEF RATING_TYPE_COUNT EQU _RS

; Rating screen

DEF RATING_SCREEN_PADDING EQU 2

; Rating text

; Where to draw the rating text
DEF vRatingText EQU _SCRN0 + (RATING_SCREEN_PADDING * SCRN_VX_B) + RATING_SCREEN_PADDING

DEF RATING_TEXT_LINE_LENGTH EQU SCRN_X_B - RATING_SCREEN_PADDING * 2
DEF RATING_TEXT_LINE_COUNT EQU 8

DEF vRatingTextTiles EQU $8800
DEF RATING_TEXT_TILES_START EQU LOW(vRatingTextTiles / 16)
DEF RATING_TEXT_LAST_TILE EQU RATING_TEXT_TILES_START + RATING_TEXT_LINE_LENGTH * RATING_TEXT_LINE_COUNT - 1

DEF RATING_TEXT_LETTER_DELAY EQU 2
DEF RATING_GRAPHIC_DELAY EQU 80

; Rating graphic

DEF RATING_GRAPHIC_HEIGHT EQU 6
DEF RATING_GRAPHIC_Y EQU SCRN_Y_B - RATING_GRAPHIC_HEIGHT - 1
DEF vRatingGraphic EQU _SCRN0 + (RATING_GRAPHIC_Y * SCRN_VX_B)

; Background palette
DEF RATING_SCREEN_BGP EQU %00_01_10_11
