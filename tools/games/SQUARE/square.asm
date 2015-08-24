;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Magic square, David Winter, 1997
;  adapted to CHIPcon v2 by jacques Deschenes, 2015
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	JP start
credits:	
	ASCII "Magic Square v1.0 by David WINTER"
	ASCII "Adapted to CHIPcon v2.0 by Jacques Deschenes, 2015"
start:
;	LOW
	CLS
	LD I, data_27D
	LD V0, 0
	LD V1, 0
	LD V2, 1
	LD V7, 0
	LD V8, 0
code_033:
	LD [I], V0
	ADD I, V2
	ADD V1, 1
	SE V1, 64
	JP code_033
	LD I, data_1FF
	LD V1, 6
	LD V0, 1
	LD V2, 11
	LD V3, 7
code_047:
	DRW V1, V0, 11
	ADD I, V2
	ADD V0, 13
	DRW V1, V0, 7
	ADD I, V3
	ADD V0, 243
	ADD V1, 8
	SE V1, 62
	JP code_047
	LD V0, 13
	LD V1, 26
	LD V2, 5
	LD VE, 3
	LD I, data_1D0
code_063:
	DRW V0, V1, 5
	ADD I, V2
	ADD V0, 6
	SE V0, 49
	JP code_063
	CALL code_15F
; lecture joystick	
code_06F:
	LD V2, 15
	LD DT, V2
	LD V2, DT
	SE V2, 0
	JP .-2
	LD V2, K
	SE V2, LEFT
	JP code_07F
	SNE VE, 3
	JP code_08D
	CALL code_15F
	ADD VE, 255
	CALL code_15F
code_07F:
	SE V2, RIGHT
	JP code_08D
	SNE VE, 8
	JP code_08D
	CALL code_15F
	ADD VE, 1
	CALL code_15F
code_08D:
	SE V2, FIRE_BTN
	JP code_06F
;	HIGH
	CLS
	LD V1, 0
code_097:
	ADD V8, VE
	ADD V1, 1
	SE V1, VE
	JP code_097
	LD VA, VE
	ADD VA, VA
	ADD VA, VA
	ADD VA, VA
	LD V0, 128
	SUBN VA, V0
	SHR VA
	LD VB, VE
	ADD VB, VB
	ADD VB, VB
	ADD VB, VB
	LD V0, 64
	SUBN VB, V0
	SHR VB
	LD V0, VA
	LD V1, VB
	LD V2, 0
	LD V3, 0
	LD I, data_1F8
code_0C5:
	DRW V0, V1, 7
	ADD V0, 8
	ADD V2, 1
	SE V2, VE
	JP code_0C5
	LD V0, VA
	ADD V1, 8
	LD V2, 0
	ADD V3, 1
	SE V3, VE
	JP code_0C5
	LD VC, 0
	LD VD, 0
	CALL code_165
; lecture joystick	
code_0E1:
	LD V0, 15
	LD DT, V0
	LD V0, DT
	SE V0, 0
	JP .-2
	LD V0, K
	SE V0, UP
	JP code_0EF
	CALL code_165
	SE VD, 0
	ADD VD, 255
	CALL code_165
code_0EF:
	SE V0, LEFT
	JP code_0FB
	CALL code_165
	SE VC, 0
	ADD VC, 255
	CALL code_165
code_0FB:
	SE V0, RIGHT
	JP code_109
	CALL code_165
	ADD VC, 1
	SNE  VC, VE
	ADD VC, 255
	CALL code_165
code_109:
	SE V0, DOWN
	JP code_117
	CALL code_165
	ADD VD, 1
	SNE  VD, VE
	ADD VD, 255
	CALL code_165
code_117:
	SE V0, FIRE_BTN
	JP code_0E1
	CALL light_toggle
	CALL code_17F
	SNE VD, 0
	JP code_129
	ADD VD, 255
	CALL code_17F
	ADD VD, 1
code_129:
	SNE VC, 0
	JP code_133
	ADD VC, 255
	CALL code_17F
	ADD VC, 1
code_133:
	LD V0, VC
	ADD V0, 1
	SNE  V0, VE
	JP code_141
	ADD VC, 1
	CALL code_17F
	ADD VC, 255
