;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; OCTOPACMAN
; IL TOURNE SUR LUI-MÊME POUR
; AVALER LE PLUS DE BIJOUX POSSIBLE
; AFIN DE RALLONGER SA LIGNE DE VIE.
; PAR CONTRE SI UN BIJOU LE FRAPPE
; EN DEHORS DE LA BOUCHE LA LIGNE DE
; VIE RACCOURCI.
; inspiré de HEXAPACMAN
;     REF: http://www.jdroid.ch/index.php?inhalt_links=navigation.inc.php&inhalt_mitte=pixelgames/hexaPac.inc.php
;   * diamant      15 points
;   * Gros losange 10 points
;   * petit losange 5 points
;   * petit carré   1 point
;;;;;;;;;;;;;;;;;;;;;;;;;;
; constantes utiles
;;;;;;;;;;;;;;;;;;;;;;;;;;
EQU STRUC_SIZE   6 ; dimension de la structure bijou
EQU JEWEL_SIZE   8 ; nombre d'octets sprite bijou
; identifiant bijou
EQU BIG_DIAMOND 3 ; gros diamant
EQU DIAMOND     2 ; diamant
EQU RUBY        1 ; rubis
EQU PERL        0 ; perle
; valeur bijou
EQU BD_VAL		15 ; gros diamant
EQU D_VAL		10 ; petit diamant
EQU R_VAL		 5 ; rubis
EQU P_VAL		 1 ; perle
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; assignation de registres
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DEFN ANGLE  VE  ; angle d'hexa packman
DEFN LLEN  VD   ; pointage
DEFN COUNT  VC  ; nombre de bijou à l'écran
DEFN MAXJWL VB  ; nombre maximum de bijou
DEFN SPEED  VA  ; vitesse du jeux
DEFN CYCLEL V9  ; compte les boucle du jeux

	JP start
credits:
	ASCII "Octo pacman\nby Jacques Deschenes\nCopyright 2015" 
	DB 26
ORG #40
start:	
	CALL show_credits
play_again:
	CLS
	; initialize variables
	LD ANGLE, 0 ; orientation bouche pacman
	LD LLEN, 8 ; valeur initiale ligne de vie
    LD COUNT, 0 ; nombre de bijou à l'écran
	LD MAXJWL, 4 ; nombre maximum de bijoux
	LD SPEED, 5 ; vitesse du jeux 5 lent, 1 rapide
	LD CYCLEL, 0 
	CALL free_jtable
	CALL draw_octopacman
	CALL update_line
;;;;;;;;;;;;;;;;;;;;	
; boucle du jeux
;;;;;;;;;;;;;;;;;;;;	
game_loop:
    ADD CYCLEL, 1
	SE VF, 0
	CALL inc_cycleh
	PUSH ANGLE
	CALL read_joystick
	POP V0
	SNE V0, ANGLE
	JP game_lp1f
	CALL draw_octopacman ; efface pacman
	LD V0, ANGLE
	CALL draw_octopacman ; remet pacman
game_lp1f:
	CALL move_jewel
	SNE LLEN, 0
    JP game_over
	SNE COUNT, MAXJWL
	JP speed_delay
	LD V0, 3
	AND V0, CYCLEL
	SNE V0, 0
	CALL new_jewel
speed_delay:	
	LD V0, SPEED
	CALL delay
	JP game_loop
game_over:	; jeu terminé
	SCD 8
	SCU 8
	LD V0, 0
	SCRY V1
	ADD V1, -8
	LD I, MSG_OVER
	PRT V0, V1
	LD V3, 95
	LD V4, 65
	CALL display_time
	CALL wait_button
	JP play_again

;;;;;;;;;;;;;;;;;;;;;
; mise à jour de la barre
; de vie
;;;;;;;;;;;;;;;;;;;;;
update_line:
    SCD 8
	SCU 8
    SNE LLEN, 0
	RET
    LD R, V4
	LD V0, LLEN
	SHR V0
	LD V2, 0
	SCRY V3
	ADD V3,-6
	LD I, LINE
	LD V4,V0
	SHR V4
	SHR V4
	SHR V4
	SHR V4
	PUSH V4
	ADD I, V4
	ADD I, V4
	ADD V4, 1
	DRW V2, V3, 2
	ADD V2,V4
	SUB V0, V4
	SE VF, 0
	JP .-4
	POP V4
	LD V0, 7
	SUB V0, V4
	LD SPEED, V0
    LD V4, R
    RET
	
