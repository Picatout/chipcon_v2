;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; H. Piper!
; 2.0 Paul Raines, 1991
; original for SUPER-CHIP
; adapted to CHIPcon v2 by
; Jacques Deschenes, 2015
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	JP start
credits:
	ASCII "v2.0 Raines (c) 1991"
	ASCII "adapted to CHIPcon v2 by"
	ASCII "Jacques Deschenes, 2015"
start:
;	HIGH
	LD V3, R
	LD VE, V2
	SNE V3, 1
	JP code_026
	LD VE, 78
	LD V0, 0
	LD V1, 0
code_026:
	LD I, data_66E
	LD [I], V1
	LD VC, 255
	LD V0, 0
	LD V1, 0
	LD V2, 0
	LD R, V2
code_034:
	CLS
	LD V0, 11
	LD V1, 0
	LD V2, 0
code_03C:
	LD I, data_6AC
	ADD I, V2
	LD [I], V1
	ADD V2, 2
	SE V2, 120
	JP code_03C
	LD V0, 0
	LD V2, 0
code_04C:
	LD I, data_664
	ADD I, V2
	LD [I], V1
	ADD V2, 2
	SE V2, 6
	JP code_04C
	LD I, data_672
	LD V0, 38
	LD V1, 57
	LD V3, 0
code_060:
	ADD I, V3
	DRW V0, V1, 5
	LD V3, 5
	ADD V0, 8
	SE V0, 70
	JP code_060
	LD I, data_686
	LD V0, 104
	LD V1, 2
	DRW V0, V1, 5
	ADD V0, 8
	LD V2, 5
	ADD I, V2
	DRW V0, V1, 5
	LD I, data_690
	LD V0, 104
	LD V1, 42
	DRW V0, V1, 5
	ADD V0, 8
	LD V2, 5
	ADD I, V2
	DRW V0, V1, 5
	LD V1, VE
	SHR V1
	LD V0, 100
	SUB V0, V1
	LD I, data_61E
	LD B, V0
	LD V2, [I]
	LD V3, 90
	LD V4, 57
	LD F, V1
	DRW V3, V4, 5
	ADD V3, 5
	LD F, V2
	DRW V3, V4, 5
	LD V0, VE
	LD I, data_5BC
	LD [I], V0
	LD I, data_5CE
	LD V0, 0
	LD V1, 0
code_0B4:
	DRW V0, V1, 2
	ADD V0, 8
	SE V0, 96
	JP code_0B4
	LD V4, 2
code_0BE:
	LD I, data_5A4
	LD V0, 0
	DRW V0, V4, 12
	LD I, data_5B0
	LD V0, 8
	DRW V0, V4, 12
	ADD V4, 12
	SE V4, 62
	JP code_0BE
	LD V7, 0
;;;;;;;;;;;;;;;;;;;;;;;;;;
;  dessine les 5 pipes preview
;;;;;;;;;;;;;;;;;;;;;;;;;;
code_0D2:
	LD V0, V7
	CALL code_520
	ADD V7, 1
	SE V7, 5
	JP code_0D2
	LD V1, 50
	LD V0, 16
	LD I, data_5DE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; dessine bas du périmètre
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
code_0E2:
	DRW V0, V1, 6
	ADD V0, 8
	SE V0, 96
	JP code_0E2
	LD V1, 0
	LD V0, 96
	LD I, data_5A2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; desssine droite du périmètre
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
code_0F0:
	DRW V0, V1, 2
	ADD V1, 2
	SE V1, 56
	JP code_0F0
	LD VD, 52
	CALL code_212
	CALL code_21E
	CALL code_22C
	LD V1, 2
	LD I, data_616
code_104:
	LD V0, 16
;;;;;;;;;;;;;;;;;;;;;;
; dessine grille
;;;;;;;;;;;;;;;;;;;;;;
code_106:
	DRW V0, V1, 8
	ADD V0, 8
	SE V0, 96
	JP code_106
	ADD V1, 8
	SE V1, 50
	JP code_104
	SNE VC, 255
	JP code_12A
	SNE VB, 0
	LD V3, 6
	SNE VB, 3
	LD V3, 4
	SNE VB, 6
	LD V3, 2
	SNE VB, 5
	LD V3, 0
	JP code_138
