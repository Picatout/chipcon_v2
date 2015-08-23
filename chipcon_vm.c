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
 * chipcon_vm.c
 *
 * Created: 2014-09-26 10:10:45
 *  Author: Jacques Deschênes
 *  Description: machine virtuelle qui exécute du byte code super CHIP
 */ 

// doit-être inclus avant <util/delay.h>
#include "hardware.h"

#include <stdlib.h>
#include <avr/interrupt.h>
#include <avr/pgmspace.h>
#include <avr/io.h>
#include <util/delay.h>

#include "chipcon_vm.h"
#include "tvout.h"
#include "sram.h"
#include "text.h"
#include "joystick.h"
#include "tone.h"

//#define caddr(b1,b2) ((((b1&0xf)<<8)+b2)<<1)
#define caddr(b1,b2)  ((((b1<<8)|b2)<<1)&0xfff)
#define rx(b1)  (b1&0xf)
#define ry(b2)  (b2>>4)

// état de la machine virtuelle
static vm_state_t vms;

// stockage temporaire sprite
static uint8_t block[32];


void print_vms(const char *msg){
	cls();
	select_font(FONT_ASCII);
	prt_pstr(msg);
	prt_pstr(PSTR("PC:"));
	print_hex(vms.pc-2,4);
	print_hex(vms.b1,2);
	print_hex(vms.b2,2);
	new_line();
	prt_pstr(PSTR("I:"));
	print_hex(vms.ix,4);
	prt_pstr(PSTR(" SP:"));
	print_hex(vms.sp,2);
	new_line();
	prt_pstr(PSTR("var[]:"));
	for (int i=0;i<16;i++){
		print_hex(vms.var[i],2);
	}
	new_line();
/*	
	prt_pstr(PSTR("rpl[]:"));
	for (int i=0;i<16;i++){
		print_hex(vms.rpl[i++],2);
	}
*/	
	prompt_btn();
}

