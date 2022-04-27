; =================================================================================================
; CONSTANTS
; =================================================================================================

; Utility
; The size of a word and longword
size_word				    equ 2
size_long				    equ 4

; The size of one palette (in bytes, words, and longwords)
size_palette_b			    equ $20
size_palette_w			    equ size_palette_b/size_word
size_palette_l			    equ size_palette_b/size_long

; The size of one graphics tile (in bytes, words, and longwords)
size_tile_b				    equ $20
size_tile_w				    equ size_tile_b/size_word
size_tile_l				    equ size_tile_b/size_long


; VDP port addresses
vdp_control                 equ $00C00004
vdp_data                    equ $00C00000

; VDP commands
vdp_cmd_vram_write		    equ $40000000
vdp_cmd_cram_write		    equ $C0000000
vdp_cmd_vsram_write		    equ $40000010

; VDP memory addresses
vram_addr_tiles             equ $0000
vram_addr_plane_a           equ $C000
vram_addr_plane_b           equ $E000


; Z80 addresses
z80_ram:		        equ $A00000	; start of Z80 RAM
z80_dac3_pitch:		    equ $A000EA
z80_dac_status:		    equ $A01FFD
z80_dac_sample:		    equ $A01FFF
z80_ram_end:		    equ $A02000	; end of non-reserved Z80 RAM
z80_version:		    equ $A10001
z80_port_1_data:	    equ $A10002
z80_port_1_control:	    equ $A10008
z80_port_2_control:	    equ $A1000A
z80_expansion_control:	equ $A1000C
z80_bus_request:	    equ $A11100
z80_reset:		        equ $A11200
ym2612_a0:		        equ $A04000
ym2612_d0:		        equ $A04001
ym2612_a1:		        equ $A04002
ym2612_d1:		        equ $A04003

; Gamepad/IO port addresses.
pad_ctrl_a              equ $00A10009   ; IO port A control port
pad_ctrl_b              equ $00A1000B   ; IO port B control port
pad_data_a              equ $00A10003   ; IO port A data port
pad_data_b              equ $00A10005   ; IO port B data port

; Pad read latch, for fetching second byte from data port
pad_byte_latch          equ $40

; Gamepad button bits
pad_button_up           equ $00
pad_button_down         equ $01
pad_button_left         equ $02
pad_button_right        equ $03
pad_button_a            equ $0C
pad_button_b            equ $04
pad_button_c            equ $05
pad_button_start        equ $0D

; All gamepad button bits (for masking)
pad_button_all          equ $303F
