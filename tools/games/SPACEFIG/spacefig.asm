;**********************************************
; Spacefight 2091, by Slammer Anarchy.
; adapted to CHIPcon v2 by Jacques Deschênes
;**********************************************
; joytick buttons
equ UP 2
equ DOWN 4
equ LEFT 8
equ RIGHT 16
equ FIRE_BTN 32

	JP main
	ASCII "Spacefight 2091\nby Slammer Anarchy!\n"
main:  
	CLS
	CALL opening_anim ; opening screen animation
	CALL code_02E 
	JP main
code_02E: ; game play begin
	LD I, level
	LD V0, 0
	LD [I], V0 ;initial level=0
	LD V8, 0
code_036: ; copy 192 bytes from sprite_2 > data_A57
	LD I, sprite_2
	ADD I, V8
	LD V7, [I]
	LD I, data_A57
	ADD I, V8
	LD [I], V7
	ADD V8, 8
	SE V8, 192
	JP code_036
	LD V0, 0
	LD I, level
	LD [I], V0
	LD I, score
	LD [I], V0
	LD V0, 3
	LD I, dca_guns
	LD [I], V0
	CALL code_09E
code_054:
	LD I, data_AEF
	LD V0, [I]
	SNE V0, 0
	JP code_060
	ADD V0, 255
	LD [I], V0
code_060:
	CALL delay_1
	CALL code_41E
	CALL code_366
	CALL code_27E
	CALL code_150
	LD I, data_A48
	LD V4, [I]
	SE V0, 0
	JP code_094
	SE V1, 0
	JP code_094
	SE V2, 0
	JP code_094
	SE V3, 0
	JP code_094
	SE V4, 0
	JP code_094
	CALL code_0EA
	LD I, level
	LD V0, [I]
	ADD V0, 32
	LD [I], V0
	SNE V0, 192
	RET
	CALL code_09E
	JP code_054
code_094:
	LD I, dca_guns
	LD V0, [I]
	SE V0, 0
	JP code_054
	RET
code_09E:
	CALL display_intro
	jp .
;initialisation des variables
	LD I, data_A43
	LD V0, 56
	LD V1, 0
	LD V2, 0
	LD [I], V2
	LD I, data_A46
	LD V0, 0
	LD V1, 0
	LD V2, 1
	LD V3, 1
	LD V4, 1
	LD V5, 1
	LD V6, 1
	LD V7, 5
	LD V8, 0
	LD V9, 0
	LD VA, 0
	LD VB, 0
	LD VC, 5
	LD [I], VC
	LD I, data_AEF
	LD V0, 255
	LD [I], V0
	CLS
	CALL draw_lives
	CALL display_dca
	CALL draw_score
	CALL display_score
	CALL code_458
	CALL code_4C6
	LD V5, 0
	JP code_318
code_0E0:
	ADD V3, 1
	SE V3, 5
	JP code_17E
	LD V3, 0
	JP code_17E
code_0EA:
	LD I, data_AEF
	LD V0, [I]
	SHR V0
	SHR V0
	SHR V0
	LD [I], V0
	CALL code_578
	CALL draw_lives
	CALL display_dca
	CALL draw_score
	CALL display_score
;draw sprite Gameover! 64x8 pixels	
	LD V0, 32
	LD V1, 25
	LD I, sprite_3 ;gameover! sprite
	LD V2, 8
	LD V3, 0
code_10A:
	DRW V0, V1, 8
	ADD V0, 8
	ADD I, V2
	ADD V3, 1
	SE V3, 8
	JP code_10A
	CALL code_464
	CALL delay_12
	CALL delay_12
	LD I, data_AEF
	LD V0, [I]
	SNE V0, 0
	RET
code_124:
	CALL code_464
	CALL display_score
	LD I, data_AEF
	LD V0, [I]
	ADD V0, 255
	LD [I], V0
	LD I, score
	LD V0, [I]
	ADD V0, 1
	LD [I], V0
	CALL code_464
	CALL display_score
	LD V0, 1
	LD ST, V0
	CALL delay_1
	LD I, data_AEF
	LD V0, [I]
	SE V0, 0
	JP code_124
	CALL delay_12
	CALL delay_12
	RET