code_141:
	LD V0, VD
	ADD V0, 1
	SNE  V0, VE
	JP code_14F
	ADD VD, 1
	CALL code_17F
	ADD VD, 255
code_14F:
	LD V0, 15
	LD DT, V0
	LD V0, DT
	SE V0, 0
	JP .-2
	CALL light_toggle
	SE V7, V8
	JP code_0E1
	CALL code_165
	LD V0, 32
	LD V1, 0
code_15B:
	LD V0, 15
	LD DT, V0
	LD V0, DT
	SE V0, 0
	JP .-2
	CALL light_toggle
	LD V0, FIRE_BTN
	SKP V0
	JP code_15B
	LD V1, 4
	LD ST, V1
	SKNP V0
	JP .-3
	JP start
code_15F:
	LD F, VE
	DRW V0, V1, 5
	RET
code_165:
	LD I, data_1F2
code_167:
	LD V2, VC
	LD V3, VD
	ADD V2, V2 ; v2^4
	ADD V2, V2
	ADD V2, V2
	ADD V2, VA
	ADD V3, V3 ;v3^4
	ADD V3, V3
	ADD V3, V3
	ADD V3, VB
	DRW V2, V3, 6
	RET
code_17F:
	LD V1, VC
	LD V2, VD
	ADD V2, V2
	ADD V2, V2
	ADD V2, V2
	ADD V1, V2
	LD I, data_27D
	ADD I, V1
	LD V0, [I]
	LD V9, 1
	XOR V0, V9
	SE V0, 1
	ADD V7, 255
	SE V0, 0
	ADD V7, 1
	LD [I], V0
	LD I, data_1ED
	JP code_167
;;;;;;;;;;;;;;;;;;;;;;;;;
;  display light bulbs
;;;;;;;;;;;;;;;;;;;;;;;;;
light_toggle:
	LD V3, 24
	LD I, data_1B1
	LD V1, 8
	DRW V1, V3, 0
	LD V1, 103
	DRW V1, V3, 0
	RET

data_1B1:
	DB #04, #20, #02, #40, #82, #41, #40, #02
	DB #23, #C4, #04, #20, #08, #10, #10, #08
	DB #D2, #4B, #12, #48, #09, #90, #05, #A0
	DB #03, #C0, #03, #C0, #03, #C0, #01

data_1D0:
	DB #80, #80, #80, #80, #F8, #F8, #80, #E0
	DB #80, #F8, #88, #88, #88, #50, #20, #F8
	DB #80, #E0, #80, #F8, #80, #80, #80, #80
	DB #F8, #00, #20, #00, #20

data_1ED:
	DB #00, #00, #38, #38, #38

data_1F2:
	DB #00, #7C, #44, #44, #44, #7C

data_1F8:
	DB #FE, #82, #82, #82, #82, #82, #FE

data_1FF:
	DB #C1, #E3, #F7, #DD, #C9, #C1, #C1, #C1
	DB #C1, #C1, #C1, #FE, #00, #C0, #FE, #02
	DB #02, #FE, #8F, #9F, #B8, #B0, #B0, #BF
	DB #BF, #B0, #B0, #B0, #B0, #7F, #01, #61
	DB #61, #65, #62, #7D, #83, #C7, #EE, #6C
	DB #6C, #EC, #EC, #6C, #6E, #67, #63, #30
	DB #00, #30, #30, #30, #30, #3F, #F3, #FB
	DB #03, #03, #03, #73, #FB, #1B, #3B, #F3
	DB #E3, #9F, #80, #98, #9F, #98, #98, #98
	DB #1F, #3F, #70, #60, #60, #60, #60, #60
	DB #70, #3F, #1F, #CF, #40, #4C, #CF, #4C
	DB #4C, #4C, #80, #C0, #00, #00, #00, #00
	DB #00, #00, #00, #FF, #FF, #E7, #20, #26
	DB #E7, #86, #46, #27, #00, #00, #00, #00
	DB #00, #00, #00, #00, #00, #F0, #E0, #F0
	DB #00, #00, #80, #00, #00, #F0
data_27D:
	DB #00