;;;;;;;;;;;;;;;;;
; lecture du joystick
; et modification de 
; l'angle
; utilise V0, V1
; modifie ANGLE
;;;;;;;;;;;;;;;;;;;	
read_joystick:
    LD V0, 0
	LD V1, LEFT
	SKNP V1
	JP rot_left
	LD V1, RIGHT
	SKNP V1
	JP rot_right
	LD V1, UP
	SKNP V1
	JP rot_2left
	LD V1, DOWN
	SKNP V1
	JP rot_2right
    RET
rot_2left:
    ADD V0, 1
rot_left:
    ADD V0, 1	
    JP rotation
rot_2right:
    ADD V0, -1
rot_right:
    ADD V0, -1
rotation:
    ADD ANGLE, V0
	LD V0, 7
	AND ANGLE, V0
    RET

;;;;;;;;;;;;;;;;;;;;;
; attend que le 
; joueur presse le
; bouton du joystick
;;;;;;;;;;;;;;;;;;;;;	
wait_button:
   LD V0, FIRE_BTN
   SKP V0
   JP .-1
   LD V1, 4
   LD ST, V1
   SKNP V0
   JP .-1
   RET

;;;;;;;;;;;;;;;;;;
; affiche message
; d'information
; du jeu
; utilise V0-V2
;;;;;;;;;;;;;;;;;;
show_credits:
    CLS
	LD I, credits
	LD V0, 0
    SCRY V1
    LD V2, V1
	ADD V1, -8
	PRT V0,V1
	LD V1, FIRE_BTN
cred_loop:
	LD V0, 2
	CALL delay
	SCU 1
	ADD V2, -1
	SNE V2, 0
	JP cred_exit
	SKP V1
	JP cred_loop
cred_exit:
	LD V1, FIRE_BTN
	SKNP V1
	JP .-1
	RET

;;;;;;;;;;;;;;;;;;;;
; boucle qui tue le temps
; en tournant dans une 
; boucle vide jusqu'à 
; expiration de la minuterie
; DT
; argument V0=durée.
; La durée est en multiple de 16,67msec.
;;;;;;;;;;;;;;;;;;;;	
delay:
    LD DT, V0
	LD V0, DT
	SE V0, 0
	JP .-2
	RET

;;;;;;;;;;;;;;;;;;;;;;
; dessine pacman
; argument: V0=angle
; utilise V0, V1,V2,V3,I
;;;;;;;;;;;;;;;;;;;;;;	
draw_octopacman:
	LD V1, 56
    LD V2, 22
	LD V3, 32
	LD I, PACM0
	SNE V0, 0
	JP draw_xp1f 
draw_xp1b:
	ADD I, V3
	ADD V0, -1
	SE V0, 0
	JP draw_xp1b
draw_xp1f:	
    DRW V1,V2, 0	
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; dessine un bijou 
; argument: V0=index tableau
; utilise V0-V3 et I
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
draw_jewel:
	LD I, JTABLE
	LD V3, STRUC_SIZE
	SNE V0, 0
	JP draw_j1f
	ADD I, V3
	ADD V0, -1
	SE V0, 0
	JP .-3
draw_j1f:	
	LD V3, [I]
	LD I, JEWEL0
	LD V0, JEWEL_SIZE
	SNE V1, 0
	JP .+5
	ADD I, V0
	ADD V1, -1
	SE V1, 0
	JP .-3
	DRW V2,V3, 8
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; recherche position libre dans JTABLE
; génère nouveau bijou si 
; il y en a une
; utilise V0-V5, I
;;;;;;;;;;;;;;;;;;;;;;;;;;;	
new_jewel:
	RND V4, 7 ; index table
	PUSH V4
	LD V3, STRUC_SIZE
    LD I, JTABLE
	SNE V4, 0
	JP nj_1f
    ADD I, V3
	ADD V4, -1
	SE V4, 0
	JP .-3
