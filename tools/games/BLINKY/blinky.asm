; packman clone
; blinky 2.00 Blinky [Hans Christian Egeberg, 1991]
; Adapted for CHIPcon v2 by Jacques Deschenes, 2015/08
; 


EQU UP 2
EQU DOWN 4
EQU LEFT 8
EQU RIGHT 16
EQU SELECT 32
EQU SUSPEND 32
EQU SCORE_DELAY 20
EQU BLINK_DELAY 30
EQU COLL_DELAY  90
EQU ANIM_DELAY  5
EQU MAX_SPEED 10

	JP splash	
credits:
	ASCII "blinky 2.00 C. Egeberg 1991\nJacques Deschenes, 2015"
splash:
	cls
	LD I, credits
	ld v0, 0
	scry v1
	shr v1
	prt v0,v1
	scry v1
splash_loop:	
	ld v0, SELECT
	sknp v0
	jp splash_abort
	ld v0, 2
	call delay
	scu 1
	add v1,-1
	se v1, 0
	jp splash_loop
splash_abort:
    ld v0, SELECT
	sknp v0
	jp .-2
; added by J.D. 2015
set_speed:
	CLS
	LD V0, 0
	LD V1, 0
	LD I, speed_prompt
	PRT V0,V1
	ld I, speed
	ld v0, [I]
	ld v2, v0
	LD V3, MAX_SPEED
	SUB V3, V2
	LD F, V3
	LD V0, 42
    DRW V0,V1, 5
	LD V0, K
	SNE V0, UP
	CALL incr_speed
	SNE V0, DOWN
	CALL decr_speed
	SE V0, SELECT
	JP set_speed
	JP game_init
decr_speed:
    SE v2, MAX_SPEED 
	ADD v2, 1
	JP .+3
incr_speed:
	SE v2, 1
	ADD v2, 255
	ld v0,v2
	ld I, speed
	ld [I], v0
	LD V0, 15
    call delay
    ret	
game_init:
	CLS
	XOR V0, V0
	XOR V1, V1
	LD I, score
	LD [I], V1
	LD V0, 5
	LD I, data_6E6
	LD [I], V0
	XOR V7, V7
code_02C: ; new game loop
	XOR V6, V6
	CALL copy_maze	;copy maze to free_space
	CLS
	CALL draw_maze	
code_034:	; glutton life loop
	LD VE, 64
	AND V7, VE
	LD VE, 39
	OR V7, VE
	LD V8, 52		; V8<-glutton_x
	LD V9, 24		; V9<-glutton_y
	LD VA, 112		; VA<-predator1_x
	LD VB, 0		; VB<-predataor1_y
	LD VC, 4		; VC<-predateor2_x
	LD VD, 52		; VD<-predator2_y
	CALL draw_glutton	
	LD I, predator
	DRW VA, VB, 8   ; draw predator 1
	DRW VC, VD, 8   ; draw predator 2
code_050: ; delay loop
	LD I, speed
	LD V0, [I]
	call delay
	CALL btns_check	
	SE VE, 0
	JP code_07E	
code_056:
	LD I, data_6E6
	LD V0, [I]
	LD V5, V0
	RND V4, #FF
	AND V4, V5
	CALL code_308	
	RND V4, #FF
	AND V4, V5
	CALL code_430	
	LD V0, SUSPEND
	SKNP V0  
	CALL wait_s_release	;wait SUSPEND release
	SE V6, 247
	JP code_050	
	LD VE, V6
	CALL update_score	
	LD VE, 100
	CALL update_score	
	CALL wait_s_release	;wait SUSPEND release
	JP code_02C	
code_07E:
	LD V0, DT
	SNE V0, 0
	JP code_122	
	LD V0, V8
	SHR V0
	SHR V0
	LD V1, VA
	SHR V1
	SHR V1
	SUB V0, V1
	SNE V0, 0
	JP code_0A0	
	SNE V0, 1
	JP code_0A0	
	SNE V0, 255
	JP code_0A0	
	JP code_0D2	
