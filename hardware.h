/*
* Copyright 2014, Jacques Deschênes
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
 * hardware.h
 *
 * créé le: 2014-09-25 08:14:55
 *  Auteur: Jacques Deschênes
 *
 */ 


#ifndef HARDWARE_H_
#define HARDWARE_H_

#define F_CPU 16000000L
#define __CHIP_COMP__ 1

#include "chipcon_config.h"

#include <avr/io.h>


#define BYTE uint8_t

// broches pour le vidéo
#define NTSC_SYNC_PORT PORTB
#define NTSC_SYNC_DDR  DDRB
#define NTSC_VIDEO_PORT PORTD
#define NTSC_VIDEO_UCSRA UCSR0A
#define NTSC_VIDEO_UCSRB UCSR0B
#define NTSC_VIDEO_UCSRC UCSR0C
#define NTSC_VIDEO_UBRR  UBRR0
#define NTSC_VIDEO_UDR  UDR0
#define	NTSC_SYNC_OCRA OCR1A
#define	NTSC_SYNC_OCRB OCR1B
#define	NTSC_SYNC_TCCRA TCCR1A
#define	NTSC_SYNC_TCCRB TCCR1B
#define	NTSC_SYNC_TIMSK TIMSK1
#define NTSC_SYNC_TCNT  TCNT1
#define NTSC_SYNC_IE (1<<OCIE1B)
#define NTSC_SYNC_OUT (1<<PORTB2)
#define NTSC_VIDEO_OUT (1<<PORTD1)


// interface joystick
#define JSTK_DDR  DDRC
#define JSTK_IPORT PORTC
#define JSTK_PIN   PINC
#define JSTK_INP5   (1<<PORTC5)
#define JSTK_INP4   (1<<PORTC4)
#define JSTK_INP3   (1<<PORTC3)
#define JSTK_INP2   (1<<PORTC2)
#define JSTK_INP1  (1<<PORTC1)
#define JSTK_IMASK  (JSTK_INP5|JSTK_INP4|JSTK_INP3|JSTK_INP2|JSTK_INP1)
// interface SPI carte SD et SRAM
#define SPI_PORT PORTB
#define SPI_DDR  DDRB
#define SPI_CLK  (1<<PORTB5)
#define SPI_MISO  (1<<PORTB4)
#define SPI_MOSI (1<<PORTB3)
#define SPI_CR  SPCR
#define SPI_DR  SPDR
#define SPI_SR  SPSR
#define SPI_SLOW_CLOCK() {SPI_SR&=~1u;SPI_CR|=3u;}
#define SPI_FAST_CLOCK() {SPI_SR|=1;SPI_CR&=~3u;}	

// sélectin carte SD
#define SDC_PORT PORTB
#define SDC_DDR  DDRB
#define SDC_SEL  (1<<PORTB1)
#define SDC_DETECT (1<<PORTB0)
#define SDC_PIN  PINB

// selection SRAM
#define SRAM_PORT PORTC
#define SRAM_DDR  DDRC
#define SRAM_SEL   (1<<PORTC0)
//sram commands
#define SRAM_READ (3)
#define SRAM_WRITE (2)
#define SRAM_EDIO (0x3b)
#define SRAM_EQIO (0x38)
#define SRAM_RSTIO (0xff)
#define SRAM_RDMR  (5)
#define SRAM_WRMR  (1)
#define SRAM_BTMOD (0x00)
#define SRAM_PGMD  (0x80)
#define SRAM_SQMD  (0x40)
// octets dans SRAM 24LC512
#define SRAM_SIZE (65536)
// longueur nom fichier
// dans SRAM
#define ENTRY_SIZE (32)

// générateur de sons
#define TONE_OCRA  OCR0A
#define TONE_TCCRA TCCR0A
#define TONE_TCCRB TCCR0B
#define TONE_PORT  PORTD
#define TONE_DDR   DDRD
#define TONE_OUT   (1<<PORTD6)
#define TONE_ENV   (1<<PORTD0)

#endif /* HARDWARE_H_ */