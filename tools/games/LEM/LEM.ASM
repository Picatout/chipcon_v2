;---------------------------------------------------------------------------
; Copyright 2014, 2015 Jacques Deschênes
; This file is part of CHIPcon.
;
;     CHIPcon is free software: you can redistribute it and/or modify
;     it under the terms of the GNU General Public License as published by
;     the Free Software Foundation, either version 3 of the License, or
;     (at your option) any later version.
;
;     CHIPcon is distributed in the hope that it will be useful,
;     but WITHOUT ANY WARRANTY; without even the implied warranty of
;     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;     GNU General Public License for more details.
;
;     You should have received a copy of the GNU General Public License
;     along with CHIPcon.  If not, see <http://www.gnu.org/licenses/>.
;
;--------------------------------------------------------------------------
; fichier source pour l'assembleur cc2asm.exe
;
; NOM: LEM
; DESCRIPION: Jeux qui consiste à faire alunir le LEM.
;             clone d'un jeux datant des années 197x
;             contrôle:  FIRE vers le haut
;                       LEFT vers la gauche
;                       RIGHT vers la droite
;
; AUTEUR: Jacques Deschênes
; CRÉATION: 2014-10-30
; MISE à JOUR: 2015-08-19
;--------------------------------------------------------------------------
;;;;;;;;;;;;;;;;;
;; constantes  ;;
;;;;;;;;;;;;;;;;;
equ PAD_WIDTH	16 ; largeur de la plateforme d'alunissage
equ LEM_WIDTH	16 ; largeur du LEM
equ K_RIGHT_JET	8 ; touche de contrôle du jet de droite
equ K_LEFT_JET	16 ; touche de contrôle du jet de gauche
equ K_UP_JET	32 ; touche de contrôle du jet vertical

;;;;;;;;;;;;;;;
;; variables ;;
;;;;;;;;;;;;;;;
defn xpos VE	; coordonnée x du LEM
defn ypos VD    ; coordonnée y du LEM
defn hspeed VC  ; vitesse horizontale du LEM
defn vspeed VB  ; vitesse verticale du LEM
defn fuel VA    ; niveau de carburant
defn score V9   ; nombre d'alunissage réussis
defn set V8     ; nombre de tentative d'alunissage
defn pad V7    ; position du pad d'alunissage


;;;;;;;;;;;;;;;;;;;;
;;  code segment  ;;
;;;;;;;;;;;;;;;;;;;;
	cls
	call show_credit
	cls
	ld score, 0
	ld set, 0
next_set:
	add set,1
;position initiale du LEM
;centre haut de l'écran
    scrx xpos
    ld w, pad_width
	sub xpos, w
	shr xpos
	ld ypos,0  
; vitesses initiales nulles 
	ld hspeed,0
	ld vspeed,0
;réservoir carburant plein
	ld fuel, 100
; dessine la surface de la lune
	call moonscape
; dessine LEM et affiche le niveau carburant
	call drw_lem
	call prt_fuel_level
;boucle principale
main:
	sne fuel,0 
	jp move_lem ; plus de carburant ignore le clavier
; lecture clavier
	ld w, K_RIGHT_JET
	sknp w ; jet de droite allumé
	jp right_jet
	ld w, K_LEFT_JET
	sknp w ; jet de gauche allumé
	jp left_jet
	ld w, K_UP_JET
	sknp w ; fusée principale allumée
	jp up_jet
	jp move_lem
right_jet:
	call prt_fuel_level 
	add hspeed,-1  
	add fuel,-1  
	jp update_fuel
; accélaration vers la droite
left_jet:
	call prt_fuel_level
	add hspeed, 1   
	add fuel, -1 
	jp update_fuel
;accélaration vers le haut
up_jet:
	call prt_fuel_level
	add vspeed, -2  
	se fuel, 1
	add fuel, -1  ; réacteur plus puissant consomme 2 unités de carburant
	add fuel, -1   
update_fuel:
	noise 4
	call prt_fuel_level
; déplacement LEM
move_lem:
	call prt_fuel_level ; efface niveau de carburant
	call drw_lem ; efface LEM
; mise à jour position LEM
	add xpos, hspeed  
	ld w,127
	and xpos,w
	add ypos, vspeed 
	add vspeed, 1  ; gravitée
	call drw_lem
	sne C, 1
	jp collision
; affiche le niveau de carburant
	call prt_fuel_level
	sne fuel, 0
	jp fuel_empty
; délais
	ld w,20
	call delay 
	jp main
; réservoir vide
fuel_empty:
	call prt_fuel_level
	ld w, 10
	ld v1, 4
	tone w,v1
	ld w, 4
	call delay
	call prt_fuel_level
	ld w, 4
	tone w,v1
	call delay
	jp main

;délais
; arguments:
; 	w = nombre de frame
delay:
	ld dt,w
	ld w, dt
	se w, 0
	jp .-2
	ret
	
