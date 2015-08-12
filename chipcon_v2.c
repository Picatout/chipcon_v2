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
 * chipcon.c
 *
 * Created: 2014-09-22 20:05:57
 *  Author: Jacques Desch�nes
 */ 


// doit-�tre inclus avant <util/delay.h>
#include "hardware.h"


#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <avr/interrupt.h>
#include <avr/pgmspace.h>
#include <avr/io.h>
#include <util/delay.h>

// fichiers d'ent�te du projet
#include "tvout.h"
#include "joystick.h"
#include "sram.h"
#include "text.h"
#include "tone.h"
#include "chipcon_vm.h"
#include "splash.h"

#if SDC_SUPPORT
#include "filesys.h"
#endif

//jeux en m�moire FLASH
#include "lem.h"
#include "car.h"
#include "worm.h"
#include "alien.h"
#include "blinky.h"

extern vm_state_t vms;


void load_flash_game(const uint8_t *addr,uint16_t size){
	uint16_t i;
	
	for (i=0;i<size;i++){
		sram_write_byte(CODE_BASE_ADDR+i,pgm_read_byte(&addr[i]));
	}
}

#define MAX_ENTRIES (2048)
#define DISPLAY_LINES (10)



uint8_t display_page(int16_t page){
	uint8_t fname[ENTRY_SIZE];
	uint8_t i;
	for (i=0;i<DISPLAY_LINES;i++){
		sram_load_block(page*DISPLAY_LINES*ENTRY_SIZE+(i*ENTRY_SIZE),ENTRY_SIZE,fname);
		if (strlen((char *)fname)){
			put_char(' ');
			print(fname);
			if (i<7) new_line();
		}else{
			break;
		}
	}
	return i;
}

inline void display_cursor(uint8_t line){
	put_sprite(0,line*CHAR_HEIGHT,8,&font_6x8[(RIGHT_ARROW-32)*CHAR_HEIGHT],FLASH_MEM);
}

// s�lectionne un fichier
// � partir de la liste
// affich�e � l'�cran
int16_t select_file(int16_t fcount){
	int16_t page, selected;
	uint8_t key, pg_lines;
	
	cls();
	page=0;
	selected=0;
	frame_delay=2;
	while (frame_delay);
	pg_lines=display_page(page);
	while (1){
		display_cursor(selected);
		key=joystick_wait_any();
		//key_tone(key,6,false);
		display_cursor(selected);
		switch(key){
		case BTN_FIRE: 
		    joystick_wait_release();
			return page*DISPLAY_LINES+selected;
			break;
		case BTN_LEFT: // page pr�c�dente
			if (page){
				page--;
				selected=7;
				cls();
				pg_lines=display_page(page);
			}else{
				selected=0;
			}
			break;
		case BTN_RIGHT: // page suivante
			if ((page*DISPLAY_LINES+DISPLAY_LINES)<fcount){
				page++;
				selected=0;
				cls();
				pg_lines=display_page(page);
			}else{
				selected=pg_lines-1;
			}
			break;	
		case BTN_UP: // item pr�c�dent
			if (selected){
				selected--;
			}else if (page){
				page--;
				selected=7;
				cls();
				pg_lines=display_page(page);
			}
			break;
		case BTN_DOWN: // item suivant
			if (selected<(pg_lines-1)){
				selected++;
			}else if ((page*DISPLAY_LINES+DISPLAY_LINES)<fcount){
				page++;
				selected=0;
				cls();
				pg_lines=display_page(page);
			}
			break;
		default:
			break;
		}//switch
		while (_joystick_state()!=JSTK_IMASK)key_tone(key,2,true);
	}//while	
}

#if SDC_SUPPORT
// copie la liste des fichiers
// du r�pertoire racine
// dans la SRAM
int16_t sdc_files(){
		uint8_t fname[ENTRY_SIZE];
		int16_t entry_nbr;
        struct fat_dir_entry_struct dir_entry;
		
        /* charge les fichiers dans la SRAM */
		entry_nbr=0;
		fname[ENTRY_SIZE-1]=0;
        while((entry_nbr<MAX_ENTRIES) && fs_read_dir(&dir_entry))
        {
	        if (!(dir_entry.attributes & FAT_ATTRIB_DIR)){
				strcpy((char*)fname,dir_entry.long_name);
				sram_store_block(entry_nbr*ENTRY_SIZE,ENTRY_SIZE,fname);
				entry_nbr++;
			}
        }
		fname[0]=0;
		sram_store_block(entry_nbr*ENTRY_SIZE,ENTRY_SIZE,fname);
		return entry_nbr;
}