code_150:
	LD I, data_A50
	LD V2, [I]
	SE V0, 0
	JP code_1A4
	ADD V2, 255
	LD [I], V2
	SE V2, 0
	RET
	LD I, level
	LD V0, [I]
	LD V2, 192
	SUB V2, V0
	SHR V2
	SHR V2
	SHR V2
	SHR V2
	SHR V2
	LD V0, V2
	LD I, data_A52
	LD [I], V0
	RND V3, #03
	RND V4, #01
	ADD V3, V4
code_17E:
	LD I, data_A48
	ADD I, V3
	LD V0, [I]
	SNE V0, 0
	JP code_0E0
	LD I, data_2
	ADD I, V3
	LD V0, [I]
	LD V3, V0
	LD I, data_A46
	LD V1, [I]
	ADD V0, V3
	ADD V0, 7
	ADD V1, 25
	LD I, data_A50
	LD [I], V2
	LD V0, 2
	LD ST, V0
	JP code_274
code_1A4:
	CALL code_274
	ADD V1, 4
	LD I, data_A50
	LD [I], V1
	CALL code_274
	SNE V1, 64
	JP code_24E
	SNE V1, 63
	JP code_24E
	SNE V1, 62
	JP code_24E
	SNE V1, 61
	JP code_24E
	SNE V1, 43
	JP code_20E
	SNE V1, 42
	JP code_20E
	SNE V1, 41
	JP code_20E
	SNE V1, 40
	JP code_20E
	SNE V1, 39
	JP code_20E
	SNE VF, 0
	RET
	LD V2, V0
	LD V3, V1
	LD I, data_A44
	LD V1, [I]
	SNE V0, 0
	JP code_1FE
	SE V0, V2
	JP code_1FE
	LD I, score
	LD V0, [I]
	ADD V0, 1
	LD [I], V0
	LD V0, 1
	LD ST, V0
	CALL code_3E6
	LD I, data_A44
	LD V0, 0
	LD V1, 0
	LD [I], V1
	JP code_24E
code_1FE:
	LD VA, 0
code_200:
	CALL code_25E
	CALL code_25A
	ADD VA, 1
	SE VA, 5
	JP code_200
	CALL code_25E
	JP code_24E
code_20E:
	LD V2, V0
	LD V3, V0
	SHR V2
	SHR V2
	SHR V2
	LD I, level
	LD V0, [I]
	LD I, data_A57
	ADD I, V0
	ADD I, V2
	LD V0, [I]
	SNE V0, 0
	RET
	LD V0, [I]
	ADD V0, 255
	LD V2, V0
	LD V0, 0
	LD [I], V0
	SNE V2, 0
	JP code_244
	LD V0, V2
	LD [I], V0
	LD V2, 16
	ADD I, V2
	LD V0, 0
	LD [I], V0
	JP code_24E
code_244:
	LD V0, 248
	AND V0, V3
	LD V1, 44
	LD I, sprite_8_4
	DRW V0, V1, 4
code_24E:
	CALL code_274
	LD I, data_A50
	LD V0, 0
	LD V1, 0
	LD [I], V1
	RET
code_25A:
	LD V9, 1
	JP code_262
code_25E:
	LD V9, 255
	JP code_262
code_262:
	CALL display_dca
	LD V0, 1
	LD ST, V0
	LD I, dca_guns
	LD V0, [I]
	ADD V0, V9
	LD [I], V0
	CALL display_dca
	JP delay_6
code_274:
	LD I, data_A50
	LD V1, [I]
	LD I, data_8F6
	DRW V0, V1, 3
	RET
code_27E:
	LD I, data_A4D
	LD V0, [I]
	ADD V0, 255
	LD [I], V0
	SE V0, 0
	RET
	LD V0, 5
	LD [I], V0
	LD V5, 0
	CALL code_318
	CALL code_298
	LD V5, 1
	JP code_318