code_0A0:
	LD V0, V9
	SHR V0
	SHR V0
	LD V1, VB
	SHR V1
	SHR V1
	SUB V0, V1
	SNE V0, 0
	JP code_0BC	
	SNE V0, 1
	JP code_0BC	
	SNE V0, 255
	JP code_0BC	
	JP code_0D2	
code_0BC:
	LD I, predator
	DRW VA, VB, 8	; erase predator1
	LD VA, 112
	LD VB, 0
	DRW VA, VB, 8	; draw predator1 at maze top-right
	LD VE, 243
	AND V7, VE		; ; V7[2:3] predator1 direction
	LD VE, 4		 
	OR V7, VE
	LD VE, 50
	CALL update_score	
code_0D2:
	LD V0, V8
	SHR V0
	SHR V0
	LD V1, VC
	SHR V1
	SHR V1
	SUB V0, V1
	SNE V0, 0
	JP code_0EE	
	SNE V0, 1
	JP code_0EE	
	SNE V0, 255
	JP code_0EE	
	JP code_056	
code_0EE:
	LD V0, V9
	SHR V0
	SHR V0
	LD V1, VD
	SHR V1
	SHR V1
	SUB V0, V1
	SNE V0, 0
	JP code_10A	
	SNE V0, 1
	JP code_10A	
	SNE V0, 255
	JP code_10A	
	JP code_056	
code_10A:
	LD I, predator
	DRW VC, VD, 8	; erase predator2
	LD VC, 4
	LD VD, 52
	DRW VC, VD, 8	; draw predator2 to at 4,52
	LD VE, 207
	AND V7, VE		; V7[4:5] are predator2 direction
	LD VE, 32
	OR V7, VE
	LD VE, 25
	CALL update_score	
	JP code_056	
code_122: ; a predator eated glutton
	LD V0, COLL_DELAY
	CALL time_out_select	
	CALL draw_glutton	
	LD I, predator
	DRW VA, VB, 8
	DRW VC, VD, 8
	LD VE, 64
	XOR V7, VE		;V7[6] glutton life count toggle
	LD V0, V7
	AND V0, VE
	SE V0, 0		; if V7[6] is 0 here glutton spent is 2 lifes
	JP code_034	;new life cycle
	LD VE, V6   ; 
	CALL update_score	
	CALL update_max_score	
	CLS
	LD V6, 36
	LD V7, 20
	LD I, max_score
	CALL print_bignum	;display max_score
	LD V6, 36
	LD V7, 32
	LD I, score
	CALL print_bignum	;display_score
	LD V4, 0
	LD V5, 16
	LD V6, 1
	LD V7, 15
code_15A:
	LD I, eyes_left
	DRW V4, V6, 0
	LD I, eyes_right
	DRW V5, V6, 0
	LD V0, SCORE_DELAY
	CALL time_out_select	
	SE VE, 0
	JP code_1D8	
	LD I, eyes_left
	DRW V4, V6, 0
	LD I, eyes_right
	DRW V5, V6, 0
	ADD V4, 4
	ADD V5, 4
	SE V4, 96
	JP code_15A	
code_17A:
	LD I, eyes_left
	DRW V4, V6, 0
	LD I, eyes_right
	DRW V5, V6, 0
	LD V0, SCORE_DELAY
	CALL time_out_select	
	SE VE, 0
	JP code_1D8	
	LD I, eyes_left
	DRW V4, V6, 0
	LD I, eyes_right
	DRW V5, V6, 0
	ADD V6, 4
	SE V6, 45
	JP code_17A	
code_198:
	LD I, eyes_left
	DRW V4, V6, 0
	LD I, eyes_right
	DRW V5, V6, 0
	LD V0, SCORE_DELAY
	CALL time_out_select	
	SE VE, 0
	JP code_1D8	
	LD I, eyes_left
	DRW V4, V6, 0
	LD I, eyes_right
	DRW V5, V6, 0
	ADD V4, 252
	ADD V5, 252
	SE V4, 0
	JP code_198	
code_1B8:
	LD I, eyes_left
	DRW V4, V6, 0
	LD I, eyes_right
	DRW V5, V6, 0
	LD V0, SCORE_DELAY
	CALL time_out_select	
	SE VE, 0
	JP code_1D8	
	LD I, eyes_left
	DRW V4, V6, 0
	LD I, eyes_right
	DRW V5, V6, 0
	ADD V6, 252
	SE V6, 1
	JP code_1B8	
	JP code_15A	
