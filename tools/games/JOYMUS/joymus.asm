; joystick musical
; Jacques Deschenes
; 2015-08-18

equ UP 2
equ DOWN 4
equ LEFT 8
equ RIGHT 16
equ FIRE 32


	cls
    ld v0,0
    ld v1,0
    ld i, credits
    prt v0,v1
	ld v2,2
loop:
	ld v1,255
    ld v0,k
    sne v0, UP
	ld v1,0
	sne v0, UP+RIGHT
    ld v1,1
    sne v0, RIGHT
    ld v1,2
    sne v0,RIGHT+DOWN
    ld v1,3
    sne v0,DOWN
    ld v1,4
    sne v0,DOWN+LEFT
    ld v1,5	
	sne v0, LEFT
	ld v1,6
	sne v0, LEFT+UP
	ld v1,7
	sne v0, FIRE+UP
	ld v1,8
	sne v0, FIRE+UP+RIGHT
	ld v1,9
	sne v0, FIRE+RIGHT
	ld v1,10
	sne v0, FIRE+RIGHT+DOWN
	ld v1,11
	sne v0, FIRE+DOWN
	ld v1,12
	sne v0, FIRE+DOWN+LEFT
	ld v1,13
	sne v0, FIRE+LEFT
	ld v1,14
	sne v0, FIRE+LEFT+UP
	ld v1,15
	se v1,255
	tone v1,v2,wait
	jp loop

  
	
credits:
	ascii "Joystick musical\nJacques Deschenes\n2015"
	