void games_on_sdcard(){
	int16_t fcount, selected;

	
	fcount=sdc_files();
	if (fcount && ((selected=select_file(fcount))>-1)){
		if (fs_load_file(selected)){
			cls();
			if (schipp()==CHIP_BAD_OPCODE){
				print_vms(PSTR("CRASH! bad opcode\n"));
			}
		}
	}
}
#endif

//nom des jeux en flash
PROGMEM const uint8_t flash_games[]=
"LEM\n"
"CAR\n"
"WORM\n"
"ALIEN\n"
"BLINKY\n"
"";


// s�lection et ex�cution
// d'un jeux qui est en
// m�moire flash
void games_in_flash(){
	uint16_t i=0,j,entry=0,selected;
	uint8_t c, name[32];

	memset(name,0,ENTRY_SIZE);
	while ((c=pgm_read_byte(&flash_games[i++]))){
		j=0;
		while (c && (c!='\n')){
			name[j++]=c;
			c=pgm_read_byte(&flash_games[i++]);
		}
		sram_store_block(entry*ENTRY_SIZE,ENTRY_SIZE,name);
		entry++;
		memset(name,0,ENTRY_SIZE);
		if (!c) break;
	}
    sram_store_block(entry*ENTRY_SIZE,ENTRY_SIZE,name);
	cls();
	selected=select_file(entry);
	switch(selected){
	case 0:
		load_flash_game((const uint8_t*)lem,LEM_SIZE);
//		text_scroller((const uint8_t*)lem_info,4);
		break;
		
	case 1:
		load_flash_game((const uint8_t*)car,CAR_SIZE);
//		text_scroller((const uint8_t*)car_info,4);
		break;

	case 2:
		load_flash_game(worm,WORM_SIZE);
//		text_scroller(worm_info,4);
		break;

	case 3:
		load_flash_game(alien,ALIEN_SIZE);
//		text_scroller(alien_info,4);
		break;

	case 4:
		load_flash_game(blinky,BLINKY_SIZE);
//		text_scroller(mines_info,4);
		break;
/*
	case 5:
		load_flash_game(magic_square,SQUARE_SIZE);
		text_scroller(magic_square_info,4);
		break;

	case 6:
		load_flash_game(field,FIELD_SIZE);
		text_scroller(field_info,4);
		//set_break_point(0x302);
		//set_break_point(0x2fa);
		//set_break_point(0x304);
		break;
*/
	default:
		return;	
	}
	cls();
	if (schipp()==CHIP_BAD_OPCODE){
		print_vms(PSTR("CRASH! bad opcode\n"));	
	};

}

 PROGMEM const uint8_t credits[]=
	"FAT driver\n"
	"Copyright 2006-2012\n"
	"Roland Riegel\n";


void splash_screen(){
	uint16_t i;
	
	for (i=0;i<SPLASH_SIZE;i++) sram_write_byte(SAVE_SCREEN_ADDR+i,pgm_read_byte((splash+i)));
	screen_restore();
	frame_delay=120;
	while (frame_delay){
		if (_joystick_state()!=JSTK_IMASK){
			 tone(1000,2);
			 frame_delay=0;
		}
	}
	joystick_wait_release(); 
}

int main(void){
	uint8_t sdc_ok=0;
	
	CLKPR= (1<<7);
	CLKPR = 0 ; // d�sactivation du diviseur
	tvout_init();
	//initialisation SPI
	SPI_DDR |= SPI_CLK+SPI_MOSI;
	SPI_CR = (1<<SPE)|(1<<MSTR);
	SPI_SR |= 1; // Fosc/2
	// initialisation du joystick Atari 2600
	_joystick_init();
	// initialisation sons
	tone_init();
	// initialisation m�moire SRAM
	sram_init();
	sei();// activation des interruptions
	srand(TCNT1);
#if SDC_SUPPORT
	//initialisation carte SD
	sd_raw_init();
	if (fs_mount()) sdc_ok=fs_open_dir("/");
#endif
#if !FW_DEBUG
	splash_screen();
	text_scroller(credits,4);
#endif	
	while (1){
		//sram_clear();
		cls();
		select_font(FONT_ASCII);
#if SDC_SUPPORT
/*
select_font(FONT_ASCII);
set_cursor(0,0);
prt_pstr((PSTR("first line")));
set_cursor(0,VRES-CHAR_HEIGHT);
prt_pstr(PSTR("last line"));
while(1);
*/
		if (!sdc_ok){
			prt_pstr(PSTR("carte SD absente!"));
			new_line();
			prompt_btn();
#endif
			games_in_flash();
#if SDC_SUPPORT 
		}else{
			games_on_sdcard();
		}
		
#endif		
	}//while(1)
	return EXIT_SUCCESS;
}