nj_1f:
    POP V4	
    LD V5, 0
try_next:	
	LD V1,[I]
    SNE V0, 0
	JP free_slot
	ADD I, V3
	ADD V4, 1
	SE V4, 8 ; boucle début table
	JP .+3
	LD I, JTABLE
	LD V4, 0
	ADD V5, 1
	SNE V5, 8
	RET
	JP try_next
free_slot:
    RND V1, 3
	SNE V4, 0
	JP E
	SNE V4, 1
	JP NE
	SNE V4, 2
	JP N
	SNE V4, 3
	JP NW
	SNE V4, 4
	JP WEST
	SNE V4, 5
	JP SW
	SNE V4, 6
	JP S
SE: ; sud est
	LD V2, 120
	LD V3, 56
    JP store_it
S: ; sud
	LD V2, 60
	LD V3, 56
    JP store_it
SW: ; sud-ouet
	LD V2, 0
	LD V3, 56
    JP store_it
WEST:  ; ouest
	LD V2, 0
	LD V3, 28
    JP store_it
NW: ; nord-ouest
    LD V2, 0
	LD V3, 0 
    JP store_it
N:  ; nord
	LD V2, 56
	LD V3, 0
    JP store_it
NE: ; nord-est
	LD V2, 120
	LD V3, 0
    JP store_it
E:	; est
	LD V2, 120
	LD V3, 28
store_it:	
    LD V0, 1  ; occupée
    LD [I], V3
	LD V0, V4
	CALL draw_jewel
	ADD COUNT, 1
    RET
;;;;;;;;;;;;;;;;;;;;;
; libère la table 
; des jeux
; utilise V0, V1, V2
;;;;;;;;;;;;;;;;;;;;;
free_jtable:
    LD V2, STRUC_SIZE
    LD I, JTABLE
	LD V0, 0
	LD V1, 0
	LD [I], V0
	ADD I, V2
	ADD V1, 1
	SE V1, 8
	JP .-4
	RET

	
;;;;;;;;;;;;;;;;;;;;;;;;;
; déplace les bijoux
; vérifie pour collision
;;;;;;;;;;;;;;;;;;;;;;;;
move_jewel:
	LD V6, 0 ;index
    JP mj_get_record
mj_next:	
	ADD V6,1
	SNE V6, 8
	RET	
mj_get_record:	
	LD V0, V6
	CALL set_jewel_ptr
	LD V5, [I]
	SE V0, 1
	JP mj_next
mj_move_it:	
	LD V0, V1
	CALL set_sprite_ptr
	DRW V2,V3, JEWEL_SIZE
	ADD V2, V4
	ADD V3, V5
	LD V0, 1
	LD R, V5
	DRW V2, V3, JEWEL_SIZE
    LD V5, R
	LD V7, 1
	SNE VF, 1 ; collision?
	CALL collision
	LD V0, V6
	CALL set_jewel_ptr
	LD V0, V7
	LD [I], V5
	SE V7, 0
	JP mj_next
	LD V0, V1
	CALL set_sprite_ptr
	DRW V2,V3,JEWEL_SIZE
	ADD COUNT, -1
	JP mj_next
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  une collision a eu lieu
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
collision:	
	SE V6, ANGLE
	JP loose_points
win_points:	
	LD V8, 4
	LD ST, V8
	SNE V1, PERL
	ADD LLEN, P_VAL
    SNE V1, RUBY
    ADD LLEN, R_VAL
    SNE V1, DIAMOND
    ADD LLEN, D_VAL
	SNE V1, BIG_DIAMOND
	ADD LLEN, BD_VAL
	SE VF, 0
	LD LLEN, 255
 	JP coll_exit
loose_points:
    NOISE 4
	SNE V1, PERL
	ADD LLEN, -P_VAL
    SNE V1, RUBY
    ADD LLEN, -R_VAL
    SNE V1, DIAMOND
    ADD LLEN, -D_VAL
	SNE V1, BIG_DIAMOND
	ADD LLEN, -BD_VAL
	SE  VF, 1
	LD LLEN, 0