code_298:
	LD I, data_A4E
	LD V1, [I]
	SNE V0, 0
	JP code_304
	SNE V0, 1
	JP code_2CC
	SNE V0, 2
	JP code_2F0
	LD V0, 10
	LD ST, V0
	LD I, data_A47
	LD V0, [I]
	SE V0, 12
	ADD V0, 1
	LD [I], V0
	ADD V1, 1
	LD I, data_A4F
	LD V0, V1
	LD [I], V0
	SE V1, 4
	RET
	LD I, data_A4E
	LD V0, 0
	LD V1, 0
	LD [I], V1
	RET
code_2CC:
	LD V0, 10
	LD ST, V0
	LD I, data_A47
	LD V0, [I]
	SE V0, 12
	ADD V0, 1
	LD [I], V0
	ADD V1, 1
	LD I, data_A4F
	LD V0, V1
	LD [I], V0
	SE V1, 4
	RET
	LD I, data_A4E
	LD V0, 2
	LD V1, 0
	LD [I], V1
	RET
code_2F0:
	LD I, data_A46
	LD V0, [I]
	ADD V0, 252
	LD [I], V0
	SE V0, 0
	RET
	LD I, data_A4E
	LD V0, 3
	LD [I], V0
	RET
code_304:
	LD I, data_A46
	LD V0, [I]
	ADD V0, 4
	LD [I], V0
	SE V0, 40
	RET
	LD I, data_A4E
	LD V0, 1
	LD [I], V0
	RET
code_318:
	LD I, data_A46
	LD V1, [I]
	LD V7, V1
	LD V6, V0
	ADD V7, 9
	LD V8, 0
	LD I, level
	LD V0, [I]
	LD V9, V0
code_32A:
	LD I, data_A48
	ADD I, V8
	LD V0, [I]
	LD I, sprite_5
	ADD I, V9
	SE V0, 0
	DRW V6, V7, 0
	SE VF, 0
	CALL code_346
	ADD V6, 18
	ADD V8, 1
	SE V8, 5
	JP code_32A
	RET
code_346:
	SNE V5, 0
	RET
	DRW V6, V7, 0
	LD I, data_A48
	ADD I, V8
	LD V0, 0
	LD [I], V0
	CALL display_score
	LD I, score
	LD V0, [I]
	ADD V0, 2
	LD [I], V0
	CALL display_score
	CALL code_3E6
	LD I, data_A44
	JP code_416
code_366:
	LD I, data_A44
	LD V1, [I]
	SNE V0, 0
	RET
	SNE V1, 44
	JP code_37E
	SNE V1, 45
	JP code_37E
	SNE V1, 46
	JP code_37E
	SE V1, 47
	RET
code_37E:
	LD V2, V0
	LD V3, V0
	SHR V2
	SHR V2
	SHR V2
	LD I, level
	LD V0, [I]
	LD I, data_A57
	ADD I, V0
	ADD I, V2
	LD V0, [I]
	SNE V0, 0
	RET
	LD V0, [I]
	ADD V0, 255
	LD V2, V0
	LD V0, 0
	LD [I], V0
	SNE V2, 0
	JP code_3B4
	LD V0, V2
	LD [I], V0
	LD V2, 16
	ADD I, V2
	LD V0, 0
	LD [I], V0
	JP code_3BE
code_3B4:
	LD V0, 248
	AND V0, V3
	LD V1, 44
	LD I, sprite_8_4
	DRW V0, V1, 4
code_3BE:
	CALL code_3E6
	LD I, data_A44
	JP code_416
code_3C4:
	LD V0, 10
	SKP V0
	RET
	LD I, data_A44
	LD V0, [I]
	SE V0, 0
	RET
	LD I, data_A43
	LD V0, [I]
	ADD V0, 7
	LD I, data_A44
	LD V1, 46
	LD [I], V1
	CALL code_3E6
	LD V0, 1
	LD ST, V0
	RET
code_3E6:
	LD I, data_A44
	LD V1, [I]
	LD I, data_8F6
	SE V0, 0
	DRW V0, V1, 3
	RET
code_3F2:
	CALL code_3E6
	LD I, data_A44
	LD V1, [I]
	ADD V1, 254
	SNE V1, 8
	JP code_416
	SNE V1, 9
	JP code_416
	LD [I], V1
	CALL code_3E6
	SE V0, 0
	SNE VF, 0
	RET
	LD V5, 0
	CALL code_318
	LD V5, 1
	CALL code_318
	RET