code_12A:
	RND V3, #07
	ADD V3, 1
	RND VC, #30
	ADD VC, 16
	ADD VC, V3
	RND V3, #03
	SHL V3
code_138:
	LD I, data_65C
	ADD I, V3
	LD V1, [I]
	LD VB, V0
	LD V2, V1
	LD V9, V2
	LD V0, VC
	CALL code_472
	CALL code_4CC
	LD VA, 2
	CALL code_23E
	LD V7, 0
	LD V8, 0
	CALL code_55E
	CALL code_580
	LD V0, 255
	LD DT, V0
;;;;;;;;;;;;;;;;;;;;;;
; lecture du joystick
;;;;;;;;;;;;;;;;;;;;;; 
code_15A:
	LD V0, LEFT
	SKNP V0
	CALL code_1AA
	LD V0, RIGHT
	SKNP V0
	CALL code_1C4
	LD V0, UP
	SKNP V0
	CALL code_1DE
	LD V0, DOWN
	SKNP V0
	CALL code_1F8
	LD V0, FIRE_BTN
	SKNP V0
	CALL code_18C
	LD V0, FIRE_BTN+LEFT
	SKNP V0
	CALL code_196
	LD V0, FIRE_BTN+DOWN
	SKNP V0
	LD VE, 2
	LD V0, DT
	SNE V0, 0
	CALL code_24E
	JP code_15A
code_18C:
	LD V0, 15
	CALL code_520
	LD V0, VD
	CALL code_472
	RET
code_196:
	CALL code_51C
	LD V0, VD
	CALL code_472
	RET
code_19E:
	LD V0, VD
	LD V1, 15
	AND V0, V1
	LD V1, VD
	SUB V1, V0
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;;;;;;;;;;;;;;;;;;;;;;;;	
code_1AA:
	CALL code_212
	CALL code_22C
	CALL code_19E
	ADD V0, 255
	SNE V0, 255
	LD V0, 0
	LD VD, V1
	ADD VD, V0
	CALL code_212
	CALL code_22C
	LD V0, 144
	CALL code_236
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;;;;;;;;;;;;;;;;;;;;;;;;	
code_1C4:
	CALL code_212
	CALL code_22C
	CALL code_19E
	ADD V0, 1
	SNE V0, 10
	LD V0, 9
	LD VD, V1
	ADD VD, V0
	CALL code_212
	CALL code_22C
	LD V0, 144
	CALL code_236
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;;;;;;;;;;;;;;;;;;;;;;;;	
code_1DE:
	CALL code_21E
	CALL code_22C
	CALL code_19E
	ADD V1, 240
	SNE V1, 240
	LD V1, 0
	LD VD, V1
	ADD VD, V0
	CALL code_21E
	CALL code_22C
	LD V0, 144
	CALL code_236
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;;;;;;;;;;;;;;;;;;;;;;;;	
code_1F8:
	CALL code_21E
	CALL code_22C
	CALL code_19E
	ADD V1, 16
	SNE V1, 96
	LD V1, 80
	LD VD, V1
	ADD VD, V0
	CALL code_21E
	CALL code_22C
	LD V0, 144
	CALL code_236
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;;;;;;;;;;;;;;;;;;;;;;;;	
code_212:
	CALL code_19E
	ADD V0, 96
	CALL code_42A
	LD I, data_646
	DRW V0, V1, 4
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;;;;;;;;;;;;;;;;;;;;;;;;	
code_21E:
	CALL code_19E
	LD V0, V1
	ADD V0, 10
	CALL code_42A
	LD I, data_63E
	DRW V0, V1, 8
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;;;;;;;;;;;;;;;;;;;;;;;;	
code_22C:
	LD V0, VD
	CALL code_42A
	LD I, data_636
	DRW V0, V1, 8
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;;;;;;;;;;;;;;;;;;;;;;;;	
code_236:
	ADD V0, 255
	SE V0, 0
	JP code_236
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;
; dessine bout de tuyau
; à droite de l'écran
;;;;;;;;;;;;;;;;;;;;;;;;;	
code_23E:
	LD I, data_654
	ADD I, VA
	LD V0, [I]
	CALL code_4BC
	LD V0, 108
	LD V1, 28
	DRW V0, V1, 8
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
code_24E:
	CALL code_23E
	ADD VA, 1
	LD V0, V9
	LD V1, 240
	AND V0, V1
	SNE V0, 0
	JP code_264
	SNE VA, 4
	JP code_292
	SNE VA, 5
	JP code_322
