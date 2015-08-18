/*
* Copyright 2014, Jacques Desch�nes
* This file is part of CHIPcon.
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
*     along with CHIPcon.  If not, see <http://www.gnu.org/licenses/>.
*/

/*
 * tone.h
 *
 * Created: 2014-09-26 10:18:30
 *  Author: Jacques Desch�nes
 */ 


#ifndef TONE_H_
#define TONE_H_
#include <stdbool.h>
#include "hardware.h"


#define tone_on() TONE_PORT |= TONE_ENV
#define tone_off() TONE_PORT &= ~TONE_ENV
#define wait_tone_end()  while (tone_length)

void tone_init();
void tone(uint16_t freq, uint8_t length);
void key_tone(uint8_t key, uint8_t length,bool wait_end);
void noise(uint8_t length);


#endif /* TONE_H_ */