code_416:
	LD V0, 0
	LD V1, 0
	LD [I], V1
	RET
code_41E:
	CALL code_3C4
	CALL code_3F2
	LD V0, 3
	SKNP V0
	JP code_444
	LD V0, 12
	SKNP V0
	JP code_430
	RET
code_430:
	LD I, data_A43
	LD V0, [I]
	SNE V0, 112
	RET
	CALL code_458
	ADD V0, 1
	LD I, data_A43
	LD [I], V0
	CALL code_458
	RET
code_444:
	LD I, data_A43
	LD V0, [I]
	SNE V0, 0
	RET
	CALL code_458
	ADD V0, 255
	LD I, data_A43
	LD [I], V0
	CALL code_458
	RET
code_458:
	LD I, data_A43
	LD V0, [I]
	LD V1, 49
	LD I, sprite_6
	DRW V0, V1, 0
	RET
;********************	
; display ?
;********************
code_464:
	LD I, data_AEF  ; ?
	LD V0, [I]
	LD V3, 57
	LD V4, 34
	JP code_476
;**********************
;  display score
;**********************	
display_score:
	LD I, score
	LD V0, [I]
	LD V3, 34
	LD V4, 3
;***************************
; convert to BCD & display
;***************************
code_476:
	LD I, BCD
	LD B, V0
	LD V2, [I]
	LD F, V0
	CALL code_486
	LD F, V1
	CALL code_486
	LD F, V2
code_486:
	DRW V3, V4, 5
	ADD V3, 5
	RET
;**************************
; display dcagun_sprite
;**************************	
display_dca:
	LD I, dca_guns
	LD V0, [I]
	SNE V0, 0
	RET
	LD V1, 77
	LD V2, 1
	LD I, dcagun_sprite
code_49A:
	DRW V1, V2, 7
	ADD V1, 8
	ADD V0, 255
	SE V0, 0
	JP code_49A
	RET
;******************	
; draw lives_sprite
;******************
draw_lives:
	LD V0, 101
	LD V1, 0
	LD I, lives_sprite
; draw 32x8 sprite
code_4AC:
	LD V2, 8
	LD V3, 0
code_4B0:
	DRW V0, V1, 8
	ADD V0, 8
	ADD I, V2
	ADD V3, 1
	SE V3, 4
	JP code_4B0
	RET
;******************	
; draw score_sprite
;******************
draw_score:
	LD V0, 0
	LD V1, 0
	LD I, score_sprite
	JP code_4AC
;************************	
code_4C6:
	LD V1, 0
	LD V2, 44
	LD V3, 0
	LD I, level
	LD V0, [I]
	LD V4, V0
code_4D2:
	LD I, data_A67
	ADD I, V4
	ADD I, V3
	LD V0, [I]
	LD I, sprite_8_4
	SE V0, 0
	DRW V1, V2, 4
	ADD V1, 8
	ADD V3, 1
	SE V3, 16
	JP code_4D2
	RET
;*********************
;  set intro
;*********************	
display_intro:
	CALL code_55C  ; scroll left intro
	CALL code_514  ; display Get Ready!
	CALL code_52C  ; display Level
	CALL code_4F6  ; tone sequence
	CALL code_56A  ; scroll level right
	RET
code_4F6:
	CALL code_50E
	CALL delay_12
	CALL code_50E
	CALL delay_6
	CALL code_50E
	CALL delay_6
	CALL code_50E
	CALL delay_12
	CALL code_50E
	CALL delay_12
	CALL code_50E
	JP delay_12
; beep
code_50E:
	LD V0, 3
	LD ST, V0
	RET
;*****************************
; draw sprite Get Ready! 64x8
;*****************************	
code_514:
	LD V0, 32
	LD V1, 12
	LD I, sprite_9f9  ; get ready sprite
	LD V2, 8
	LD V3, 0
code_51E:
	DRW V0, V1, 8
	ADD V0, 8
	ADD I, V2
	ADD V3, 1
	SE V3, 8
	JP code_51E
	RET
; draw Level sprite	
code_52C:
	LD V0, 48
	LD V1, 32
	LD I, sprite_4  ; Level sprite
	LD V2, 8
	LD V3, 0
