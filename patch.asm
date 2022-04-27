; #################################################################################################
; #                                      GFX REVAMP / ROMHACK                                     #
; #                                   Ghostbusters (USA, Europe)                                  #
; #                           for SEGA GENESIS - v0.1 2022-04-07, ArcadeTV                        #
; #################################################################################################

; =================================================================================================
; # INCLUDE CONSTANTS
; =================================================================================================

    include "includes/constants.asm"


; =================================================================================================
; # MACROS
; =================================================================================================

; Set the VRAM (video RAM) address to write to next
    macro SetVRAMWrite
    move.l  #(vdp_cmd_vram_write)|((\1)&$3FFF)<<16|(\1)>>14,vdp_control
    endm

; Set the CRAM (colour RAM) address to write to next
    macro SetCRAMWrite
	move.l  #(vdp_cmd_cram_write)|((\1)&$3FFF)<<16|(\1)>>14,vdp_control
	endm


; =================================================================================================
; HEADER OVERWRITES
; =================================================================================================

    org     $1C0
    dc.b    "--> ArcadeTV <--"
    org     $1D0
    include "includes/version.asm"          ; include the generated file from build.bat
    org     $1E0                            ; Date is written upon building
    dc.b    "================"

    org     $1F0
    dc.b    "JUE"                           ; All Regions allowed


; =================================================================================================
; ROUTINE OVERWRITES
; =================================================================================================

    org     $1804E                          ; fix wrong tiles after text
    dc.b    " GHOSTBUSTERS",$FE

    org     $6C624                          ; Params for GFX in Intro
    ; RAYMOND ------------------------------
    dc.w    0
    dc.l    tilemapRAY
    dc.w    $C43A-($80*size_word)-(34*size_word)
    dc.w    9                               ; width:  10 (-1)
    dc.w    21                              ; height: 22 (-1)
    dc.w    0
    dc.b    0
    dc.b    1
    dc.l    textRaymond
    dc.w    $C5EA
    dc.b    0                               ; disable
    dc.b    0
    dc.b    1
    dc.b    0
    ; PETER --------------------------------
    dc.b    0
    dc.b    0
    dc.l    tilemapPETER
    dc.w    $C402-($80*size_word)-(34*size_word)
    dc.w    9                               ; width:  10 (-1)
    dc.w    21                              ; height: 22 (-1)
    dc.b    0
    dc.b    0
    dc.b    0
    dc.b    1
    dc.l    textPeter
    dc.w    $C864
    dc.b    0
    dc.b    0
    dc.b    1
    dc.b    0
    ; EGON ---------------------------------
    dc.b    0
    dc.b    0
    dc.l    tilemapEGON
    dc.w    $C468-($80*size_word)-(33*size_word)
    dc.w    9                               ; width:  10 (-1)
    dc.w    21                              ; height: 22 (-1)
    dc.b    0
    dc.b    0
    dc.b    0
    dc.b    1
    dc.l    textEgon
    dc.w    $C5D8
    dc.b    0
    dc.b    0
    dc.b    1
    dc.b    0
    ; 3 FACES ------------------------------
    dc.b    0
    dc.b    2
    dc.l    tilemapRAY
    dc.w    $C43A-($80*size_word)-(34*size_word)
    dc.w    9                               ; width:  10 (-1)
    dc.w    21                              ; height: 22 (-1)
    dc.b    0
    dc.b    0
    dc.l    tilemapPETER
    dc.w    $C452-($80*size_word)-(34*size_word)
    dc.w    9                               ; width:  10 (-1)
    dc.w    21                              ; height: 22 (-1)
    dc.b    0
    dc.b    0
    dc.l    tilemapEGON
    dc.w    $C468-($80*size_word)-(33*size_word)
    dc.w    9                               ; width:  10 (-1)
    dc.w    21                              ; height: 22 (-1)
    dc.b    0
    dc.b    0
    dc.b    0
    dc.b    0
    dc.b    1
    dc.b    0

    org     $16C26
    jsr     bypassTiledataRoutine

    ;org     $16C32
    ;jsr     setPalette


; =================================================================================================
; ADDITIONAL STUFF
; =================================================================================================

    org     $80000 ; -----------------------> padded space from here <-----------------------------

bypassTiledataRoutine:
    movem.l d0-d7/a0-a1/a3-a5,-(sp)
    SetVRAMWrite $48E0
    lea     tiledata,a0			            ; Move the address of the first graphics tile into a0
	move.l  #((tiledata_end+tiledata)/4)-1,d0  
                                            ; Loop counter = 8 longwords per tile * num tiles (-1 for DBRA loop)
	@Tiles_Loop:							; Start of loop
	move.l  (a0)+,vdp_data					; Write tile line (4 bytes per line), and post-increment address
	dbra    d0,@Tiles_Loop					; Decrement d0 and loop until finished (when d0 reaches -1)

    movem.l (sp)+,d0-d7/a0-a1/a3-a5

    rts

setPalette:
    movem.l d0-d7/a0-a1/a3-a5,-(sp)
    SetCRAMWrite $20
    lea     palette,a0			            ; Move the address of the first graphics tile into a0
	move.l  #(size_palette_w)-1,d0  
                                            ; Loop counter = 8 longwords per tile * num tiles (-1 for DBRA loop)
	@Pal_Loop:							    ; Start of loop
	move.w  (a0)+,vdp_data					; Write tile line (4 bytes per line), and post-increment address
	dbra    d0,@Pal_Loop					; Decrement d0 and loop until finished (when d0 reaches -1)

    movem.l (sp)+,d0-d7/a0-a1/a3-a5
    moveq   #8,d0                           ; adopt original instruction
    rts


    ; DATA:

tiledata:
    incbin  "includes/bin/tiledata_concatenated.bin"
tiledata_end:

    even

palette:
    ;dc.w    $0000,$0000,$0EEE,$08AC,$0468,$0024,$0222,$0844,$0C86,$0ECA,$0EEE,$00EE,$008E,$004E,$000A,$0EEE 
    incbin  "includes/bin/pal.bin"

textRaymond:
    dc.b    "RAY STANTZ",0
textPeter:
    dc.b    "PETER VENKMAN",0
textEgon:
    dc.b    "EGON SPENGLER",0

    even

tilemapRAY:
    include "includes/tilemaps/raymond.asm"
tilemapPETER:
    include "includes/tilemaps/peter.asm"
tilemapEGON:
    include "includes/tilemaps/egon.asm"