	CLS
	LD I, data_FFFFFE25
	LD V0, 0
	LD V1, 0
	PRT V0,V1
	LD V3, 60
	LD V0, 0
	LD DT, V3
	ADD V0, 1
	LD V3, DT
	SE V3, 0
	JP code_FFFFFE08	;#016
	LD V4, 0
	LD V5, 8
	CALL code_FFFFFE18	;#01C
	LD V2, 60
	LD DT, V2
	LD V2, DT
	SE V2, 0
	JP code_FFFFFE11	;#026
	LD V0, 32
	SKP V0
	JP code_FFFFFE00	;#02C
	EXIT
	DB #A0, #2B, #F0, #33, #63, #00, #A0, #2B
	DB #F3, #1E, #F0, #65, #F0, #29, #D4, #55
	DB #74, #04, #73, #01, #33, #03, #10, #1B
	DB #00, #EE, #73, #70, #65, #65, #64, #20
	DB #74, #65, #73, #74, #00, #00, #00, #00
	DB #00, #00