code_536:
	DRW V0, V1, 8
	ADD V0, 8
	ADD I, V2
	ADD V3, 1
	SE V3, 4
	JP code_536
	LD I, level ; level number
	LD V0, [I]
	SHR V0 ; level are bits 5:7
	SHR V0
	SHR V0
	SHR V0
	SHR V0 
	ADD V0, 1
	LD LF, V0
	LD V0, 59
	LD V1, 41
	DRW V0, V1, 10
	RET
;*****************************
; scroll intro screen left
;*****************************	
code_55C:
	LD V1, 0
code_55E:
	CALL delay_1
	SCL
	ADD V1, 1
	SE V1, 32
	JP code_55E
	RET
;**********************************
; scroll Get Ready screen right
;**********************************	
code_56A:
	LD V1, 0
code_56C:
	CALL delay_1
	SCR
	ADD V1, 1
	SE V1, 32
	JP code_56C
	RET
	
code_578:
	LD V1, 0
code_57A:
	CALL delay_1
	SCD 4
	ADD V1, 1
	SE V1, 16
	JP code_57A
	RET
;***************************
; animation
;***************************	
opening_anim:
	LD I, display_toggle ;display toggle delay
	LD V0, 100
	LD [I], V0 ; initial display_toggle=100
	CALL draw_gameover
	CALL draw_lives
	CALL display_dca
	CALL draw_score
	CALL display_score
	CALL draw_16dots ; display 16 dots at random.
; wait button loop.
; switch display between:
;    Gameover! and
;    Spacefight2091!
code_598: 
	CALL delay_1
	CALL code_600 ; erase this dots generation
	CALL code_5A6 ; display switch 
	LD V0, FIRE_BTN
	SKP V0
	JP code_598
	RET
;*******************************
; toggle Gameover! sprite
; toggle Spacefight2091! sprite
;*******************************	
code_5A6:
	LD I, display_toggle
	LD V0, [I]
	ADD V0, 255
	LD [I], V0
	SE V0, 0
	RET
	LD V0, 100
	LD [I], V0
	CALL draw_gameover ; erase Gameover! sprite
	LD I, Spacefight ; draw Spacefight20191! sprite
	LD V0, 16
	LD V1, 24
	LD V2, 32
	LD V3, 0
code_5C2:
	DRW V0, V1, 0
	ADD V0, 16
	ADD I, V2
	ADD V3, 1
	SE V3, 6
	JP code_5C2
	RET
;*********************
; draw Gameover! sprite
;********************* 	
draw_gameover:
	LD I, sprite_gameover
	LD V0, 32
	LD V1, 24
	LD V2, 32
	LD V3, 0
code_5DA:
	DRW V0, V1, 0
	ADD V0, 16
	ADD I, V2
	ADD V3, 1
	SE V3, 4
	JP code_5DA
	RET
;********************
; draw 16 dots
;********************	
draw_16dots:
	LD I, dot_index
	LD V0, 0
	LD [I], V0 ;initial dot_index=0
	LD V2, V0
	LD V4, 0
code_5F2: ; 
	CALL code_628 
	ADD V2, 1
	LD V0, V2
	ADD V4, 1
	SE V4, 16
	JP code_5F2
	RET
;**************************
; erase last dot displayed
; display another and store
; its index in dot_index
;**************************	
code_600:
	LD I, dot_index
	LD V0, [I]
	LD V2, V0
	LD V4, V0
	CALL code_628 ; draw dot
	LD I, dot_pos
	SHL V2
	ADD I, V2
	RND V0, #7F
	RND V1, #3F
	LD [I], V1  ; new coordinates for dot_pos[v2]
	LD I, dot_sprite
	DRW V0, V1, 1
	LD V3, 15
	ADD V4, 1
	AND V4, V3
	LD V0, V4
	LD I, dot_index ; store next dot index.
	LD [I], V0
	RET
;******************	
; draw dot
; input:
;   V0 array index
;******************
code_628:
	LD I, dot_pos
	SHL V0
	ADD I, V0
	LD V1, [I]
	LD I, dot_sprite
	DRW V0, V1, 1
	RET
;*******************	
;  various delays
;******************
delay_12:
	LD V0, 12
	JP delay_load