coll_exit:
	CALL update_line
	LD V7, 0
    RET	 
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ajuste I sur le bon sprite
; argument: V0=index sprite
; modifie: V0, I
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
set_sprite_ptr:
   PUSH V1
   LD I, JEWEL0
   LD V1, JEWEL_SIZE
   SNE V0, 0
   JP set_sp1f
   ADD I, V1
   add V0, -1
   SE V0, 0
   JP .-3
set_sp1f:   
   POP V1   
   RET	
;;;;;;;;;;;;;;;;;;;;
; ajuste I sur l'entrée
; de la table JTABLE
; argument: V0 = index
; modifie: V0, I
;;;;;;;;;;;;;;;;;;;;;;
set_jewel_ptr:
   PUSH V1
   LD I, JTABLE
   LD V1, STRUC_SIZE
   SNE V0, 0
   JP sjp_1f
   ADD I, V1
   ADD V0, -1
   SE  V0, 0
   JP .-3
sjp_1f:
   POP V1
   RET

;;;;;;;;;;;;;;;;;
; incrémente la variable
; CYCLEH
; utilise: V0, V1,I
;;;;;;;;;;;;;;;;;;;;   
inc_cycleh:
	LD I, CYCLEH
	LD V0, [I]
	ADD V0,1
	LD [I], V0
	LD V0, 8
	SUB V0, MAXJWL
	SE V0, 0
	ADD MAXJWL, 1
	RET
	
;;;;;;;;;;;;;;;;;;;;;;;
; affiche la durée de
; vie d'Octopacman
; entrée V3, V4 coordonées de départ
; utilise: V0,V1,V2,V5,I
;;;;;;;;;;;;;;;;;;;;;;;
display_time:
   LD I, CYCLEH
   LD V0, [I]
   LD I, BCD
   LD B, V0
   LD V2, [I]
   LD F, V0
   DRW V3, V4, 5
   ADD V3, 4
   LD F, V1
   DRW V3,V4, 5
   ADD V3, 4
   LD F, V2
   DRW V3,V4,5
   ADD V3,5   
   LD B, CYCLEL
   LD V2,[I]
   LD F, V0
   DRW V3,V4,5
   ADD V3,4
   LD F, V1
   DRW V3,V4,5
   ADD V3,4
   LD F, V2
   DRW V3,V4,5
   RET	
   
;;;;;;;;;;;;;;;;;;;;
; routine de délais
; utilise V0
;;;;;;;;;;;;;;;;;;;	
delay:
    LD DT, V0
    LD V0, DT
    SE V0, 0
    JP .-2
    RET	

CYCLEH:
    DB 0
	
MSG_OVER:
    ASCII "Partie terminee!"
	
PACM0:
	DW $................
	DW $.....1111111....
	DW $....1.......1...
	DW $...1....1....1..
	DW $..1....1.1....1.
	DW $.1......1....1..
	DW $.1..........1...
	DW $.1.........1....
	DW $.1.........1....
	DW $.1..........1...
	DW $.1...........1..
	DW $..1...........1.
	DW $...1.........1..
	DW $....1.......1...
	DW $.....1111111....
	DW $................

 PACM45:
	DW $................
	DW $.....11111......
	DW $....1....1......
	DW $...1.....1......
	DW $..1......1......
	DW $.1...1...1......
	DW $1...1.1..111111.
	DW $1....1........1.
	DW $1.............1.
	DW $1.............1.
	DW $1.............1.
	DW $.1...........1..
	DW $..1.........1...
	DW $...1.......1....
	DW $....1111111.....
	DW $................
	
PACM90:
	DW $................
	DW $....1......1....
	DW $...1.1....1.1...
	DW $..1...1..1...1..
	DW $.1.....11.....1.
	DW $.1............1.
	DW $.1...1........1.
	DW $.1..1.1.......1.
	DW $.1...1........1.
	DW $.1............1.
	DW $.1............1.
	DW $..1..........1..
	DW $...1........1...
	DW $....1......1....
	DW $.....111111.....
	DW $................