#define VM_DECODER 1
// machine virtuelle SCHIP+
uint8_t schipp(){
	uint8_t x,y,n;
#if VM_DECODER!=1
	uint16_t code;
#endif	
	vms.pc=CODE_BASE_ADDR;
	vms.sp=0;
	vms.ix=0;
 	while (1){
		if (joystick_break()) return CHIP_EXIT_OK;
		vms.opcode=sram_read_word(vms.pc);
		vms.pc+=2;
		x=rx(vms.b1);
		y=ry(vms.b2);
#if VM_DECODER==1
	    switch (vms.b1>>4){ //décodeur d'instruction modèle 1
		case 0:
			if ((vms.b2&0xf0)==0xc0){
				scroll_down(vms.b2&0xf);
			}else if ((vms.b2&0xf0)==0xd0){
				scroll_up(vms.b2&0xf);				
			}else switch(vms.b2){
				case 0xe0: // 00E0, CLS   ;efface l'écran
					cls();
					break;
				case 0xe1:
				    screen_save();
					break;
				case 0xe2:
				    screen_restore();
					break;	
				case 0xee: // 00EE, RET   ;sortie de sous-routine
					vms.pc=vms.stack[vms.sp--];
					break;
				case 0xfb: // 00FB, SCR   ;glisse l'affichage vers la droite de 4 pixels
					chip_scroll_right();
					break;
				case 0xfc: // 00FC, SCL   ;glisse l'affichage vers la gauche de 4 pixels
					chip_scroll_left();
					break;
				case 0xfd:// 00FD, EXIT   ;sortie de l'interpréteur.
					return CHIP_EXIT_OK;
				case 0xfe: //00FE,  LOW  ; passe en mode graphique 64x32
					break; // ignore ce code
				case 0xff:  //00FF, HIGH  ; passe en mode graphique 128x64
					break; // ignore ce code
				default:
					return CHIP_BAD_OPCODE;
			}//switch(b2)
			break;
		case 0x1: // 1NNN JP label  ;saut vers 'label'  adresse=2*NNN
			vms.pc=caddr(vms.b1,vms.b2);
			break;
		case 0x2: // 2NNN  CALL label  ; appelle la sous-routine 'label' adresse=2*NNN
			vms.stack[++vms.sp]=vms.pc;
			vms.pc=caddr(vms.b1,vms.b2);
			break;
		case 0x3: // 3XKK   SE VX, KK  ;saute l'instruction suivante si VX == KK
			if (vms.var[x]==vms.b2) vms.pc+=2;
			break;
		case 0x4: // 4XKK  SNE VX,VY  ;Saute l'instruction suivante si VX <> KK
			if (vms.var[x]!=vms.b2)vms.pc+=2;
			break;
		case 0x5: // 5XY0  SE VX,VY   ;Saute l'instruction suivante si VX == VY
			if (vms.var[x]==vms.var[y]) vms.pc+=2;
			break;
		case 0x6: // 6XKK   LD VX,KK  ; VX := KK
			vms.var[x]=vms.b2;
			break;
		case 0x7: // 7XKK   ADD VX,KK  ; VX := VX + KK
			vms.var[x]+=vms.b2;
			break;
		case 0x8: 
			switch(vms.b2&0xf){
			case 0: // 8XY0   LD VX, VY  ; VX := VY
				vms.var[x]=vms.var[y];
				break;
			case 1: // 8XY1  OR VX, VY  ; VX := VX OR VY
				vms.var[x]|=vms.var[y];
				break;
			case 0x2: // 8XY2  AND VX,VY  ; VX := VX AND VY
				vms.var[x]&=vms.var[y];
				break;
			case 0x3: // 8XY3  XOR VX,VY  ; VX := VX XOR VY
				vms.var[x]^=vms.var[y];
				break;
			case 0x4: // 8XY4  ADD VX,VY  ; VX := VX + VY, VF := carry
				n=(vms.var[x]+vms.var[y])>255;
				vms.var[x]+=vms.var[y];
				vms.var[15]=n;
				break;
			case 0x5: // 8XY5  SUB VX,VY  ; VX := VX - VY, VF := not borrow
				n=vms.var[x]>=vms.var[y];
				vms.var[x]-=vms.var[y];
				vms.var[15]=n;
				break;
			case 0x6: // 8XY6  SHR VX  ; VX := VX shr 1, VF := carry
				n=(vms.var[x]&1u);
				vms.var[x]>>=1;
				vms.var[15]=n;
				break;
			case 0x7: // 8XY7  SUBN VX,VY  ; VX := VY - VX, VF := not borrow
				n=vms.var[y]>=vms.var[x];
				vms.var[x]=vms.var[y]-vms.var[x];
				vms.var[15]=n;
				break;
			case 0xe: // 8XYE  SHL VX  ; VX := VX shl 1, VF := carry
				n=(vms.var[x]&128)>>7;
				vms.var[x]<<=1;
				vms.var[15]=n;
				break;
			default:
				return CHIP_BAD_OPCODE;
			}//switch(vms.b2&0xf)
			break;
		case 0x9:
			switch (vms.b2&0xf){
			case 0x0: // 9XY0  SNE VX,VY  ; Saute l'instruction suivante si VX <> VY
				if (vms.var[x]!=vms.var[y]) vms.pc+=2;
				break;
			case 0x1: // 9XY1  TONE VX, VY ; joue une note de la gamme tempérée. VX=note, VY=durée
				key_tone(vms.var[x],vms.var[y],false);
				break;
			case 0x2: // 9XY2  PRT VX, VY ; imprime le texte pointé par I. I est incrémenté. position VX, VY
				select_font(FONT_ASCII);
				set_cursor(vms.var[x],vms.var[y]);
				n=sram_read_byte(vms.ix++);
				while (n){
					put_char(n);
					n=sram_read_byte(vms.ix++);
				}
				break;
			case 0x3: // 9XY3 PIXI VX, VY  ; inverse le pixel à la position VX,VY
				plot(vms.var[x],vms.var[y],INVERT);
				break;
			case 0x4: // 9NN4  NOISE NN ; bruit blanc durée NN*frame
				noise((x<<4)+y);
				break;
			case 0x5: // 9XY5 TONE VX, VY, WAIT ; joue une note attend la fin avant de poursuivre. VX=note, VY=durée
				key_tone(vms.var[x],vms.var[y],true);
				break;
			case 0x6: // 9X06, PUSH VX  ; empile le contenu de VX
				vms.stack[++vms.sp]=vms.var[x];
				break;
			case 0x7: // 9X07, POP VX  ; transfert le sommet de la pile dans VX
				vms.var[x]=vms.stack[vms.sp--];
				break;
			case 0x8: // 9X08, SCRX  ;  VX=HRES nombre de pixels en largeur d'écran.
				vms.var[x]=HRES;
				break;
			case 0x9: // 9X09, SCRY  ; VX=VRES  nombre de pixels en hauteur d'écran.
				vms.var[x]=VRES;
				break;
			case 0xA: // 9XNA, BSET VX,N  ; met à 1 le bit N de VX
			    vms.var[x] |= (1<<(y&0x7));
			    break;
		    case 0xB: // 9XNB  BCLR VX,N  ; met à 0 le bit N de VX
			    vms.var[x] &= ~(1<<(y&0x7));
			    break;
			case 0xC: // 9XNC  BINV VX,N  ; inverse le bit N de VX
   			    vms.var[x] ^= (1<<(y&0x7));
				break;
			case 0xD: // 9XND  BTSS VX,N  ; saute l'instruction suivante si le bit N de VX==1
			    if (vms.var[x]&(1<<(y&0x7))) vms.pc+=2;
				break;
			case 0xE: // 9XNE  BTSC VX,N  ; saute l'instruction suivante si le bit N de VX==0
			    if (!(vms.var[x]&(1<<(y&0x7)))) vms.pc+=2;
				break;
			case 0xF: // 9XYF GPIX,  VF=pixel((vx),(vy))
			    vms.var[15]=get_pixel(x,y);
				break;  	
			default:
				return CHIP_BAD_OPCODE;
			}//switch(vms.b2&0xf)
			break;
		case 0xa: // ANNN    LD I, NNN  ; I := 2*NNN
			vms.ix=caddr(vms.b1,vms.b2);  // adressse de 13 bits toujours paire
			vms.src_mem=RAM_MEM;
			break;
		case 0xb: // BNNN     JP V0, NNN  ;  saut à 2*(NNN+V0)
			vms.pc=(vms.var[0]<<1)+caddr(vms.b1,vms.b2);
			break;
		case 0xc: //CXKK  RND VX,KK  ; VX=random_number&KK
			vms.var[x]=rand()&vms.b2;
			break;
		case 0xd: //DXYN DRW VX,VY   ; dessine un sprite à la position indiquée par vx,vy
			n=vms.b2&0xf;
			if (!n){
				sram_load_block(vms.ix,32,block);
				vms.var[15]=put_big_sprite((int8_t)vms.var[x],(int8_t)vms.var[y],(const uint8_t*)block);
				}else{
				if (vms.src_mem==FLASH_MEM){
					vms.var[15]=put_sprite((int8_t)vms.var[x],(int8_t)vms.var[y],n,(const uint8_t *)vms.ix,FLASH_MEM);
					}else{
					sram_load_block(vms.ix,n,block);
					vms.var[15]=put_sprite((int8_t)vms.var[x],(int8_t)vms.var[y],n,(const uint8_t*)block,RAM_MEM);
				}
			}
			break;
		case 0xe:
				switch(vms.b2){
				case 0x9e: //EX9E, SKP VX   ; saute l'instruction suivante si le bouton indiqué par VX est enfoncée
					if (joystick_btn_down(vms.var[x])) vms.pc+=2;
					break;
				case 0xa1: //EXA1, SKNP VX  ; saute l'instruction suivante si la boutin indiqué par VX n'est pas enfoncée
					if (!joystick_btn_down(vms.var[x])) vms.pc+=2;
					break;
				default:
					return CHIP_BAD_OPCODE;
				}//switch(vms.b2)
				break;
		case 0xf:
			switch(vms.b2){
			case 0x07: // FX07  LD VX, DT   VX := delay_cntr
				vms.var[x]=frame_delay;
				break;
			case 0x0a: // FX0A  LD VX, K  ; attend qu'une touche soit enfoncée et met sa valeur dans VX
				vms.var[x]=joystick_wait_any();
				break;
			case 0x15: // FX15  LD DT, VX  ; démarre la minuterie delay_cntr avec la valeur indiquée par VX
				frame_delay=vms.var[x];
				break;
			case 0x18: // FX18  LD ST, VX  ; beep d'une durée VX (multiple de 16.7 msec)
				tone(523,vms.var[x]);
				break;
			case 0x1e: // FX1E  ADD I, VX  ;  I := I + VX
				vms.ix += vms.var[x];
				break;
			case 0x29: // FX29  LD F,VX   ; fait pointé I vers le caractère indiqué par VX dans la police FONT_SHEX
				vms.ix=(int16_t)font_hex_4x6+vms.var[x]*SHEX_HEIGHT;
				select_font(FONT_SHEX);
				vms.src_mem=FLASH_MEM;
				break;
			case 0x30: // FX30 LD LF,VX  ;fait pointé I vers le caractère indiqué par VX dans la police FONT_LHEX
				vms.ix=(int16_t)font_hex_8x10+vms.var[x]*LHEX_HEIGHT;
				select_font(FONT_LHEX);
				vms.src_mem=FLASH_MEM;
				break;
			case 0x33: // FX33 LD B, VX  ;  met la représentation BCD de VX dans M[I]..M[I+2]
				n=vms.var[x];
				block[2]=n%10;
				n /=10;
				block[1]=n%10;
				block[0]=n/10;
				sram_store_block(vms.ix,3,block);
				break;
			case 0x55: // FX55  LD [I], VX  ; Sauvegarde les registres V0..VX dans la mémoire SRAM à l'adresse M[I]...
				sram_store_block(vms.ix,x+1,vms.var);
				break;
			case 0x65: // FX65 LD VX,[I]  ;charge les registres V0..VX à partir de la mémoire SRAM à l'adresse M[I]
				sram_load_block(vms.ix,x+1,vms.var);
				break;
			case 0x75: // FX75 LD R,VX  ; sauvegarde les registres V0..VX dans la banque R
				for (n=0;n<=x;n++){
					vms.rpl[n]=vms.var[n];
				}
				break;
			case 0x85: // FX85 LD VX, R  ;charge les registres V0..VX à partir de la banque R
				for (n=0;n<=x;n++){
					vms.var[n]=vms.rpl[n];
				}
				break;
			default:
				return CHIP_BAD_OPCODE;
				
			}//switch(vms.b2)
			break;	
		}//switch (vms.b1>>4)
#else
		// décodeur d'instruction modèle 2
		code=(vms.b1&0xf0)<<4;
		switch (code){
			case 0x000:
				if ((vms.b2&0xf0)==0xc0){
					 code=0xc0;
			    }else if ((vms.b2&0xf0)==0xd0){
					 code=0xd0;
			    } else code=vms.b2;
				break;
			case 0xe00:
			case 0xf00:
				code |= vms.b2;
				break;
			case 0x800:
			case 0x900:
				code |= vms.b2&0xf;
				break;
		}
		// exécution de l'instruction
		switch(code){
			case 0xc0: // 00CN, SCN   ;glisse l'affichage N lignes vers le bas
				scroll_down(vms.b2&0xf);
				break;
			case 0xd0: // 00DN, SCU   ;glisse l'affichage N lignes vers le haut
			    scroll_up(vms.b2&0xf);
				break;	
			case 0xe0: // 00E0, CLS   ;efface l'écran
				cls();
				break;
			case 0xee: // 00EE, RET   ;sortie de sous-routine
				vms.pc=vms.stack[vms.sp--];
				break;
			case 0xfb: // 00FB, SCR   ;glisse l'affichage vers la droite de 4 pixels
				chip_scroll_right();
				break;
			case 0xfc: // 00FC, SCL   ;glisse l'affichage vers la gauche de 4 pixels
				chip_scroll_left();
				break;
			case 0xfd:// 00FD, EXIT   ;sortie de l'interpréteur.
				return CHIP_EXIT_OK;
			case 0xfe: //00FE,  LOW  ; passe en mode graphique 64x32
				break; // ignore ce code
			case 0xff:  //00FF, HIGH  ; passe en mode graphique 128x64
				break; // ignore ce code
			case 0x100: // 1NNN JP label  ;saut vers 'label'  adresse=2*NNN
				vms.pc=caddr(vms.b1,vms.b2);
				break;
			case 0x200: // 2NNN  CALL label  ; appelle la sous-routine 'label' adresse=2*NNN
				vms.stack[++vms.sp]=vms.pc;
				vms.pc=caddr(vms.b1,vms.b2);
				break;
			case 0x300: // 3XKK   SE VX, KK  ;saute l'instruction suivante si VX == KK
				if (vms.var[x]==vms.b2) vms.pc+=2;
				break;
			case 0x400: // 4XKK  SNE VX,VY  ;Saute l'instruction suivante si VX <> KK
				if (vms.var[x]!=vms.b2)vms.pc+=2;
				break;
			case 0x500: // 5XY0  SE VX,VY   ;Saute l'instruction suivante si VX == VY
				if (vms.var[x]==vms.var[y]) vms.pc+=2;
				break;
			case 0x600: // 6XKK   LD VX,KK  ; VX := KK
				vms.var[x]=vms.b2;
				break;
			case 0x700: // 7XKK   ADD VX,KK  ; VX := VX + KK
				vms.var[x]+=vms.b2;
				break;
			case 0x800: // 8XY0   LD VX, VY  ; VX := VY
				vms.var[x]=vms.var[y];
				break;
			case 0x801: // 8XY1  OR VX, VY  ; VX := VX OR VY
				vms.var[x]|=vms.var[y];
				break;
			case 0x802: // 8XY2  AND VX,VY  ; VX := VX AND VY
				vms.var[x]&=vms.var[y];
				break;
			case 0x803: // 8XY3  XOR VX,VY  ; VX := VX XOR VY
				vms.var[x]^=vms.var[y];
				break;
			case 0x804: // 8XY4  ADD VX,VY  ; VX := VX + VY, VF := carry
				n=(vms.var[x]+vms.var[y])>255;
				vms.var[x]+=vms.var[y];
				vms.var[15]=n;
				break;
			case 0x805: // 8XY5  SUB VX,VY  ; VX := VX - VY, VF := not borrow
				n=vms.var[x]>=vms.var[y];
				vms.var[x]-=vms.var[y];
				vms.var[15]=n;
				break;
			case 0x806: // 8XY6  SHR VX  ; VX := VX shr 1, VF := carry
				n=(vms.var[x]&1u);
				vms.var[x]>>=1;
				vms.var[15]=n;
				break;
			case 0x807: // 8XY7  SUBN VX,VY  ; VX := VY - VX, VF := not borrow
				n=vms.var[y]>=vms.var[x];
				vms.var[x]=vms.var[y]-vms.var[x];
				vms.var[15]=n;
				break;
			case 0x80e: // 8XYE  SHL VX  ; VX := VX shl 1, VF := carry
				n=(vms.var[x]&128)>>7;
				vms.var[x]<<=1;
				vms.var[15]=n;
				break;
			case 0x900: // 9XY0  SNE VX,VY  ; Saute l'instruction suivante si VX <> VY
				if (vms.var[x]!=vms.var[y]) vms.pc+=2;
				break;
			case 0x901: // 9XY1  TONE VX, VY ; joue une note de la gamme tempérée. VX=note, VY=durée
				key_tone(vms.var[x],vms.var[y],false);
				break;
			case 0x902: // 9XY2  PRT VX, VY ; imprime le texte pointé par I. I est incrémenté. position VX, VY
				select_font(FONT_ASCII);
				set_cursor(vms.var[x],vms.var[y]);
				n=sram_read_byte(vms.ix++);
				while (n){
					put_char(n);
					n=sram_read_byte(vms.ix++);
				}
				break;
			case 0x903: // 9XY3 PIXI VX, VY  ; inverse le pixel à la position VX,VY
				plot(vms.var[x],vms.var[y],INVERT);
				break;
			case 0x904: // 9NN4  NOISE NN ; bruit blanc durée NN*frame
			    noise((x<<4)+y);
			    break;	
			case 0x905: // 9XY5 TONE VX, VY, WAIT ; joue une note attend la fin avant de poursuivre. VX=note, VY=durée
				key_tone(vms.var[x],vms.var[y],true);
				break;
			case 0x906: // 9X06, PUSH VX  ; empile le contenu de VX
			    vms.stack[++vms.sp]=vms.var[x];
				break;	
			case 0x907: // 9X07, POP VX  ; transfert le sommet de la pile dans VX
			    vms.var[x]=vms.stack[vms.sp--];
				break;	
			case 0x908: // 9X08, SCRX  ;  VX=HRES nombre de pixels en largeur d'écran.
				vms.var[x]=HRES;
				break;
			case 0x909: // 9X09, SCRY  ; VX=VRES  nombre de pixels en hauteur d'écran.
				vms.var[x]=VRES;
				break;
			case 0xa00: // ANNN    LD I, NNN  ; I := 2*NNN
				vms.ix=caddr(vms.b1,vms.b2);  // adressse de 13 bits toujours paire
				vms.src_mem=RAM_MEM;
				break;
			case 0xb00: // BNNN     JP V0, NNN  ;  saut à 2*(NNN+V0) 
				vms.pc=(vms.var[0]<<1)+caddr(vms.b1,vms.b2);
				break;
			case 0xc00: //CXKK  RND VX,KK  ; VX=random_number&KK
				vms.var[x]=rand()&vms.b2;
				break;
			case 0xd00: //DXYN DRW VX,VY   ; dessine un sprite à la position indiquée par vx,vy
				n=vms.b2&0xf;
				if (!n){
					sram_load_block(vms.ix,32,block);
					vms.var[15]=put_big_sprite((int8_t)vms.var[x],(int8_t)vms.var[y],(const uint8_t*)block);
				}else{
					if (vms.src_mem==FLASH_MEM){
						vms.var[15]=put_sprite((int8_t)vms.var[x],(int8_t)vms.var[y],n,(const uint8_t *)vms.ix,FLASH_MEM);
					}else{
						sram_load_block(vms.ix,n,block);
						vms.var[15]=put_sprite((int8_t)vms.var[x],(int8_t)vms.var[y],n,(const uint8_t*)block,RAM_MEM);
					}
				}
				break;
			case 0xe9e: //EX9E, SKP VX   ; saute l'instruction suivante si le bouton indiqué par VX est enfoncée
				if (joystick_btn_down(vms.var[x])) vms.pc+=2;
				break;
			case 0xea1: //EXA1, SKNP VX  ; saute l'instruction suivante si la boutin indiqué par VX n'est pas enfoncée
				if (!joystick_btn_down(vms.var[x])) vms.pc+=2;
				break;
			case 0xf07: // FX07  LD VX, DT   VX := delay_cntr
				vms.var[x]=frame_delay;
				break;
			case 0xf0a: // FX0A  LD VX, K  ; attend qu'une touche soit enfoncée et met sa valeur dans VX
				vms.var[x]=joystick_wait_any();
				break;
			case 0xf15: // FX15  LD DT, VX  ; démarre la minuterie delay_cntr avec la valeur indiquée par VX
				frame_delay=vms.var[x];
				break;
			case 0xf18: // FX18  LD ST, VX  ; beep d'une durée VX (multiple de 16.7 msec)
				tone(523,vms.var[x]);
				break;
			case 0xf1e: // FX1E  ADD I, VX  ;  I := I + VX
				vms.ix += vms.var[x];
				break;
			case 0xf29: // FX29  LD F,VX   ; fait pointé I vers le caractère indiqué par VX dans la police FONT_SHEX
				vms.ix=(int16_t)font_hex_4x6+vms.var[x&0xf]*SHEX_HEIGHT;
				select_font(FONT_SHEX);
				vms.src_mem=FLASH_MEM;
				break;
			case 0xf30: // FX30 LD LF,VX  ;fait pointé I vers le caractère indiqué par VX dans la police FONT_LHEX
				vms.ix=(int16_t)font_hex_8x10+vms.var[x&0xf]*LHEX_HEIGHT;
				select_font(FONT_LHEX);
				vms.src_mem=FLASH_MEM;
				break;
			case 0xf33: // FX33 LD B, VX  ;  met la représentation BCD de VX dans M[I]..M[I+2]
				n=vms.var[x];
				block[2]=n%10;
				n /=10;
				block[1]=n%10;
				block[0]=n/10;
				sram_store_block(vms.ix,3,block);
				break;
			case 0xf55: // FX55  LD [I], VX  ; Sauvegarde les registres V0..VX dans la mémoire SRAM à l'adresse M[I]...
				sram_store_block(vms.ix,x+1,vms.var);
				break;
			case 0xf65: // FX65 LD VX,[I]  ;charge les registres V0..VX à partir de la mémoire SRAM à l'adresse M[I]
				sram_load_block(vms.ix,x+1,vms.var);
				break;
			case 0xf75: // FX75 LD R,VX  ; sauvegarde les registres V0..VX dans la banque R
				for (n=0;n<=x;n++){
					vms.rpl[n]=vms.var[n];
				}
				break;
			case 0xf85: // FX85 LD VX, R  ;charge les registres V0..VX à partir de la banque R
				for (n=0;n<=x;n++){
					vms.var[n]=vms.rpl[n];
				}
				break;
			default:
				return CHIP_BAD_OPCODE;
		}//switch
#endif		
	}//while(1)
}//schipp()
