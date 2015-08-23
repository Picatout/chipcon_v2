; test assembler 
; predefined 

start:
    cls
	ld w, UP
	ld i, bcd
	ld b, w
	ld v2, [i]
	ld v4, 0
	call print
    ld w, DOWN
    ld i, bcd
    ld b, w
	ld v2, [i]
    add v4, 6
    call print
    ld w, LEFT
    ld i, bcd
    ld b, w
	ld v2, [i]
    add v4, 6
    call print
    ld w, RIGHT
    ld i, bcd
    ld b, w
	ld v2, [i]
    add v4, 6
    call print
    ld w, FIRE_BTN
    ld i, bcd
    ld b, w
	ld v2, [i]
    add v4, 6
    call print
   	ld w, 255
	add w, 1
	se c, 1
	jp .
	jp start
	
	
print:
	ld v3, 0
    ld f, w
    drw v3,v4, 5
    add v3, 4
	ld f, v1
    drw v3,v4, 5
    add v3, 4
    ld f, v2
    drw v3,v4, 5	
	ret
	
	
bcd:
  db 0,0,0	