code_264:
	LD V2, VA
	SE VB, 0
	JP code_26E
	LD V2, 8
	SUB V2, VA
code_26E:
	LD V0, VB
	SHR V0
	SHR V0
	SE V0, 0
	JP code_2C0
	SE VB, 0
	ADD V2, 255
	LD V0, VC
	CALL code_42A
	ADD V1, V2
	LD I, data_64A
	DRW V0, V1, 1
	SNE VF, 0
	JP code_304
	SE VA, 1
	JP code_304
	LD V9, 0
	JP code_33E
code_292:
	XOR VB, V9
	LD V0, 7
	AND VB, V0
	LD V0, VC
	CALL code_42A
	SE V9, 22
	JP code_2A4
	LD I, data_64C
	ADD V1, 4
code_2A4:
	SE V9, 29
	JP code_2AC
	LD I, data_64E
	ADD V1, 2
code_2AC:
	SE V9, 21
	JP code_2B4
	LD I, data_650
	ADD V1, 4
code_2B4:
	SE V9, 30
	JP code_2BC
	LD I, data_652
	ADD V1, 2
code_2BC:
	DRW V0, V1, 2
	JP code_322
code_2C0:
	SE VB, 5
	JP code_2D0
	LD V3, 128
code_2C6:
	SNE V2, 8
	JP code_2DC
	SHR V3
	ADD V2, 1
	JP code_2C6
code_2D0:
	LD V3, 1
code_2D2:
	SNE V2, 8
	JP code_2DC
	SHL V3
	ADD V2, 1
	JP code_2D2
code_2DC:
	LD V1, V3
	LD V0, V3
	LD I, data_61E
	LD [I], V1
	LD I, data_61E
	LD V0, VC
	CALL code_42A
	ADD V1, 3
	SE V9, 3
	JP code_2F6
	SNE VA, 4
	JP code_2F8
	SE VA, 5
code_2F6:
	DRW V0, V1, 2
code_2F8:
	SNE VF, 0
	JP code_304
	SE VA, 1
	JP code_304
	LD V9, 0
	JP code_33E
code_304:
	SE VA, 8
	JP code_322
	CALL code_55E
	LD V0, 0
code_30C:
	ADD V7, 1
	SE V7, 100
	JP code_316
	ADD V8, 1
	LD V7, 0
code_316:
	ADD V0, 1
	SE V0, 3
	JP code_30C
	CALL code_55E
	LD VA, 0
	CALL code_4E4
code_322:
	LD V0, VE
	LD V1, V8
	ADD V1, V7
	SNE V1, 0
	ADD V0, 176
	LD DT, V0
	CALL code_23E
code_332:
	LD V0, FIRE_BTN+LEFT
code_334:
	SKP V0
	JP code_334
code_338:
	SKNP V0
	JP code_338
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;;;;;;;;;;;;;;;;;;;;;;;;	
code_33E:
	LD V0, 3
	LD ST, V0
	CALL code_332
	CLS
	LD V2, 0
	LD V3, 0