; il y a eu collision avec le sol	
; condition succès: 
;   LEM entièrement sur le pad
;   vitesse inférieure à 3
collision:
	call prt_fuel_level
	ld w,2
	sub w, vspeed
	se C, 1
	jp crash  ; vitesse verticale trop grande
	ld w,2
	sub w, hspeed
	se C, 1
	jp crash  ; vitesse horizontale trop grande
	se xpos, pad
	jp crash    ; hors du pad
; alunissage réussi
	add score,1
	ld i, success_msg
	ld v1,0
	ld v2,16
	prt v1,v2
	jp wait_next_set
crash:
	ld i, crash_msg
	ld v1, 0
	ld v2,16
	prt v1,v2
wait_next_set:
	call display_score
	ld w, 60
	call delay
	ld w, K_UP_JET
	skp w
	jp .-1
	ld v1, 1
	ld v2, 10
	tone v1, v2
	sknp w
	jp .-1
	cls
	jp next_set

	
	
; dessine le LEM
drw_lem:
	ld I, LEM
	DRW xpos,ypos,0
	ret

; affiche le pointage
; variables locales
;	v1  position x
;	v2  position y
display_score:
	ld v1, 0
	ld v2, 10
	ld i, bcd
	ld b, score
	call display_bcd
	ld i, slash
	drw v1,v2,5
	add v1, 4
	ld i, bcd
	ld b, set
	call display_bcd
	ret
	
; affiche le nombre contenu dans la variable bcd
; utilise la police 4x6
; arguments: 
; 	v1 position x (incrémenté de 4 après chaque caractère)
;   v2 position y	
; variable locales:
;	v3 index dans le tableau bcd
;	w contient le digit à afficher
display_bcd:
	ld v3, 0
	ld i, bcd
	add i, v3
	ld w, [i]
	ld f, w
	drw v1,v2,5
	add v1,4
	add v3,1
	se v3,3
	jp .-8
	ret

;dessine la surface de la lune
;variables locales:
;	v1 position y du pixel
;   v3 variable temporaire
;   v4 position à droite du pad
;	v5 position x du pixel
moonscape:
	ld v5,0
	;position du pad au hasard
	rnd pad,#7F
	scrx w
	ld v3, PAD_WIDTH
	sub w, v3
	push w
	sub w, pad
	pop w
	se C, 1
    ld pad, w
    ld v4, pad
    add v4, PAD_WIDTH
    rnd v1,#0F
	scry w
	subn v1, w
scape_loop:
	ld v3,v5
	sub v3,pad 
	se C,1
	jp rand_y  ; à gauche du pad
	ld v3,v5
	sub v3,v4
	se C,1  ; à droite du pad
	jp put_pixel ; sur le pad
rand_y:
	scry w
	shr w
	sub w, v1
	se C, 0
	add v1, 1
    scry w
	add w, -1
	subn w, v1
	se C, 0
	add v1,-1
	rnd v3,3
	shr v3
	se v3,0
	add v1,254
	add v1,1
put_pixel:
	pixi v5,v1
	add v5,1
	scrx w
	se v5, w
	jp scape_loop
	ret

; affiche le niveau de carburant
; utilise la police 8x10
; variables locales:
;	v1  position x (incrémenté de 8 après chaque caractère)
;	v2	position y
;   w  chiffre à afficher
;   v3  index dans le tableau bcd (incrémenté de 1 après chaque caractère)
prt_fuel_level:
	ld v1,0
	ld v2,0
	ld v3,0
	ld I, BCD
	ld B, fuel
prt_fuel_loop:	
	ld I, BCD
	add i, v3
	ld w,[I]
	ld LF,w
	drw v1,v2,10
	add v1,8
	add v3,1
	se v3,3
	jp prt_fuel_loop
	ret

show_credit:
    ld i, credit
    ld v1, 0
	scry v2
    shr v2
    prt v1,v2
	scry v1
scroll_loop:
	ld w,FIRE_BTN
	sknp w
	ret
    scu 1
	ld w,3
	call delay
	add v1,-1
	se v1, 0
	jp scroll_loop
	ret
	
;;;;;;;;;;;;;;;;;;;;;;;;;;
;;     data  segment    ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;	

; véhicule d'alunissage	
LEM:
	dw	$......1111......
	dw  $.....11..11.....
	dw  $...1111111111...
	dw  $..111111111111..
	dw	$..1..........1..
	dw	$1.1.11111111.1.1
	dw	$.11.11....11.11.
	dw	$..1.11....11.1..
	dw  $.11.11111111.11.
	dw	$1.1..........1.1
	dw	$..111111111111..
	dw	$..111111111111..
	dw	$...1..1.1..1....
	dw	$..1..1...1..1...
	dw	$.11.........11..
	dw  $11...........11.

slash:
	db $..1....., $.1......
	db $.1......, $1....... 
	db $1.......

crash_msg:
	ascii "you crashed"
success_msg:
	ascii "congratulation!"
credit:
    ascii "LEM\nJacques Deschenes\nCopyright 2014,2015\nlicence GPLv3"
	
; espace variable BCD
BCD:
	db	0,0,0

	
end	
