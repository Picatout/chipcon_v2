;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  sokoban_v2.asm
;  Jacques Deschênes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
EQU GRIDMAX 2

DEFN GRIDNO VA

	JP start
	
credits:
    ASCII "sokoban 2\nby Jacques Deschenes\n(c) 2015"	

start:
   CALL display_credits
   LD GRIDNO, 0
   call grid_info
   CALL grid_select
   CALL GAME_PLAY
   JP .-2
   
display_credits:
    LD I, credits
	LD V3, 0
	SCRY V4
	SHR V4
	PRT V3,V4
    LD V2, V4
	ADD V2, 3*8
	LD V0, 2
	CALL delay
	LD V0, FIRE_BTN
	SKNP V0
	JP .+5
    SCU 1
    ADD V2, 255
    SE V2, 0
    JP .-8
    CLS	
	RET
	
grid_select:
	LD V0, LEFT
	SKNP V0
	JP dec_gridno
	LD V0, RIGHT
	SKNP V0
	JP inc_gridno
	LD V0, FIRE_BTN
	SKNP V0
    RET
	JP grid_select
grid_b1:
    LD V0, 2
	LD ST, V0
    CALL grid_info
	LD V0, 15
	CALL delay
	JP grid_select
dec_gridno:
    SNE GRIDNO, 0
	JP grid_select
	CALL grid_info
	ADD GRIDNO, -1
	JP grid_b1
inc_gridno:
    SNE GRIDNO, GRIDMAX
	JP grid_select
	CALL grid_info
	add GRIDNO, 1
	JP grid_b1
	
grid_info:
	LD V3, 0
	SCRY V4
	ADD V4, 251
	LD I, G
	DRW V3, V4, 5
	ADD V3, 7
	LD I, BCD
	LD V0, GRIDNO
	ADD V0, 1
	LD B, V0
	LD V2, [I]
	LD F, V1
	DRW V3, V4, 5
	ADD V3, 4
	LD F, V2
	DRW V3, V4, 5
    RET	
	
draw_grid:

	RET
	
game_play:
	CALL draw_grid
    RET

	
delay:
    LD DT, V0
    LD V0, DT
    SE V0, 0
    JP .-2
    RET

	
BCD: DB 0,0,0	

G:  DB #F0, #80, #B0, #90, #70

grid1:
	DB #6E, #00, #88, #C2, #90, #18, #53, #41
	DB #84, #2A, #15, #60, #E8, #52, #8C, #15
	DB #51, #14, #40, #89, #80, #8A, #44, #43
	DB #65, #28, #58, #36, #D1, #21, #51, #91
	DB #43, #64, #01, #80, #C5, #40, #22, #60
grid2:
	DB #59, #8C, #03, #B0, #30, #15, #5D, #81
	DB #28, #50, #5D, #81, #AA, #A0, #BB, #00
	DB #48, #28, #2E, #C0, #88, #52, #28, #2D
	DB #28, #82, #50, #A5, #28, #82, #00, #C0
	DB #50, #8C, #00 
grid3:
 	DB #5C, #82, #45, #20, #AC, #06, #46, #0A 
	DB #95, #A2, #C1, #52, #85, #60, #CB, #4A  
	DB #21, #15, #28, #8A, #B3, #00, #29, #42  
	DB #82, #BB, #60, #0A, #14, #05, #98, #02  
	DB #3C  
