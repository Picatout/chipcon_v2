; bit operations test

    cls
	ld v0,#aa
	binv v0,0
	btss v0,0
	jp erreur
	bclr v0,1
	btsc v0,1
	jp erreur
	bset v0,1
	btss v0,1
	jp erreur
    ld I, msg_ok
	jp imprime

erreur:
    ld I, msg_erreur
imprime:
    ld v0,0
    ld v1,0
    prt v0,v1
    jp .



msg_erreur:
    ascii "erreur"
msg_ok:
    ascii "ok"
	