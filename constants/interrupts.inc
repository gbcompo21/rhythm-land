; Number of cycles the OAM DMA routine's waitloop takes each iteration
DEF DMA_LOOP_CYCLES EQU 1 + 3

; Used in hLYCIndex - No current extra LYC interrupts
DEF LYC_INDEX_NONE EQU -1
; Used in LYCTable - Signal the end of LYC values in one frame
DEF LYC_FRAME_END EQU -1