code_1D8:
	LD I, eyes_right
	DRW V5, V6, 0
	LD I, eye_blink
	DRW V5, V6, 0
	LD V0, BLINK_DELAY
	LD DT, V0
	LD V0, DT
	SE V0, 0
	JP .-2
	JP game_init	
btns_check: ; buttons check
	LD V3, V7
	LD VE, 3
	AND V3, VE	; glutton direction
	LD V4, V8	; glutton x
	LD V5, V9	; glutton y
	LD VE, DOWN
	SKNP VE
	JP code_244	;glutton move down
	LD VE, UP
	SKNP VE
	JP code_25C	;glutton move up
	LD VE, RIGHT
	SKNP VE
	JP code_274	;glutton move right
	LD VE, LEFT
	SKNP VE
	JP code_28C	;glutton move left
code_204:
	SNE V3, 3
	ADD V5, 4	; down 4 pixels
	SNE V3, 0
	ADD V5, 252	; up 4 pixels
	SNE V3, 2
	ADD V4, 4	; right 4 pixels
	SNE V3, 1
	ADD V4, 252	; left 4 pixels
	LD V0, V4
	LD V1, V5
	CALL code_5D0	
	LD V2, V0
	LD VE, 8
	AND V0, VE
code_220:
	SE V0, 0
	JP code_2A4	
	LD VE, 7
	LD V0, V2
	AND V2, VE
	SNE V2, 5
	JP code_2AC	
	SNE V2, 6
	JP code_2C4	
	SNE V2, 7
	JP code_2FE	
code_236:
	CALL draw_glutton	
	LD VE, 252
	AND V7, VE
	OR V7, V3
	LD V8, V4
	LD V9, V5
	JP draw_glutton	
code_244:	;move down
	LD V0, V4
	LD V1, V5
	ADD V1, 4
	CALL code_5D0	
	LD V2, V0
	LD VE, 8
	AND V0, VE
	SE V0, 0
	JP code_204	
	LD V3, 3
	ADD V5, 4
	JP code_220	
code_25C:	; move up
	LD V0, V4
	LD V1, V5
	ADD V1, 252
	CALL code_5D0	
	LD V2, V0
	LD VE, 8
	AND V0, VE
	SE V0, 0
	JP code_204	
	LD V3, 0
	ADD V5, 252
	JP code_220	
code_274:	; move right
	LD V0, V4
	LD V1, V5
	ADD V0, 4
	CALL code_5D0	
	LD V2, V0
	LD VE, 8
	AND V0, VE
	SE V0, 0
	JP code_204	
	LD V3, 2
	ADD V4, 4
	JP code_220	
code_28C:	; move left
	LD V0, V4
	LD V1, V5
	ADD V0, 252
	CALL code_5D0	
	LD V2, V0
	LD VE, 8
	AND V0, VE
	SE V0, 0
	JP code_204	
	LD V3, 1
	ADD V4, 252
	JP code_220	
code_2A4:
	CALL draw_glutton	
	DRW V8, V9, 8
	LD VE, VF
	RET
code_2AC:
	LD VE, 240
	AND V0, VE
	OR V0, V3
	LD [I], V0
	LD I, food_dot
	DRW V4, V5, 8
	ADD V6, 1
	LD V1, 5
	LD V0, DT
	SNE V0, 0
	LD ST, V1
	JP code_236	
code_2C4:
	LD VE, 240
	AND V0, VE
	OR V0, V3
	LD [I], V0
	LD I, food_bar
	DRW V4, V5, 8
	ADD V6, 4
	LD V0, VA
	LD V1, VB
	CALL code_5D0	
	LD VE, 240
	AND V0, VE
	SE V0, 0
	JP code_2E4	
	LD VE, 12
	XOR V7, VE
code_2E4:
	LD V0, VC
	LD V1, VD
	CALL code_5D0	
	LD VE, 240
	AND V0, VE
	SE V0, 0
	JP code_2F6
	LD VE, 48
	XOR V7, VE
