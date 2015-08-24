;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; FIELD!  Al Roland  1993
; Adapté pour CHIPcon v2 par Jacques Deschenes  
;  évitez les collisions avec les
;  astéroöids
;  =====================
;  Note: chaque click du bouton augmente la vitesse.
;  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
    JP start
credits:
	ASCII " FIELD! Al Roland 1993"
	ASCII " adapted for CHIPcon v2"
	ASCII " by Jacques Deschenes, 2015"
start:
	LD V1, 42
	LD V2, 1
	LD I, data_2BC
	DRW V1, V2, 0
	LD V1, 58
	LD I, data_2DC
	DRW V1, V2, 0
	LD V1, 74
	LD I, data_2FC
	DRW V1, V2, 0
	LD V1, 64
	LD V2, 48
	LD I, data_27C
	DRW V1, V2, 0
	LD V1, 48
	LD I, data_25C
	DRW V1, V2, 0
	LD V2, 32
	LD V3, 48
	LD V4, 32
	LD VE, 1
	LD VD, 3
	LD I, data_19C
	DRW V1, V2, 0
	LD I, data_1BC
	LD V1, 64
	DRW V1, V2, 0
	LD V5, 255
code_03A:
	LD W, 16
	CALL delay
	LD V1, 48
	LD I, data_19C ;enlève hibou de face
	DRW V1, V2, 0
	LD I, data_1DC ;affiche hibou profil
	DRW V1, V2, 0
	LD V5, 240
    LD W, 16
	CALL delay
	DRW V1, V2, 0  ; enlève hibou profil
	LD I, data_1FC
	DRW V1, V2, 0  ; hibou envol
	SUB V3, VD
	SUB V4, VD
	LD I, data_23C
	DRW V3, V4, 0
	LD W, 16
	CALL delay
	DRW V3, V4, 0
code_072: ; boucle d'animation vol oiseau
	SUB V3, VD
	SUB V4, VD
	LD V5, #3F
	AND V4, V5
	SHL V5
	AND V3, V5
	LD I, data_21C
	DRW V3, V4, 0
	LD W, 16
	CALL delay
	DRW V3, V4, 0
	SUB V3, VD
	SUB V4, VD
	LD V5, #3F
	AND V4, V5
	SHL V5
	AND V3, V5
	LD I, data_23C
	DRW V3, V4, 0
	LD W, 16
	CALL delay
	DRW V3, V4, 0
	LD V2, FIRE_BTN
	SKP V2
	JP code_072
;initialisation variables
	CLS  
	LD V3, 16 ; vitesse la plus lente
	LD V1, 1
	LD V2, 7
	LD V9, 32 ; position x du vaisseau
	LD VA, 15 ; position y du vaisseau
	LD V5, 1
	LD VB, 122
	LD VC, 1  ; direction du déplacement 1=vers la gauche, 2 vers la droite
	LD VE, 1
	LD VD, 0
	LD V7, 0
	LD I, data_198
; boucle jeux
code_0B4:
	ADD V7, 1
	SNE V7, 192
	JP code_120
; lecture joystick	
code_0BA:
	LD V2, FIRE_BTN
	SKNP V2
	JP code_110
	LD V2, RIGHT
	SKNP V2
	JP code_174
	LD V2, LEFT
	SKNP V2
	JP code_182
	LD V2, UP
	SKNP V2
	JP code_126
	LD V2, DOWN
	SKNP V2
	JP code_12C
code_0EA:  
	SNE VC, 1
	JP code_174
	SNE VC, 2
	JP code_182
code_0F2:
	LD W, V3
	call delay
	LD I, data_190 ; dessine un nouvel obstacle
	RND V1, #3F  ;  #3A
	LD VE, 64
	SUB VE, V1
	DRW V5, VE, 4
	DRW VB, VE, 4
	SNE VC, 1
	JP code_132
	SNE VC, 2
	JP code_138
	JP code_0B4
; augmente la vitesse
code_110:
	SNE  V3, 2 ; vitesse maximale
	JP code_0EA
	ADD V3, -1
wait_release:
	LD W, 1
	CALL delay
	LD W, FIRE_BTN
	SKNP W
	JP wait_release
	JP code_0EA
code_120:
	ADD VD, 1
	LD V7, 0
	JP code_0BA
code_126:
	SNE VA, 0
	JP code_0EA
	LD VE, 1
	SUB VA, VE
	JP code_0EA
code_12C:
	SNE VA, 61
	JP code_0EA
	ADD VA, 1
	JP code_0EA
code_132:
	LD I, data_194
	DRW V9, VA, 3
	JP code_0B4
code_138:
	LD I, data_198
	DRW V9, VA, 3
	JP code_0B4
code_13E: ; fin de la partie, collision anim. explosion
	LD V5, 8
	SUB V9, V5
	SUB VA, V5
	LD I, data_31C
	DRW V9, VA, 0
	LD W, 16
	CALL delay
	LD I, data_33C
	DRW V9, VA, 0
	LD W, 16
	CALL delay
	CLS
	LD V1, 44
	LD V2, 16
	LD I, data_29C
	DRW V1, V2, 0
	LD V1, 50
	LD V2, 37
	LD F, VD
	DRW V1, V2, 5
	JP start
code_174:
	SCL
	LD I, data_194
	DRW V9, VA, 3
	SNE VF, 1
	JP code_13E
	LD VC, 1   
	JP code_0F2
