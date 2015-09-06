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

#ifndef JOYSTICK_H_
#define JOYSTICK_H_
#include "hardware.h"

#define BTN_UP    JSTK_INP1
#define BTN_DOWN  JSTK_INP2
#define BTN_LEFT  JSTK_INP3
#define BTN_RIGHT JSTK_INP4
#define BTN_FIRE  JSTK_INP5

//initialisation joystick
#define  _joystick_init()  {JSTK_DDR &= ~JSTK_IMASK; JSTK_IPORT |= JSTK_IMASK;}
#define _joystick_state()  (JSTK_PIN & JSTK_IMASK)



//retourne l'état du bouton
uint8_t joystick_btn_down(uint8_t btn);
//attend qu'un bouton sois enfoncé.
uint8_t joystick_wait_any();
// attend qu'aucun bouton ne soit enfoncé.
void joystick_wait_release(); 
//affiche un message attend bouton FIRE
void prompt_btn();
//vérifie pour un signal break
uint8_t joystick_break();
#endif /* JOYSTICK_H_ */