code_34A:
	LD I, data_6AC
	ADD I, V2
	LD V1, [I]
	ADD V2, 2
	ADD V3, V1
	SE V2, 120
	JP code_34A
	SNE V3, 60
	ADD V8, 1
	LD I, data_66E
	LD V1, [I]
	ADD V0, V7
	LD V3, 100
	SUB V0, V3
	LD V4, VF
	SE V4, 0
	ADD V1, 1
	SE V4, 1
	ADD V0, 100
	ADD V1, V8
	LD I, data_66E
	LD [I], V1
	LD V5, V0
	LD V3, 40
	LD V4, 40
	LD I, data_66A
	LD B, V1
	LD V2, [I]
	LD LF, V0
	DRW V3, V4, 10
	ADD V3, 11
	LD LF, V1
	DRW V3, V4, 10
	ADD V3, 11
	LD LF, V2
	DRW V3, V4, 10
	LD I, data_66A
	LD B, V5
	LD V2, [I]
	ADD V3, 11
	LD LF, V1
	DRW V3, V4, 10
	ADD V3, 11
	LD LF, V2
	DRW V3, V4, 10
	CALL code_55E
	LD I, data_5BC
	LD V0, [I]
	LD VE, V0
	SNE VE, 2
	ADD VE, 4
	ADD VE, 252
	SE V8, 0
	JP code_3C2
	SHR V0
	LD V1, 100
	SUB V1, V0
	SUB V7, V1
	SNE VF, 0
	JP code_3CC
code_3C2:
	CALL code_3F6
	SE V0, 0
	JP code_034
	LD V3, 1
	JP code_3E0
code_3CC:
	LD I, data_69A
	LD V0, 42
	LD V1, 24
	DRW V0, V1, 5
	ADD V0, 8
	LD V2, 5
	ADD I, V2
	DRW V0, V1, 5
	CALL code_3F6
	LD V3, 0
code_3E0:
	LD I, data_66E
	LD V1, [I]
	LD V2, VE
	LD R, V3
	LD V0, FIRE_BTN+UP
code_3EA:
	SKNP V0
	JP code_3EA
	LD V0, FIRE_BTN+UP
code_3F0:
	SKNP V0
	JP code_3F0
	EXIT
;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;;;;;;;;;;;;;;;;;;;;;;;;	
code_3F6:
	LD I, data_5CE
	LD V3, 2
	LD V4, 8
	DRW V3, V4, 8
	LD I, data_5E6
	LD V3, 10
	DRW V3, V4, 8
	LD I, data_6A4
code_406:
	LD V3, 14
	LD V4, 16
	DRW V3, V4, 7
code_40C:
	LD V0, 37
	CALL code_236
	LD V0, LEFT+UP
	SKNP V0
	JP code_428
	LD V0, 0
	SKNP V0
	JP code_428
	DRW V3, V4, 7
	ADD V4, 2
	SNE V4, 56
	JP code_406
	DRW V3, V4, 7
	JP code_40C
code_428:
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;;;;;;;;;;;;;;;;;;;;;;;;	
code_42A:
	LD V1, V0
	LD VF, 240
	AND V1, VF
	SHR V1
	LD VF, 15
	AND V0, VF
	SHL V0
	SHL V0
	SHL V0
	ADD V0, 16
	ADD V1, 2
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;;;;;;;;;;;;;;;;;;;;;;;;	
	DB #70, #F0, #71, #FE, #80, #56, #80, #56
	DB #80, #56, #81, #5E, #80, #14, #00, #EE
;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;;;;;;;;;;;;;;;;;;;;;;;;	
code_452:
	LD I, data_6AC
	LD V1, V0
	LD VF, 15
	AND V1, VF
	SHL V1
	ADD I, V1
	LD VF, 240
	AND V0, VF
	SHR V0
	LD V1, V0
	SHR V1
	SHR V1
	ADD V0, V1
	SHL V0
	ADD I, V0
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;;;;;;;;;;;;;;;;;;;;;;;;	
code_472:
	LD V3, V0
	CALL code_452
	LD V1, [I]
	LD V5, 0
	SE V0, 11
	LD V5, 255
	SNE V1, 0
	JP code_488
	LD V1, 3
	LD ST, V1
	JP code_4A4