code_2F6:
	LD V0, 255
	LD ST, V0
	LD DT, V0
	JP code_236	
code_2FE:
	SNE V3, 1
	LD V4, 116
	SNE V3, 2
	LD V4, 0
	JP code_236	
code_308:
	LD V2, V7
	LD V3, V7
	LD VE, 12
	AND V2, VE
	LD V0, VA
	LD V1, VB
	CALL code_5D0	
	LD I, predator
	LD VE, 240
	AND V0, VE
	SE V0, 0
	JP code_336	
code_320:
	DRW VA, VB, 8
	SNE V2, 12
	ADD VB, 4
	SNE V2, 0
	ADD VB, 252
	SNE V2, 8
	ADD VA, 4
	SNE V2, 4
	ADD VA, 252
	DRW VA, VB, 8
	RET
code_336:
	LD VE, 128
	LD V1, DT
	SE V1, 0
	JP code_3E6	
	SE V4, 0
	JP code_3E6	
	LD V1, V0
	SHL V3
	SE VF, 0
	JP code_368	
	LD V3, V9
	SUB V3, VB
	SNE VF, 0
	JP code_39E	
	SE V3, 0
	JP code_386	
	XOR V7, VE
	LD V3, V8
	SUB V3, VA
	SNE VF, 0
	JP code_3CE	
	SE V3, 0
	JP code_3B6	
	XOR V7, VE
	JP code_3E6	
code_368:
	LD V3, V8
	SUB V3, VA
	SNE VF, 0
	JP code_3CE	
	SE V3, 0
	JP code_3B6	
	XOR V7, VE
	LD V3, V9
	SUB V3, VB
	SNE VF, 0
	JP code_39E	
	SE V3, 0
	JP code_386	
	XOR V7, VE
	JP code_3E6	
code_386:
	LD V3, 64
	AND V1, V3
	SNE V1, 0
	JP code_3E6	
	DRW VA, VB, 8
	ADD VB, 4
	DRW VA, VB, 8
	LD VE, 243
	AND V7, VE
	LD V2, 12
	OR V7, V2
	RET
code_39E:
	LD V3, 16
	AND V1, V3
	SNE V1, 0
	JP code_3E6	
	DRW VA, VB, 8
	ADD VB, 252
	DRW VA, VB, 8
	LD VE, 243
	AND V7, VE
	LD V2, 0
	OR V7, V2
	RET
code_3B6:
	LD V3, 32
	AND V1, V3
	SNE V1, 0
	JP code_3E6	
	DRW VA, VB, 8
	ADD VA, 4
	DRW VA, VB, 8
	LD VE, 243
	AND V7, VE
	LD V2, 8
	OR V7, V2
	RET
code_3CE:
	LD V3, 128
	AND V1, V3
	SNE V1, 0
	JP code_3E6	
	DRW VA, VB, 8
	ADD VA, 252
	DRW VA, VB, 8
	LD VE, 243
	AND V7, VE
	LD V2, 4
	OR V7, V2
	RET
code_3E6:
	RND V1, #F0
	AND V0, V1
	SE V0, 0
	JP code_3F6	
code_3EE:
	LD VE, 12
	XOR V7, VE
	XOR V2, VE
	JP code_320	
code_3F6:
	DRW VA, VB, 8
	SHL V0
	SNE VF, 0
	JP code_404	
	LD V2, 4
	ADD VA, 252
	JP code_426	
code_404:
	SHL V0
	SNE VF, 0
	JP code_410	
	LD V2, 12
	ADD VB, 4
	JP code_426	
code_410:
	SHL V0
	SNE VF, 0
	JP code_41C	
	LD V2, 8
	ADD VA, 4
	JP code_426	
code_41C:
	SHL V0
	SNE VF, 0
	JP code_3EE	
	LD V2, 0
	ADD VB, 252
code_426:
	DRW VA, VB, 8
	LD VE, 243
	AND V7, VE
	OR V7, V2
	RET