PACM135:
	DW $................
	DW $......11111.....
	DW $......1....1....
	DW $......1.....1...
	DW $......1......1..
	DW $......1...1...1.
	DW $.111111..1.1..1.
	DW $.1........1...1.
	DW $.1............1.
	DW $.1............1.
	DW $.1............1.
	DW $..1..........1..
	DW $...1........1...
	DW $....1......1....
	DW $.....111111.....
	DW $................
	
PACM180:		
	DW $................
	DW $....11111111....
	DW $...1........1...
	DW $..1....1.....1..
	DW $.1....1.1.....1.
	DW $..1....1......1.
	DW $...1..........1.
	DW $....1.........1.
	DW $....1.........1.
	DW $...1..........1.
	DW $..1...........1.
	DW $.1...........1..
	DW $..1.........1...
	DW $...111111111....
	DW $................

PACM245:
	DW $................
	DW $....11111111....
	DW $...1........1...
	DW $..1..........1..
	DW $.1............1.
	DW $1......1.......1
	DW $1.....1.1......1
	DW $1......1.......1
	DW $1..............1
	DW $1111111........1
	DW $......1.......1.
	DW $......1......1..
	DW $......1.....1...
	DW $......1....1....
	DW $......11111.....
	DW $................
	
PACM270:
	DW $................
	DW $.....111111.....
	DW $....1......1....
	DW $...1........1...
	DW $..1..........1..
	DW $.1............1.
	DW $.1............1.
	DW $.1............1.
	DW $.1........1...1.
	DW $.1.......1.1..1.
	DW $.1........1...1.
	DW $.1.....11.....1.
	DW $..1...1..1...1..
	DW $...1.1....1.1...
	DW $....1......1....
	DW $................

PACM315:
	DW $................
	DW $.....111111.....
	DW $....1......1....
	DW $...1........1...
	DW $..1.......1..1..
	DW $.1.......1.1..1.
	DW $.1........1...1.
	DW $.1............1.
	DW $.1............1.
	DW $.1........11111.
	DW $.1........1.....
	DW $..1.......1.....
	DW $...1......1.....
	DW $....1.....1.....
	DW $.....111111.....
	DW $................
	
JEWEL0: ; perle 1 points
    DB $........, $........
    DB $...11..., $..1111..	
    DB $..1111.., $...11...	
    DB $........, $........
	
JEWEL1: ; rubis 5 point 
    DB $........, $..1111..
    DB $.11..11., $11....11	
    DB $.11..11., $..1111..	
    DB $........, $........
	
JEWEL2: ; petit diamant 10 points
    DB $...11..., $..1.11..
    DB $.1...11., $1.....11	
    DB $1.....11, $.1...11.	
    DB $..1.11.., $...11...	

JEWEL3: ; gros diamant 20 points
    DB #18, #24
    DB #66, #99
    DB #99, #66
    DB #24, #18
	
LINE:
    DB #80, #80
	DB #C0, #C0
	DB #E0, #E0
	DB #F0, #F0
	DB #F8, #F8
	DB #FC, #FC
	DB #FE, #FE
	DB #FF, #FF
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; chaque élément de la table
; est une direction
; les données d'une direction sont
; 1 libre {0,1}  
; 2 type de bijou {0,1,2} 
; 3 x  {0..120}
; 4 y  {0..56}
; 5 dx {-2,0,2}  
; 6 dy {-1,0,1}  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
JTABLE: ; tableau des bijoux
    DB 0,0,120,28,-2,0 ; est
    DB 0,0,120,0,-2,1 ; nord-est
    DB 0,0,60,0,0,1 ; nord
    DB 0,0,0,0,2,1 ; nord-ouest
    DB 0,0,0,28,2,0 ; ouest
    DB 0,0,0,56,2,-1 ; sud-ouest
    DB 0,0,60,56,0,-1 ; sud
    DB 0,0,120,56,-2,-1 ; sud-est
	
BCD:
    DB 0,0,0,0
	