delay_6:
	LD V0, 6
	JP delay_load
delay_1:
	LD V0, 1
delay_load:
	LD DT, V0
;***************
;  delay loop
;***************	
code_642:
	LD V0, DT
	SE V0, 0
	JP code_642
	RET

dot_pos:  ;store coordinates of 16 displayed blinking dots
	DB #0A, #11, #5B, #22, #5B, #29, #75, #38
	DB #54, #11, #0C, #09, #34, #13, #78, #34
	DB #26, #04, #06, #1A, #0C, #22, #20, #0A
	DB #00, #16, #06, #05, #3F, #07, #00, #1E

data_2:
	DB #00, #12, #24, #36, #48
sprite_2:
	DB #00, #00, #00, #00, #00, #00, #00, #00
	DB #00, #00, #00, #00, #00, #00, #00, #00
	DB #00, #00, #00, #00, #00, #00, #00, #00
	DB #00, #00, #00, #00, #00, #00, #00, #00
	DB #00, #00, #00, #00, #00, #00, #01, #01
	DB #01, #01, #00, #00, #00, #00, #00, #00
	DB #00, #00, #00, #00, #00, #00, #01, #01
	DB #01, #01, #00, #00, #00, #00, #00, #00
	DB #00, #00, #00, #02, #02, #02, #00, #00
	DB #00, #00, #01, #01, #01, #00, #00, #00
	DB #00, #00, #00, #01, #01, #01, #00, #00
	DB #00, #00, #01, #01, #01, #00, #00, #00
	DB #00, #05, #05, #00, #00, #00, #05, #00
	DB #00, #05, #00, #00, #00, #05, #05, #00
	DB #00, #01, #01, #00, #00, #00, #01, #00
	DB #00, #01, #00, #00, #00, #01, #01, #00
	DB #0A, #0A, #00, #00, #0A, #0A, #00, #00
	DB #00, #00, #0A, #0A, #00, #00, #0A, #0A
	DB #01, #01, #00, #00, #01, #01, #00, #00
	DB #00, #00, #01, #01, #00, #00, #01, #01
	DB #14, #14, #14, #14, #14, #14, #14, #14
	DB #14, #14, #14, #14, #14, #14, #14, #14
	DB #01, #01, #01, #01, #01, #01, #01, #01
	DB #01, #01, #01, #01, #01, #01, #01, #01

sprite_gameover:
	DB #3C, #00, #7C, #00, #E0, #00, #C0, #00
	DB #CC, #71, #CC, #FB, #CD, #DB, #CD, #9B
	DB #CD, #9B, #FD, #FB, #7C, #FB, #00, #00
	DB #00, #00, #00, #00, #FF, #FF, #FF, #FF
	DB #00, #00, #00, #00, #00, #00, #00, #00
	DB #F0, #E0, #F9, #F0, #7D, #98, #6D, #F8
	DB #6D, #80, #6D, #F8, #6C, #F8, #00, #00
	DB #00, #00, #00, #00, #FF, #FF, #FF, #FF
	DB #38, #00, #7C, #00, #EC, #00, #CC, #00
	DB #CD, #99, #CD, #9B, #CD, #9B, #CD, #9B
	DB #CD, #9B, #FC, #F3, #78, #61, #00, #00
	DB #00, #00, #00, #00, #FF, #FF, #FF, #FF
	DB #00, #07, #00, #07, #00, #06, #00, #06
	DB #C1, #CC, #E3, #CC, #37, #08, #F6, #08
	DB #06, #00, #F6, #18, #F6, #18, #00, #00
	DB #00, #00, #00, #00, #FF, #FF, #FF, #FF

sprite_3: ; 
	DB #FD, #FD, #11, #31, #31, #31, #31, #31
	DB #A1, #B3, #BF, #BF, #B3, #B3, #B3, #B3
	DB #1C, #3C, #70, #60, #78, #60, #7C, #3C
	DB #0E, #1F, #1B, #19, #1F, #19, #1F, #1F
	DB #0E, #1F, #BB, #B3, #33, #B3, #BF, #1E
	DB #66, #76, #7E, #6E, #66, #66, #66, #66
	DB #CC, #CC, #CD, #CD, #CC, #EC, #7D, #3D
	DB #70, #F3, #83, #E0, #F0, #33, #F3, #E0

