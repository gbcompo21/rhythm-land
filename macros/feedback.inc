; One "line" of feedback, separated from the next with a blank line and
; a bit of delay.
MACRO feedback
    DB \#, "\n\n"
    DB TEXT_DELAY, 40
ENDM

; The last "line" of feedback, which isn't followed by any more text and
; thus doesn't need the newlines. Includes the text terminator value.
MACRO feedback_last
    DB \#
    DB TEXT_END
ENDM