code_430:
	LD V2, V7
	LD V3, V7
	LD VE, 48
	AND V2, VE
	LD V0, VC
	LD V1, VD
	CALL code_5D0	
	LD I, predator
	LD VE, 240
	AND V0, VE
	SE V0, 0
	JP code_45E	
code_448:
	DRW VC, VD, 8
	SNE V2, 48
	ADD VD, 4
	SNE V2, 0
	ADD VD, 252
	SNE V2, 32
	ADD VC, 4
	SNE V2, 16
	ADD VC, 252
	DRW VC, VD, 8
	RET
code_45E:
	LD VE, 128
	LD V1, DT
	SE V1, 0
	JP code_516	
	SE V4, 0
	JP code_516	
	LD V1, V0
	SHL V3
	SNE VF, 0
	JP code_490	
	LD V3, V9
	SUB V3, VD
	SNE VF, 0
	JP code_4C8	
	SE V3, 0
	JP code_4AE	
	XOR V7, VE
	LD V3, V8
	SUB V3, VC
	SNE VF, 0
	JP code_4FC	
	SE V3, 0
	JP code_4E2	
	XOR V7, VE
	JP code_516	
code_490:
	LD V3, V8
	SUB V3, VC
	SNE VF, 0
	JP code_4FC	
	SE V3, 0
	JP code_4E2	
	XOR V7, VE
	LD V3, V9
	SUB V3, VD
	SNE VF, 0
	JP code_4C8	
	SE V3, 0
	JP code_4AE	
	XOR V7, VE
	JP code_516	
code_4AE:
	LD V3, 64
	AND V1, V3
	SNE V1, 0
	JP code_516	
	DRW VC, VD, 8
	ADD VD, 4
	DRW VC, VD, 8
	XOR V7, VE
	LD VE, 207
	AND V7, VE
	LD V2, 48
	OR V7, V2
	RET
code_4C8:
	LD V3, 16
	AND V1, V3
	SNE V1, 0
	JP code_516	
	DRW VC, VD, 8
	ADD VD, 252
	DRW VC, VD, 8
	XOR V7, VE
	LD VE, 207
	AND V7, VE
	LD V2, 0
	OR V7, V2
	RET
code_4E2:
	LD V3, 32
	AND V1, V3
	SNE V1, 0
	JP code_516	
	DRW VC, VD, 8
	ADD VC, 4
	DRW VC, VD, 8
	XOR V7, VE
	LD VE, 207
	AND V7, VE
	LD V2, 32
	OR V7, V2
	RET
code_4FC:
	LD V3, 128
	AND V1, V3
	SNE V1, 0
	JP code_516	
	DRW VC, VD, 8
	ADD VC, 252
	DRW VC, VD, 8
	XOR V7, VE
	LD VE, 207
	AND V7, VE
	LD V2, 16
	OR V7, V2
	RET
code_516:
	RND V1, #F0
	AND V0, V1
	SE V0, 0
	JP code_528	
code_51E:
	XOR V7, VE
	LD VE, 48
	XOR V7, VE
	XOR V2, VE
	JP code_448	
code_528:
	DRW VC, VD, 8
	SHL V0
	SNE VF, 0
	JP code_536	
	LD V2, 144
	ADD VC, 252
	JP code_558	
code_536:
	SHL V0
	SNE VF, 0
	JP code_542	
	LD V2, 48
	ADD VD, 4
	JP code_558	
code_542:
	SHL V0
	SNE VF, 0
	JP code_54E	
	LD V2, 160
	ADD VC, 4
	JP code_558	
code_54E:
	SHL V0
	SNE VF, 0
	JP code_51E	
	LD V2, 0
	ADD VD, 252
code_558:
	DRW VC, VD, 8
	LD VE, 79
	AND V7, VE
	OR V7, V2
	RET
; draw_glutton
; V7(0:1) is direction
; V8 is X coord
; V9 is Y coord
draw_glutton:	
	LD V0, V7
	LD VE, 3
	AND V0, VE
	SHL V0
	LD V1, V8
	ADD V1, V9
	LD VE, 4
	AND V1, VE
	SNE V1, 0
	ADD V0, 1
	SHL V0
	SHL V0
	SHL V0
	LD I, glutton
	ADD I, V0
	DRW V8, V9, 8
	LD VE, VF
	RET
