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
*     along with CHIPcon.  If not, see <http://www.gnu.org/licenses/>.
*/

/*
 * chipcon.c
 *
 * Created: 2014-09-22 20:05:57
 *  Author: Jacques Deschênes
 */ 


// doit-être inclus avant <util/delay.h>
#include "hardware.h"


#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <avr/interrupt.h>
#include <avr/pgmspace.h>
#include <avr/io.h>
#include <util/delay.h>

// fichiers d'entête du projet
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

//jeux en mémoire FLASH
#include "lem.h"
#include "car.h"
#include "worm.h"
#include "alien.h"
#include "blinky.h"
#include "joymus.h"
#if TEST
#include "speed.h"
#endif

extern vm_state_t vms;


void load_flash_game(const uint8_t *addr,uint16_t size){
	uint16_t i;
	
	for (i=0;i<size;i++){
		sram_write_byte(CODE_BASE_ADDR+i,pgm_read_byte(&addr[i]));
	}
}

#define MAX_ENTRIES (2048)
#define DISPLAY_LINES (VRES/CHAR_HEIGHT)



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
	put_sprite(0,line*CHAR_HEIGHT,CHAR_HEIGHT,&font_6x8[(RIGHT_ARROW-32)*CHAR_HEIGHT],FLASH_MEM);
}

// sélectionne un fichier
// à partir de la liste
// affichée à l'écran
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
		case BTN_LEFT: // page précédente
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
		case BTN_UP: // item précédent
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
char ext[]=".bin";
char extu[]=".BIN";

#if SDC_SUPPORT
// copie la liste des fichiers
// du répertoire racine
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
	        if (!(dir_entry.attributes & FAT_ATTRIB_DIR) && ((strstr(dir_entry.long_name,ext))||(strstr(dir_entry.long_name,extu)))){
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
"LEM\n"  // case 0
"CAR\n"  // case 1
"WORM\n"  // case 2
"ALIEN\n" // case 3
"BLINKY\n" // case 4
"JOYMUS\n" // case 5
#if TEST
"speed test\n" // case last
#endif
"";


// sélection et exécution
// d'un jeux qui est en
// mémoire flash
void games_in_flash(){
	uint16_t i=0,j,entry=0,selected;
	uint8_t c,  name[32];

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
		break;
		
	case 1:
		load_flash_game((const uint8_t*)car,CAR_SIZE);
		break;

	case 2:
		load_flash_game(worm,WORM_SIZE);
		break;

	case 3:
		load_flash_game(alien,ALIEN_SIZE);
		break;

	case 4:
		load_flash_game(blinky,BLINKY_SIZE);
		break;
	case 5:
	    load_flash_game(joymus,JOYMUS_SIZE);
		break;	
#if TEST		
	case 6:
		load_flash_game(speed,SPEED_SIZE);
		break;
#endif		
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
	
	for (i=0;i<VIDEO_BUFF_SIZE;i++) video_write_byte(i,pgm_read_byte((splash+i)));
	frame_delay=60;
	while (frame_delay){
		if (_joystick_state()!=JSTK_IMASK){
			 tone(1000,2);
			 frame_delay=0;
		}
	}
	joystick_wait_release(); 
	cls();
}

int main(void){
	uint8_t sdc_ok=0;
	
	CLKPR= (1<<7);
	CLKPR = 0 ; // désactivation du diviseur
	tvout_init();
	select_font(FONT_ASCII);
	//initialisation SPI
	SPI_DDR |= SPI_CLK+SPI_MOSI;
	SPI_CR = (1<<SPE)|(1<<MSTR);
	SPI_SR |= 1; // Fosc/2
	// initialisation du joystick Atari 2600
	_joystick_init();
	// initialisation sons
	tone_init();
	// initialisation mémoire SRAM
	sram_init();
	sei();// activation des interruptions
	splash_screen();
	srand(TCNT1);
	
#if SDC_SUPPORT
	//initialisation carte SD
	if (sd_raw_init() && fs_mount()){
		 sdc_ok=fs_open_dir("/");
	}else{
		SPI_FAST_CLOCK();
	}
#endif
#if !FW_DEBUG
	text_scroller(credits,4);
#endif	
	while (1){
		//sram_clear();
		cls();
		select_font(FONT_ASCII);
#if SDC_SUPPORT==1
		if (sdc_ok){
			games_on_sdcard();
		}else{
			prt_pstr(PSTR("carte SD?\n"));
			prompt_btn();
			games_in_flash();
		}
#else		
		games_in_flash();
#endif		
	}//while(1)
	return EXIT_SUCCESS;
}

