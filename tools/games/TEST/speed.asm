; speed test
; boucle simple:

EQU BTN_FIRE 32

start:
	cls
	ld i, speed_test 
	ld v0,0
	ld v1,0
	prt v0,v1
	ld v3, 60
	ld v0, 0
	ld v1, 0
	ld dt, v3
loop:
    add v1,1
	se vf,0
	add v0,1
	ld v3,dt
	se v3,0
	jp loop
    ld v4,0
	ld v5,8
	call imprime
	ld v4,0
	ld v5,16
	ld v0,v1
	call imprime
	ld v2, 60
	ld dt, v2
	ld v2, dt
	se v2,0
	jp .-2
	ld v0, BTN_FIRE
	skp v0
	jp start
	exit
;imprime résultat
; v0=nombre
; v3 digit counter
; v4=x
; v5=y
imprime:
    ld i, bcd
	ld b, v0
	ld v3, 0 
imp_loop:
	ld i, bcd
	add i, v3
    ld v0,[i]
    ld f, v0
    drw v4,v5,5
	add v4,4
	add v3,1
	se v3,3
	jp imp_loop
	ret
 



speed_test: 
   ASCII "speed test"
   
bcd: 
	db 0,0,0
   
end
 