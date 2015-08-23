; 
;  test SAVE and RSTR
;

start:
	cls
	ld v0,0
	ld v1,0
	ld I, msg
	prt v0,v1
	ld v0, 60
	ld v1, 30
    ld I, dot
	drw v0,v1,4
	ld v0, 30
	ld dt, v0
	ld v0,dt
	se v0, 0
	jp .-2
	save
	cls
	ld v0,30
	ld dt, v0
	ld v0,dt
	se v0, 0
	jp .-2
	rstr
	jp start
	
	
	
	
	
	
	
msg:
  ASCII "save restore test"	
	
dot:
  DB  #ff,#ff,#ff,#ff	