code_488:
	CALL code_4BC
	LD V0, V3
	CALL code_42A
	DRW V0, V1, 8
	LD V0, V3
	CALL code_452
	LD V1, 0
	LD V0, V2
	LD [I], V1
	LD V0, V2
	CALL code_4BC
	LD V0, V3
	CALL code_42A
	DRW V0, V1, 8
code_4A4:
	CALL code_55E
	ADD V7, V5
	SE V7, 255
	JP code_4B8
	SNE V8, 0
	JP code_4B6
	ADD V8, 255
	LD V7, 99
	JP code_4B8
code_4B6:
	LD V7, 0
code_4B8:
	CALL code_55E
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;
; I= data_5BE+(V0&15)<<3
;;;;;;;;;;;;;;;;;;;;;;;;;	
code_4BC:
	LD V1, 15
	AND V0, V1
	SHL V0
	SHL V0
	SHL V0
	LD I, data_5BE
	ADD I, V0
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;;;;;;;;;;;;;;;;;;;;;;;;	
code_4CC:
	LD V0, VC
	CALL code_452
	LD V1, [I]
	SNE V0, 11
	JP code_33E
	LD V9, V0
	LD V0, VC
	CALL code_452
	LD V0, V9
	LD V1, 1
	LD [I], V1
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;;;;;;;;;;;;;;;;;;;;;;;;	
code_4E4:
	LD V3, 0
	SNE VB, 6
	LD V3, 1
	SNE VB, 3
	LD V3, 16
	SNE VB, 0
	LD V3, 240
	SNE VB, 5
	LD V3, 255
	LD V1, VC
	ADD V1, V3
	LD VF, 240
	AND V1, VF
	SNE V1, 240
	JP code_33E
	SNE V1, 96
	JP code_33E
	LD V1, VC
	ADD V1, V3
	LD VF, 15
	AND V1, VF
	SNE V1, 15
	JP code_33E
	SNE V1, 10
	JP code_33E
	ADD VC, V3
	CALL code_4CC
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;;;;;;;;;;;;;;;;;;;;;;;;	
code_51C:
	LD V1, VA
	JP code_52A
code_520:
	RND V1, #07
	SHR V0
	SHR V0
	SNE V0, 0
	SHR V1
code_52A:
	LD I, data_654
	ADD I, V1
	LD V0, [I]
	LD V5, V0
	LD V4, 3
	LD V3, 0
code_536:
	LD I, data_664
	ADD I, V3
	LD V0, [I]
	LD V2, V0
	CALL code_4BC
	LD V0, 4
	DRW V0, V4, 8
	LD I, data_664
	ADD I, V3
	LD V0, V5
	LD [I], V0
	CALL code_4BC
	LD V0, 4
	DRW V0, V4, 8
	ADD V4, 12
	LD V5, V2
	ADD V3, 1
	SE V3, 5
	JP code_536
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;;;;;;;;;;;;;;;;;;;;;;;;	
code_55E:
	LD V3, 105
	LD V4, 9
	LD I, data_66A
	LD B, V8
	LD V2, [I]
	LD F, V2
	DRW V3, V4, 5
	ADD V3, 6
	LD I, data_66A
	LD B, V7
	LD V2, [I]
	LD F, V1
	DRW V3, V4, 5
	ADD V3, 6
	LD F, V2
	DRW V3, V4, 5
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;;;;;;;;;;;;;;;;;;;;;;;;	
code_580:
	LD V0, VE
	ADD V0, 254
	SHR V0
	SHR V0
	LD V1, 20
	SUB V1, V0
	LD I, data_66A
	LD B, V1
	LD V2, [I]
	LD LF, V1
	LD V3, 104
	LD V4, 50
	DRW V3, V4, 10
	ADD V3, 11
	LD LF, V2
	DRW V3, V4, 10
	RET

data_5A2:
	DB #F8, #F8

data_5A4:
	DB #C0, #C0, #C0, #C0, #C0, #C0, #C0, #C0
	DB #C0, #C0, #C0, #FF

data_5B0:
	DB #03, #03, #03, #03, #03, #03, #03, #03
	DB #03, #03, #03, #FF