sprite_4: ; level sprite
	DB #C0, #C1, #C3, #C3, #C3, #E3, #7B, #39
	DB #EC, #EC, #8C, #0C, #CC, #0F, #E7, #E3
	DB #C7, #CF, #DC, #D8, #DE, #D8, #9F, #0F
	DB #60, #60, #60, #60, #60, #70, #3C, #1C

sprite_5:
	DB #00, #00, #97, #D2, #03, #80, #01, #00
	DB #0F, #E0, #3F, #F8, #55, #54, #AB, #BA
	DB #FF, #6E, #BA, #BA, #55, #54, #3F, #F8
	DB #4F, #E4, #00, #00, #80, #02, #00, #00
	DB #03, #C0, #06, #60, #04, #A0, #03, #C0
	DB #04, #20, #0B, #30, #14, #58, #14, #28
	DB #10, #58, #12, #A8, #0D, #50, #16, #A8
	DB #23, #C4, #7F, #FE, #40, #02, #00, #00
	DB #4A, #AA, #15, #50, #4A, #AA, #D5, #53
	DB #E4, #27, #7F, #FE, #39, #9C, #0C, #30
	DB #06, #60, #07, #E0, #33, #CC, #2B, #D4
	DB #07, #E0, #03, #C0, #01, #80, #00, #00
	DB #03, #C0, #05, #60, #06, #A0, #03, #C0
	DB #1B, #D8, #2D, #74, #5E, #BA, #A5, #65
	DB #C6, #A3, #C7, #E3, #CD, #B3, #DA, #5B
	DB #54, #2A, #18, #18, #18, #18, #30, #0C
	DB #30, #0C, #48, #12, #A4, #25, #84, #21
	DB #4C, #32, #32, #4C, #02, #40, #1F, #F8
	DB #20, #AC, #28, #54, #20, #AC, #1F, #F8
	DB #7F, #FE, #92, #49, #92, #49, #92, #49
	DB #3F, #FC, #40, #02, #5A, #FA, #50, #0A
	DB #43, #EA, #52, #4A, #47, #CA, #50, #0A
	DB #5F, #FA, #40, #02, #3F, #FC, #0F, #F0
	DB #38, #1C, #54, #36, #AC, #2B, #F8, #1F

sprite_6: ; dca gun
	DB #01, #00, #01, #00, #01, #00, #01, #00
	DB #01, #00, #03, #80, #03, #80, #03, #80
	DB #07, #C0, #C6, #C6, #7D, #7C, #3F, #F8
	DB #7F, #FC, #C3, #86, #01, #00, #00, #00

dcagun_sprite:
	DB #10, #10, #10, #28, #7C, #D6, #FE
data_8F6:
	DB #80, #80, #80
score_sprite:
	DB #38, #79, #C3, #F3, #7B, #1B, #FB, #F1
	DB #E3, #E7, #8E, #0C, #0C, #0C, #EF, #E7
	DB #8E, #DF, #DB, #D9, #DF, #DF, #DB, #99
	DB #0E, #1E, #B8, #B0, #BC, #30, #BE, #9E

lives_sprite:
	DB #C3, #C3, #C3, #C3, #C3, #E3, #7B, #3B
	DB #66, #66, #66, #66, #66, #7E, #3C, #18
	DB #38, #79, #E3, #C3, #F1, #C0, #FB, #7B
	DB #E0, #E0, #00, #C0, #E0, #60, #E0, #C0