code_182:
	SCR
	LD I, data_198
	DRW V9, VA, 3
	SNE VF, 1
	JP code_13E
	LD VC, 2
	JP code_0F2
;;;;;;;;;;;;;;;;
; input: W=delay
; time=delay*16,67msec
delay:
    LD DT, W
	LD W, DT
	SE W, 0
	JP .-2
	RET
	
data_190: ; sprite 1
	DB #6E, #FF, #7E, #33

data_194: ; sprite 2
	DB #E0, #7F, #E0, #00

data_198: ; sprite 3
	DB #07, #FE, #07, #99

data_19C: ; hibou de face
	DB #00, #00, #20, #83, #31, #86, #7F, #C7
	DB #4A, #46, #7B, #C6, #3F, #80, #5F, #43
	DB #FF, #E4, #DF, #63, #FF, #E0, #DB, #60
	DB #AA, #A3, #6A, #C0, #EA, #FF, #D5, #7F

data_1BC: ; Al/soft
	DB #00, #00, #C6, #00, #66, #00, #E6, #00
	DB #66, #00, #67, #C0, #00, #00, #C0, #60
	DB #00, #84, #8C, #8E, #52, #C4, #52, #84
	DB #8C, #83, #00, #00, #FF, #FF, #FF, #FF

data_1DC: ; hibou profile
	DB #04, #00, #1E, #03, #37, #86, #7F, #87
	DB #0F, #C6, #07, #76, #0F, #F8, #0F, #DB
	DB #07, #FC, #03, #EF, #01, #DF, #00, #9F
	DB #00, #0F, #01, #07, #FF, #FF, #FF, #7F

data_1FC:
	DB #00, #00, #00, #03, #00, #06, #00, #07
	DB #00, #06, #00, #06, #00, #00, #00, #03
	DB #00, #04, #00, #03, #00, #00, #00, #00
	DB #00, #03, #00, #00, #FF, #FF, #FF, #7F

data_21C: ; hibou ailes fermées
	DB #04, #00, #1E, #00, #37, #80, #7F, #80
	DB #0F, #C0, #07, #70, #0F, #F8, #0F, #D8
	DB #07, #F8, #03, #EE, #01, #DF, #00, #9F
	DB #00, #4F, #00, #67, #00, #03, #00, #00

data_23C: ; hibou ailes ouvertes
	DB #10, #00, #3C, #0E, #5E, #BF, #FF, #FF
	DB #3F, #FF, #0F, #F7, #07, #FB, #07, #F9
	DB #03, #F8, #01, #FC, #00, #DE, #00, #9E
	DB #00, #5F, #00, #0F, #00, #0F, #00, #00

data_25C: ; Al Rol/Hit .
	DB #24, #30, #54, #28, #54, #30, #74, #29
	DB #54, #2A, #54, #29, #00, #00, #50, #00
	DB #54, #80, #71, #E0, #54, #80, #54, #83
	DB #54, #43, #00, #00, #00, #00, #00, #00

data_27C: ; .land/togo
	DB #20, #02, #20, #02, #20, #02, #26, #C6
	DB #AA, #AA, #26, #A6, #00, #00, #70, #60
	DB #20, #A0, #24, #84, #2A, #AA, #2A, #AA
	DB #24, #64, #00, #00, #00, #00, #00, #00

data_29C:
	DB #14, #00, #14, #00, #08, #94, #09, #54
	DB #08, #88, #00, #00, #C4, #EE, #AA, #48
	DB #CE, #4E, #AA, #48, #AA, #48, #AA, #4E
	DB #00, #00, #07, #E0, #03, #C0, #01, #80

data_2BC: ; FI
	DB #00, #00, #FF, #7E, #FF, #7E, #E0, #18
	DB #E0, #18, #E0, #18, #FC, #18, #FC, #18
	DB #E0, #18, #E0, #18, #E0, #18, #E0, #18
	DB #E0, #7E, #E0, #7E, #00, #00, #00, #00

data_2DC: ;EL
	DB #00, #00, #FF, #70, #FF, #70, #E0, #70
	DB #E0, #70, #E0, #70, #FC, #70, #FC, #70
	DB #E0, #70, #E0, #70, #E0, #70, #E0, #70
	DB #FF, #7E, #FF, #7E, #00, #00, #00, #00

data_2FC: ; D!
	DB #00, #00, #F8, #08, #FE, #1C, #E7, #3E
	DB #E7, #3E, #E7, #3E, #E7, #3E, #E7, #1C
	DB #E7, #1C, #E7, #1C, #E7, #08, #E7, #00
	DB #FE, #1C, #F8, #1C, #00, #00, #00, #00

data_31C:
	DB #00, #02, #10, #0C, #08, #14, #0E, #C0
	DB #05, #A0, #06, #1C, #1A, #24, #7A, #90
	DB #C1, #E8, #02, #18, #05, #08, #0C, #10
	DB #10, #00, #00, #00, #00, #00, #00, #00

data_33C:
	DB #C3, #02, #31, #8C, #09, #54, #0E, #C4
	DB #75, #B9, #1E, #1C, #1A, #3E, #7A, #93
	DB #E1, #E9, #22, #19, #05, #08, #4C, #14
	DB #30, #0A, #1B, #32, #14, #32, #20, #01