copy_maze:
	LD VE, 0
code_588:
	LD I, maze
	ADD I, VE
	ADD I, VE
	ADD I, VE
	ADD I, VE
	LD V3, [I]
	LD I, free_space
	ADD I, VE
	ADD I, VE
	ADD I, VE
	ADD I, VE
	LD [I], V3
	ADD VE, 1
	SE VE, 128
	JP code_588	
	RET
draw_maze:
	XOR V2, V2
	XOR V3, V3
	LD VE, 15
code_5AE:
	LD V0, V2
	LD V1, V3
	CALL code_5D4	
	AND V0, VE
	SHL V0
	SHL V0
	LD I, maze_sprites
	ADD I, V0
	DRW V2, V3, 4
	ADD V2, 4
	SE V2, 128
	JP code_5AE	
	XOR V2, V2
	ADD V3, 4
	SNE V3, 64
	RET
	JP code_5AE	
code_5D0:  	; V0=free_space[(V1&0xFC)*8+V0/4]
	ADD V0, 4
	ADD V1, 4
code_5D4:	; I= free_space+(V1&0xFC)*8+V0/4
	SHR V0
	SHR V0
	SHR V1
	SHR V1
	SHL V1
	SHL V1
	SHL V1
	SHL V1
	LD I, free_space
	ADD I, V1
	ADD I, V1
	ADD I, V0
	LD V0, [I]	; V0=M[I]
	RET
wait_s_release:
	LD I, data_6E6
	LD V0, [I]
	SHR V0
	LD [I], V0
	LD V0, SUSPEND
code_5FA:  ; wait SUSPEND release
	SKNP V0
	JP code_5FA	
	RET
print_bignum:	; display number in M[I..I+1]
	LD V1, [I]
	LD VE, 1
	XOR V4, V4
	LD V2, V0
	LD V3, V1
code_60A:
	LD V5, 16
	SUB V3, V5
	SNE VF, 0
	SUB V2, VE
	SNE VF, 0
	JP code_626	
	LD V5, 39
	SUB V2, V5
	SNE VF, 0
	JP code_626	
	LD V0, V2
	LD V1, V3
	ADD V4, VE
	JP code_60A	
code_626:
	LD LF, V4
	DRW V6, V7, 10
	ADD V6, 12
	XOR V4, V4
	LD V2, V0
	LD V3, V1
code_632:
	LD V5, 232
	SUB V3, V5
	SNE VF, 0
	SUB V2, VE
	SNE VF, 0
	JP code_64E	
	LD V5, 3
	SUB V2, V5
	SNE VF, 0
	JP code_64E	
	LD V0, V2
	LD V1, V3
	ADD V4, VE
	JP code_632	
code_64E:
	LD LF, V4
	DRW V6, V7, 10
	ADD V6, 12
	XOR V4, V4
	LD V2, V0
	LD V3, V1
code_65A:
	LD V5, 100
	SUB V3, V5
	SNE VF, 0
	SUB V2, VE
	SNE VF, 0
	JP code_66E	
	LD V0, V2
	LD V1, V3
	ADD V4, VE
	JP code_65A	
code_66E:
	LD LF, V4
	DRW V6, V7, 10
	ADD V6, 12
	XOR V4, V4
	LD V2, V0
	LD V3, V1
code_67A:
	LD V5, 10
	SUB V3, V5
	SNE VF, 0
	JP code_688	
	LD V1, V3
	ADD V4, VE
	JP code_67A	
code_688:
	LD LF, V4
	DRW V6, V7, 10
	ADD V6, 12
	LD LF, V1
	DRW V6, V7, 10
	RET
update_score: ; add points to score
	LD I, score
	LD V1, [I]
	ADD V1, VE
	SE VF, 0
	ADD V0, 1
	LD I, score
	LD [I], V1
	RET
update_max_score: ; check for score>max_score
	LD I, score
	LD V3, [I]
	LD VE, V0
	SUB VE, V2
	SNE VF, 0
	RET
	SE VE, 0
	JP code_6BC	
	LD VE, V1
	SUB VE, V3
	SNE VF, 0
	RET
