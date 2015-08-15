/*
* Copyright 2014, 2015, Jacques Desch�nes
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
*     along with CHIPcon.  If not, see <http://www.gnu.org/licenses/>.
*/

/*
 * tvout.h
 *
 * Created: 2014-09-25 12:34:43
 *  Author: Jacques Desch�nes
 */ 


#ifndef TVOUT_H_
#define TVOUT_H_

#include <avr/pgmspace.h>


#define HRES (128)
#define HBYTES (HRES/8)
#if !SDC_SUPPORT
//lorsque pas de support carte SD
//r�solution maximale
#define VRES (96)
#else
#if DEFVRES==1
#define VRES (64)
#elif DEFVRES==2 
#define VRES (72)
#else
#define VRES (88)
#endif
#endif
#define VIDEO_BUFF_SIZE (HBYTES*VRES)
#define VLINES (VRES*2)
#define FIRST_VISIBLE (((240-VLINES)>>1)+24)
#define LAST_VISIBLE  (VLINES+FIRST_VISIBLE-1)

#define SAVE_SCREEN_ADDR (32768)

//where is the sprite
#define FLASH_MEM  (0)
#define RAM_MEM (1)

typedef enum OP_TYPE {WHITE,BLACK, INVERT} optype;

// dur�e maximale 255*16,7msec=4,3 sec.
extern volatile uint8_t frame_delay;
extern volatile uint8_t tone_length;

void tvout_init();
void plot(int8_t x, int8_t y, optype op);
int8_t put_sprite(int8_t x, int8_t y, uint8_t n, const uint8_t *sprite, int8_t memory);
int8_t put_big_sprite(int8_t x, int8_t y,const uint8_t *sprite);
void cls();
void scroll_down(uint8_t lines);
void scroll_up(uint8_t lines);
void scroll_right(uint8_t pixels);
void chip_scroll_right();
void scroll_left(uint8_t pixels);
void chip_scroll_left();
void screen_save();
void screen_restore();
void video_write_byte(uint16_t addr, uint8_t b);
#endif /* TVOUT_H_ */