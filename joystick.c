/*
* Copyright 2014, 2015, Jacques Deschênes
* This file is part of CHIPcon v2.
*
*     CHIPcon is free software: you can redistribute it and/or modify
*     it under the terms of the GNU General Public License as published by
*     the Free Software Foundation, either version 3 of the License, or
*     (at your option) any later version.
*
*     CHIPcon is distributed in the hope that it will be useful,
*     but WITHOUT ANY WARRANTY; without even the implied warranty of
*     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*     GNU General Public License for more details.
*
*     You should have received a copy of the GNU General Public License
*     along with CHIPcon v2.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <avr/pgmspace.h>

#include "hardware.h"
#include "joystick.h"
#include "text.h"
#include "tone.h"

//retourne l'état du bouton
inline uint8_t joystick_btn_down(uint8_t btn){
	return (JSTK_PIN & btn)==0;
}//f()

//attend qu'un bouton sois enfoncé.
uint8_t joystick_wait_any(){
	while ((JSTK_PIN & JSTK_IMASK)==JSTK_IMASK);
	return (~(JSTK_PIN & JSTK_IMASK))&JSTK_IMASK;
}//f()

inline void joystick_wait_release(){
	while ((JSTK_PIN&JSTK_IMASK)!=JSTK_IMASK)tone(500,2);
}//f()

void prompt_btn(){
	prt_pstr(PSTR("\nbouton..."));
	while (JSTK_PIN&BTN_FIRE);
    joystick_wait_release();
}//f()

uint8_t joystick_break(){
	if (!(JSTK_PIN & (BTN_UP|BTN_DOWN))||(!(JSTK_PIN&(BTN_LEFT|BTN_RIGHT)))){
		joystick_wait_release();
		return 1;
	}
	return 0;
}//f()