spacefight:  ; Spacefight2091!
	DB #3C, #00, #7C, #00, #E0, #00, #C0, #00
	DB #F1, #E0, #79, #F1, #1D, #BB, #0D, #9B
	DB #0D, #9B, #FD, #FB, #F9, #F1, #01, #80
	DB #01, #80, #01, #80, #FC, #3F, #FF, #FF
	DB #00, #00, #00, #00, #00, #00, #00, #00
	DB #E1, #CE, #F3, #DF, #B7, #19, #36, #1F
	DB #36, #18, #F7, #DF, #F3, #CF, #00, #00
	DB #00, #00, #00, #00, #FF, #FF, #FF, #FF
	DB #0F, #00, #1F, #00, #38, #00, #30, #00
	DB #3E, #C7, #3E, #CF, #B0, #1D, #B0, #D9
	DB #30, #D9, #B0, #DF, #B0, #CF, #00, #01
	DB #00, #0F, #00, #0F, #FF, #E0, #FF, #FF
	DB #30, #60, #30, #60, #30, #60, #30, #60
	DB #3C, #78, #BE, #78, #B7, #60, #B3, #60
	DB #B3, #70, #B3, #3C, #B3, #1C, #80, #00
	DB #80, #00, #00, #00, #7F, #FF, #FF, #FF
	DB #3C, #3C, #7E, #7E, #E6, #E6, #C6, #C6
	DB #0E, #C6, #1C, #C6, #38, #C6, #70, #C6
	DB #E0, #C6, #FE, #FE, #FE, #7C, #00, #00
	DB #00, #00, #00, #00, #FF, #FF, #FF, #FF
	DB #3C, #C7, #7E, #C7, #E6, #C6, #C6, #C6
	DB #C6, #CC, #FE, #CC, #7E, #C8, #06, #C8
	DB #06, #C0, #FE, #D8, #FC, #D8, #00, #00
	DB #00, #00, #00, #00, #FF, #FF, #FF, #FF

sprite_9f9: ; Get ready sprite
	DB #3C, #7C, #E1, #C1, #CD, #CD, #FD, #7C
	DB #77, #F7, #C0, #81, #E1, #81, #F1, #F1
	DB #E0, #E0, #80, #80, #80, #80, #80, #80
	DB #F0, #F8, #DD, #CD, #FD, #F9, #DD, #CC
	DB #71, #F3, #C7, #86, #E7, #86, #F6, #F6
	DB #C7, #EF, #6D, #6C, #EC, #6C, #6F, #6F
	DB #19, #99, #D9, #DF, #CF, #C6, #C6, #86
	DB #98, #98, #98, #98, #18, #00, #18, #18

dot_sprite:
	DB #80
sprite_8_4:
	DB #FF, #AA, #55, #FF
display_toggle: ; 1 byte variable initialized to 100
	DB #00
data_AEF: 
	DB #255
level: ; (level<<5)
	DB #00
dca_guns:
	DB #00
score:  
	DB #00
data_A43:
    DB	#56
data_A44:
    DB	#00
data_A45:
	DB #00
data_A46:
    DB	#00
data_A47:
    DB	#00
data_A48:
    DB 1
data_A49:	
	DB 1
data_A4A:
    DB 1
data_A4B:	
	DB 1
data_A4C:
    DB 1
data_A4D:
    DB #00
data_A4E:
    DB	#00
data_A4F:
    DB #00
data_A50:
    DB	#00
data_A51:
    DB #00
data_A52:	
    DB 0
BCD:
	0,0,0
dot_index:
    DB 0
data_A57:
    DB 0,0,0,0,0,0,0,0
    DB 0,0,0,0,0,0,0,0
data_A67:
    DB 0,0,0,0,0,0,0,0
    DB 0,0,0,0,0,0,0,0
    DB 0,0,0,0,0,0,0,0
    DB 0,0,0,0,0,0,0,0
    DB 0,0,0,0,0,0,0,0
    DB 0,0,0,0,0,0,0,0
    DB 0,0,0,0,0,0,0,0
    DB 0,0,0,0,0,0,0,0
    DB 0,0,0,0,0,0,0,0
    DB 0,0,0,0,0,0,0,0
    DB 0,0,0,0,0,0,0,0
    DB 0,0,0,0,0,0,0,0
    DB 0,0,0,0,0,0,0,0
    DB 0,0,0,0,0,0,0,0
    DB 0,0,0,0,0,0,0,0
    DB 0,0,0,0,0,0,0,0
    DB 0,0,0,0,0,0,0,0
    DB 0,0,0,0,0,0,0,0
    DB 0,0,0,0,0,0,0,0
    DB 0,0,0,0,0,0,0,0
    DB 0,0,0,0,0,0,0,0
    DB 0,0,0,0,0,0,0,0
	