code_6BC: ; max_score=score
	LD I, max_score
	LD [I], V1
	RET
time_out_select: ; wait SELECT button with timeout
	XOR VE, VE
	LD V2, SELECT
	LD DT, V0
code_6CA:
	SKNP V2
	JP code_6DE	
	LD V0, DT
	SE V0, 0
	JP code_6CA	
	RET
code_6DE:
	LD VE, 1 ; return VE=1 when SELECT button pushed
	RET
delay:
	ld dt, v0
	ld v0, dt
	se v0, 0
	jp .-2
	ret
	
score:
	DB #00, #00
max_score:
	DB #00, #00
data_6E6:
	DB #05, #00
glutton:	; glutton sprites
	DB #00, #22, #63, #63, #77, #7F, #3E, #1C
	DB #00, #1C, #1E, #5D, #5D, #6F, #3E, #1C
	DB #00, #3C, #7E, #0F, #07, #0F, #7E, #3C
	DB #00, #1C, #26, #7F, #7F, #7B, #06, #1C
	DB #00, #1E, #3F, #78, #70, #78, #3F, #1E
	DB #00, #1C, #32, #7F, #7F, #6F, #30, #1C
	DB #00, #1C, #3E, #7F, #77, #63, #63, #22
	DB #00, #1C, #3E, #6F, #5D, #5D, #1E, #1C

predator:	; predator sprite
	DB #00, #1C, #3E, #49, #77, #7F, #63, #7F

food_dot:	; dot food sprite
	DB #00, #00, #00, #00, #08, #00, #00, #00

food_bar:	; bar food sprite
	DB #00, #00, #00, #00, #08, #08, #00, #00

maze_sprites:	16 maze sprites 4x4
	DB #00, #00, #00, #00, #00, #00, #00, #00
	DB #00, #00, #00, #00, #00, #00, #00, #00
	DB #00, #00, #00, #00, #80, #00, #00, #00
	DB #80, #80, #00, #00, #00, #00, #00, #00
	DB #F0, #00, #00, #00, #00, #00, #00, #00
	DB #80, #80, #80, #80, #00, #00, #00, #00
	DB #F0, #80, #80, #80, #80, #80, #80, #80
	DB #F0, #00, #00, #00, #80, #00, #00, #00

