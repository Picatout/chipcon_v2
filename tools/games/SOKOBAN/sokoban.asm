;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  sokoban_v2.asm
;  Jacques Deschenes
;  2015-08-25
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

sokoban:
 	DB  #60, #F0, #F0, #60
box:
    DB  #F0, #90, #90, #F0
target:
 	DB  #00, #40, #80, #00
brick:
    DB  #F0, #F0, #F0, #F0
grid1:
	DB 19,11, 11, 8  ; largeur, hauteur, sokoban x, y
	DB 5,2,5,4,7,3,7,4,2,7,5,7,0  ; position des boites
	DB 16,6,17,6,16,7,17,7,16,8,17,8,0 ; position des cibles
	DB 4,0,8,0, ; labyrinthe
undo:
	