data_5BC:
	DB #00, #00

data_5BE:
	DB #00, #00, #00, #00, #00, #00, #00, #00
	DB #C3, #C3, #C3, #C3, #C3, #C3, #C3, #C3

data_5CE:
	DB #FF, #FF, #00, #00, #00, #00, #FF, #FF
	DB #C3, #C3, #00, #00, #00, #00, #C3, #C3

data_5DE:
	DB #FF, #FF, #FF, #FF, #FF, #FF, #FF, #FF

data_5E6:
	DB #FF, #FF, #0F, #07, #03, #03, #83, #C3
	DB #FF, #FF, #F0, #E0, #C0, #C0, #C1, #C3
	DB #FF, #FF, #C0, #C0, #C0, #C0, #FF, #FF
	DB #FF, #FF, #03, #03, #03, #03, #FF, #FF
	DB #C3, #C3, #C3, #C3, #C3, #C3, #FF, #FF
	DB #FF, #FF, #C3, #C3, #C3, #C3, #C3, #C3

data_616:
	DB #00, #7E, #42, #42, #42, #42, #7E, #00

data_61E:
	DB #00, #00, #00, #00, #00, #00, #00, #00
	DB #C3, #C1, #C0, #C0, #E0, #F0, #FF, #FF
	DB #C3, #83, #03, #03, #07, #0F, #FF, #FF

data_636:
	DB #00, #00, #18, #3C, #3C, #18, #00, #00

data_63E:
	DB #00, #10, #10, #70, #70, #10, #10, #00

data_646:
	DB #00, #18, #18, #7E

data_64A:
	DB #18, #00

data_64C:
	DB #08, #04

data_64E:
	DB #04, #08

data_650:
	DB #10, #20

data_652:
	DB #20, #10

data_654:
	DB #1D, #15, #16, #1E, #01, #02, #03, #03

data_65C:
	DB #06, #07, #05, #08, #00, #09, #03, #0A

data_664:
	DB #00, #00, #00, #00, #00, #00

data_66A:
	DB #00, #00, #00, #00

data_66E:
	DB #00, #00, #00, #00

data_672:
	DB #A3, #A2, #E3, #A2, #AA, #BB, #92, #93
	DB #12, #3A, #BB, #A2, #B3, #22, #3A, #88
	DB #88, #88, #40, #48

data_686:
	DB #D9, #92, #D2, #52, #D9, #3B, #AA, #B3
	DB #AA, #2B

data_690:
	DB #9A, #92, #9A, #91, #D9, #B4, #A4, #B4
	DB #24, #36

data_69A:
	DB #EA, #AA, #AE, #A4, #E4, #EE, #8A, #CE
	DB #89, #E9

data_6A4:
	DB #20, #20, #70, #F8, #F8, #F8, #70, #00

data_6AC:
	DB #0B, #00, #0B, #00, #0B, #00, #0B, #00
	DB #0B, #00, #0B, #00, #0B, #00, #0B, #00
	DB #0B, #00, #0B, #00, #0B, #00, #0B, #00
	DB #0B, #00, #0B, #00, #0B, #00, #0B, #00
	DB #0B, #00, #0B, #00, #0B, #00, #0B, #00
	DB #0B, #00, #0B, #00, #0B, #00, #0B, #00
	DB #0B, #00, #0B, #00, #0B, #00, #0B, #00
	DB #0B, #00, #0B, #00, #0B, #00, #0B, #00
	DB #0B, #00, #0B, #00, #0B, #00, #0B, #00
	DB #0B, #00, #0B, #00, #0B, #00, #0B, #00
	DB #0B, #00, #0B, #00, #0B, #00, #0B, #00
	DB #0B, #00, #0B, #00, #0B, #00, #0B, #00
	DB #0B, #00, #0B, #00, #0B, #00, #0B, #00
	DB #0B, #00, #0B, #00, #0B, #00, #0B, #00
	DB #0B, #00, #0B, #00, #0B, #00, #0B, #00