maze:	; maze data
	DB #0C, #08, #08, #08, #08, #08, #08, #08
	DB #08, #08, #08, #08, #08, #08, #08, #0D
	DB #0C, #08, #08, #08, #08, #08, #08, #08
	DB #08, #08, #08, #08, #08, #08, #08, #0D
	DB #0A, #65, #05, #05, #05, #05, #E5, #05
	DB #05, #E5, #05, #05, #05, #05, #C5, #0A
	DB #0A, #65, #05, #05, #05, #05, #E5, #05
	DB #05, #E5, #05, #05, #05, #05, #C5, #0A
	DB #0A, #05, #0C, #08, #08, #0F, #05, #0C
	DB #0D, #05, #08, #08, #08, #0D, #05, #0E
	DB #0F, #05, #0C, #08, #08, #0F, #05, #0C
	DB #0D, #05, #08, #08, #08, #0D, #05, #0A
	DB #0A, #05, #0A, #65, #06, #05, #95, #0A
	DB #0A, #35, #05, #05, #C5, #0A, #35, #05
	DB #05, #95, #0A, #65, #05, #05, #95, #0A
	DB #0A, #35, #05, #06, #C5, #0A, #05, #0A
	DB #0A, #05, #0F, #05, #08, #08, #08, #08
	DB #08, #0C, #08, #0F, #05, #08, #08, #08
	DB #08, #08, #0F, #05, #08, #08, #0C, #08
	DB #08, #08, #08, #0F, #05, #0F, #05, #0A
	DB #0A, #75, #05, #B5, #05, #05, #05, #05
	DB #C5, #0A, #65, #05, #B5, #05, #E5, #05
	DB #05, #E5, #05, #B5, #05, #C5, #0A, #65
	DB #05, #05, #05, #05, #B5, #05, #D5, #0A
	DB #0A, #05, #0C, #08, #08, #08, #08, #0D
	DB #05, #0F, #05, #0C, #08, #0F, #05, #08
	DB #0F, #05, #08, #08, #0D, #05, #0F, #05
	DB #0C, #08, #08, #08, #08, #0D, #05, #0A
	DB #0F, #05, #0F, #65, #05, #05, #C5, #0A
	DB #35, #E5, #95, #0A, #65, #05, #B0, #05
	DB #05, #B5, #05, #C5, #0A, #35, #E5, #95
	DB #0A, #65, #05, #05, #C5, #0F, #05, #0F
	DB #07, #74, #05, #D5, #08, #0F, #05, #0E
	DB #0F, #05, #08, #0F, #05, #0C, #08, #08
	DB #08, #08, #0D, #05, #08, #0F, #05, #08
	DB #0F, #05, #08, #0F, #75, #05, #D4, #07
	DB #0A, #05, #0A, #35, #05, #05, #F5, #05
	DB #05, #B5, #05, #05, #D5, #08, #08, #0D
	DB #0C, #08, #0F, #75, #05, #05, #B5, #05
	DB #05, #F5, #05, #05, #95, #0A, #05, #0A
	DB #0A, #05, #08, #08, #08, #0D, #05, #0C
	DB #08, #08, #08, #0D, #35, #05, #C5, #0A
	DB #0A, #65, #05, #95, #0C, #08, #08, #08
	DB #0D, #05, #0C, #08, #08, #0F, #05, #0A
	DB #0A, #75, #05, #06, #C5, #0A, #05, #08
	DB #08, #08, #08, #08, #08, #0F, #05, #08
	DB #0F, #05, #08, #08, #08, #08, #08, #08
	DB #0F, #05, #0A, #65, #06, #05, #D5, #0A
	DB #0A, #05, #0C, #0D, #05, #0A, #35, #05
	DB #05, #05, #05, #E5, #05, #05, #F5, #05
	DB #05, #F5, #05, #05, #E5, #05, #05, #05
	DB #05, #95, #0A, #05, #0C, #0D, #05, #0A
	DB #0A, #05, #08, #0F, #05, #08, #08, #08
	DB #08, #08, #0F, #05, #0C, #0D, #05, #08
	DB #0F, #05, #0C, #0D, #05, #08, #08, #08
	DB #08, #08, #0F, #05, #08, #0F, #05, #0A
	DB #0A, #35, #05, #05, #B5, #05, #05, #05
	DB #05, #05, #05, #95, #0A, #0A, #35, #05
	DB #05, #95, #0A, #0A, #35, #05, #05, #05
	DB #05, #05, #05, #B5, #05, #05, #95, #0A
	DB #08, #08, #08, #08, #08, #08, #08, #08
	DB #08, #08, #08, #08, #0F, #08, #08, #08
	DB #08, #08, #0F, #08, #08, #08, #08, #08
	DB #08, #08, #08, #08, #08, #08, #08, #0F

eyes_left:	; left eye
	DB #01, #E0, #02, #10, #04, #C8, #09, #E4
	DB #0B, #F4, #0B, #B4, #09, #E5, #04, #C9
	DB #02, #13, #01, #E7, #00, #07, #01, #83
	DB #03, #F0, #01, #FF, #00, #FF, #00, #3F

eyes_right:	; right eye
	DB #0F, #00, #10, #80, #26, #40, #4F, #20
	DB #5F, #A0, #5D, #A0, #4F, #20, #26, #40
	DB #90, #80, #CF, #00, #C0, #00, #83, #00
	DB #1F, #80, #FF, #00, #FE, #00, #F8, #00

eye_blink:	; right eye closed
	DB #0F, #00, #1F, #80, #3F, #C0, #7F, #E0
	DB #7F, #E0, #5F, #E0, #47, #E0, #20, #C0
	DB #90, #80, #CF, #00, #C0, #80, #83, #C0
	DB #1F, #80, #FF, #00, #FE, #00, #F8, #00

speed: 
    DB ANIM_DELAY
	
speed_prompt:
	ASCII "speed: "
	
free_space:
	DB 0, 0,0
	
