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
*  nom: cc-dasm.c
*  Description: déassembleur pour programme CHIPcon (supporte programme SCHIP)
*/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>


#define caddr(b1,b2) ((((b1&0xf)<<8)+b2)-org)
#define r1(b1)  (b1&0xf)
#define r2(b2)  ((b2&0xf0)>>4)


#define NOT_DONE (0)
#define DONE (1)

typedef struct code_target{
	unsigned short addr;
	unsigned short done;
}code_target_t;

typedef struct i_target{
	unsigned short addr;
	unsigned short size;
}data_t;


#define CODE_SPACE (4096)
 

data_t  data[100];
int dx=0;
unsigned short org=512;

unsigned char bytecode[CODE_SPACE];
unsigned char decoded[CODE_SPACE];

char *dasm[CODE_SPACE];

unsigned char registers[16];

#define NOT_SKIP (0)
#define SKIP (1)
#define LDI  (2)

int previous=NOT_SKIP;

int latest=0;

code_target_t  target[256]; // call and jumps targets
int  tx=0;

int search_for_data(int addr){
	int i;
	for(i=0;i<dx;i++){
		if (data[i].addr==addr) break;
	}
	return i;
}

int search_for_target(int addr){
	int i;
	for(i=0;i<tx;i++){
		if (target[i].addr==addr) break;
	}
	return i;
}

int next_target(){
	int i,next_addr;
	next_addr=0;
	for (i=0;i<tx;i++){
		if (!target[i].done){
			next_addr=target[i].addr;
			target[i].done=DONE;
			break;
		}			
	}
	return next_addr;
}

void file_not_found(char *name){
	printf("%s file not found\n",name);
	exit(0);
}//f();

int load_bytecode(char *name){
	FILE *fp;
	unsigned size;
	memset(bytecode,0,CODE_SPACE);
	memset(dasm,0,CODE_SPACE);
	memset(decoded,0,CODE_SPACE);
	fp=fopen(name,"rb");
	if (!fp) file_not_found(name);
	fseek(fp,0L,SEEK_END);
	size=ftell(fp);
	fseek(fp,0L,SEEK_SET);
	fread(bytecode,1,size,fp);
	fclose(fp);
	printf("%s size: %u\n",name,size);
	return size;
}

void usage(){
	puts("de-assemmble [pvp] PICVisionPortable binary file.");
	puts("USAGE: pvpdasm pvp_file asm_file");
	puts("pvp source code is pvp binary.");
	puts("pvp_file is PICVIsionPortable binary.");
	puts("asm_file  is name of output file.");
	exit(EXIT_FAILURE);
}


void alignement_warning(int addr){
	unsigned char b1,b2;
	unsigned short t;
	printf("WARNING:\nAt PC address 0x%03X a call or jp is made at odd address:\n",addr);
	b1=bytecode[addr++];
	b2=bytecode[addr];
	t=((b1&0xf)<<8)+b2;
	if ((b1&0xf0)==1){
		printf("#%03X\tJP #%03X\n",addr,t);
	} 
	else{
		printf("#%03X\tCALL #%03X\n",addr,t);
	}
}//f()


int main(int argc, char *argv[]){
	FILE  *out;
	unsigned char b1,b2;
	int size, i=0,j, ix;
	unsigned short pc=0;
	char *line, *tx_line, unknown=0;
	
	if (argc<3) usage();
	if (strcmp(argv[1],"pvp")==0){
		org=0;
		size=load_bytecode(argv[2]);
		out=fopen(argv[3],"w");
	}else{
		size=load_bytecode(argv[1]);
		out=fopen(argv[2],"w");
	}
	do {
		line=malloc(256);
		dasm[pc]=line;
		*line=0;
		i=search_for_target(pc);
		if (i<tx){
			sprintf(line,"code_%03X:\n",target[i].addr);
		}
		b1=bytecode[pc];
		decoded[pc++]=1;
		b2=bytecode[pc];
		decoded[pc++]=1;
		if ((pc-2)>latest) latest=pc-2;
		sprintf(line+strlen(line),"\t");
		switch((b1&0xf0)>>4){
		case 0:
			if ((b2&0xf0)==0xc0){ // 00CN, (modes schip et xchip seulement) glisse l'affichage N lignes vers le bas  
				sprintf(line+strlen(line),"SCD %d\n",b2&0xf);
				previous=NOT_SKIP;
			}else{
				switch (b2){
				case 0xE0:  // 00E0, efface l'écran
					sprintf(line+strlen(line),"CLS\n");
					previous=NOT_SKIP;
					break;
				case 0xEE: // 00EE, sortie de sous-routine
					sprintf(line+strlen(line), "RET\n");
					if (previous!=SKIP) pc=size;
					previous=NOT_SKIP;
					break;
				case 0xFB: // 00FB, (modes schip et xchip seulement) glisse l'affichage vers la droite de 4 pixels
					sprintf(line+strlen(line),"SCR\n");
					previous=NOT_SKIP;
					break;
				case 0xFC: // 00FC, (modes schip et xchip seulement) glisse l'affichage vers la gauche de 4 pixels
					sprintf(line+strlen(line),"SCL\n");
					previous=NOT_SKIP;
					break;
				case 0xFD:// 00FD, (modes schip et xchip seulement) sortie de l'interpréteur.
					sprintf(line+strlen(line),"EXIT\n");
					if (previous!=SKIP) pc=size;
					previous=NOT_SKIP;
					break;
				case 0xFE: // 00FE  revient au mode CHIP-8
					sprintf(line+strlen(line),"LOW\n");
					previous=NOT_SKIP;
					break;
				case 0xFF: // 00FF passe en mode SCHIP
					sprintf(line+strlen(line),"HIGH\n");
					previous=NOT_SKIP;
					break;
				default:
					unknown=1;
					previous=NOT_SKIP;
					break;
				}//switch
			}
			break;
		case 1: // 1NNN saut vers l'adresse NNN
			i=search_for_target(caddr(b1,b2));
			if (i==tx){
				target[tx].addr=caddr(b1,b2);
				if (decoded[caddr(b1,b2)]){
					target[tx].done=DONE;
					if (strstr(dasm[caddr(b1,b2)],"code_")!=dasm[caddr(b1,b2)]){
						tx_line=malloc(256);
						sprintf(tx_line,"code_%03X:\n",target[tx].addr);
						strcat(tx_line, dasm[caddr(b1,b2)]);
						free(dasm[caddr(b1,b2)]);
						dasm[caddr(b1,b2)]=tx_line;
						if (caddr(b1,b2)==pc-2) line=tx_line;
					}
				}else{
					target[tx].done=NOT_DONE;
				}
				tx++;
			}
			sprintf(line+strlen(line),"JP code_%03X\n",target[i].addr);
			if (previous!=SKIP) pc=size;
			previous=NOT_SKIP;
			break;
		case 2: // 2NNN  appelle la sous-routine à l'adresse NNN
			i=search_for_target(caddr(b1,b2));
			if (i==tx){ 
				target[tx].addr=caddr(b1,b2); 
				if (decoded[caddr(b1,b2)]){
					target[tx].done=DONE;
					if (strstr(dasm[caddr(b1,b2)],"code_")!=dasm[caddr(b1,b2)]){
						tx_line=malloc(256);
						sprintf(tx_line,"code_%03X:\n",target[i].addr);
						strcat(tx_line, dasm[caddr(b1,b2)]);
						free(dasm[caddr(b1,b2)]);
						dasm[caddr(b1,b2)]=tx_line;
					}
				}else{
					target[tx].done=NOT_DONE;
				}
				tx++;
			}
			sprintf(line+strlen(line),"CALL code_%03X\n",target[i].addr);
			previous=NOT_SKIP;
			break;
		case 3: // 3XKK     saute l'instruction suivante si VX == KK 
			sprintf(line+strlen(line),"SE V%X, %d\n",r1(b1),b2);
			previous=SKIP;
			break;
		case 4: // 4XKK     Saute l'instruction suivante si VX <> KK 
			sprintf(line+strlen(line),"SNE V%X, %d\n",r1(b1),b2);
			previous=SKIP;
			break;
		case 5: // 5XY0     Saute l'instruction suivante si VX == VY
			sprintf(line+strlen(line),"SE V%X, V%X\n",r1(b1),r2(b2));
			previous=SKIP;
			break;
		case 6: // 6XKK     VX := KK 
			sprintf(line+strlen(line),"LD V%X, %d\n", r1(b1),b2);
			previous=NOT_SKIP;
			break;
		case 7: // 7XKK     VX := VX + KK
			sprintf(line+strlen(line),"ADD V%X, %d\n", r1(b1),b2);
			previous=NOT_SKIP;
			break;
		case 8: 
			switch(b2&0xf){
			case 0: // 8XY0     VX := VY
				sprintf(line+strlen(line),"LD V%X, V%X\n",r1(b1),r2(b2));
				break;
			case 1: // 8XY1     VX := VX or VY
				sprintf(line+strlen(line),"OR V%X, V%X\n", r1(b1),r2(b2));
				break;
			case 2: // 8XY2     VX := VX and VY
				sprintf(line+strlen(line),"AND V%X, V%X\n", r1(b1),r2(b2));
				break;
			case 3: // 8XY3     VX := VX xor VY
				sprintf(line+strlen(line),"XOR V%X, V%X\n", r1(b1),r2(b2));
				break;
			case 4: // 8XY4     VX := VX + VY, VF := carry 
				sprintf(line+strlen(line),"ADD V%X, V%X\n", r1(b1),r2(b2));
				break;
			case 5: // 8XY5     VX := VX - VY, VF := not borrow 
				sprintf(line+strlen(line),"SUB V%X, V%X\n", r1(b1),r2(b2));
				break;
			case 6: // 8XY6     VX := VX shr 1, VF := carry 
				sprintf(line+strlen(line),"SHR V%X\n",r1(b1));
				break;
			case 7: // 8XY7     VX := VY - VX, VF := not borrow
				sprintf(line+strlen(line),"SUBN V%X, V%X\n", r1(b1),r2(b2));
				break;
			case 0xe: // 8XYE     VX := VX shl 1, VF := carry 
				sprintf(line+strlen(line),"SHL V%X\n",r1(b1));
				break;
			default:
				unknown=1;
				break;
			}//switch
			previous=NOT_SKIP;
			break;
		case 9: // 9XY0     Saute l'instruction suivante si VX <> VY
			switch(b2&0xf){
			case 0:
				sprintf(line+strlen(line),"SNE  V%X, V%X\n",r1(b1),r2(b2));
				previous=SKIP;
				break;
			case 1:
				sprintf(line+strlen(line),"TONE V%X,V%X, 1\n",r1(b1),r2(b2));
				previous=NOT_SKIP;
				break;
			case 2:
				sprintf(line+strlen(line),"PRT V%X,V%X\n",r1(b1),r2(b2));
				previous=NOT_SKIP;
				break;
			case 3:
				sprintf(line+strlen(line),"PIXI V%X,V%X\n",r1(b1),r2(b2));
				previous=NOT_SKIP;
				break;
			case 4:
				sprintf(line+strlen(line),"NOISE %u\n",(b1&15)*16+(b2&0xf0)>>4);
				break;
			case 5:
				sprintf(line+strlen(line),"TONE V%X,V%X,WAIT\n",r1(b1),r2(b2));
				previous=NOT_SKIP;
				break;
			case 6:
				sprintf(line+strlen(line),"TONE V%X,V%X, 2\n",r1(b1),r2(b2));
				previous=NOT_SKIP;
				break;
			case 7:
				sprintf(line+strlen(line),"TONE [I]\n");
				previous=NOT_SKIP;
				break;
			}
			break;
		case 0xA: // ANNN     I := NNN 
			ix=caddr(b1,b2);
			if ((i=search_for_data(ix))==dx){data[dx].addr=ix;data[dx++].size=0;}
			sprintf(line+strlen(line),"LD I, data_%03X\n",data[i].addr);
			previous=LDI;
			break;
		case 0xB: // BNNN     saut à NNN+V0
			sprintf(line+strlen(line),"JP V0, #%03X\n",caddr(b1,b2));
			previous=NOT_SKIP;
			break;
		case 0xC: //CXKK VX=random_number&KK
			sprintf(line+strlen(line),"RND V%X, #%02X\n",r1(b1),b2);
			previous=NOT_SKIP;
			break;
		case 0xD: //DXYN dessine le sprite pointé par I
			sprintf(line+strlen(line),"DRW V%X, V%X, %d\n",r1(b1),r2(b2),b2&0xf);
			if (previous==LDI){
				if ((i=search_for_data(ix))<dx){
					data[i].size=b2&0xf;
				}else{
					data[dx].addr=ix;
					data[dx++].size=b2&0xf;
				}
			}
			previous=NOT_SKIP;
			break;
		case 0xE:
			switch(b2){
			case 0x9e: //EX9E, saute l'instruction suivante si la touche VX est enfoncée
				sprintf(line+strlen(line),"SKP V%X\n", r1(b1));
				previous=SKIP;
				break;
			case 0xa1: //EXA1, saute l'instruction suivante si la touche VX n'est pas enfoncée
				sprintf(line+strlen(line),"SKNP V%X\n",r1(b1));
				previous=SKIP;
				break;
			default:
				unknown=1;
				previous=NOT_SKIP;
				break;
			}//swtich
			break;
		case 0xF:
			switch(b2){
			case 0x07: // FX07     VX := DELAY_TIMER
				sprintf(line+strlen(line),"LD V%X, DT\n", r1(b1));
				break;
			case 0x0a: // FX0A     attend qu'une touche soit enfoncée et met sa valeur dans VX
				sprintf(line+strlen(line),"LD V%X, K\n",r1(b1));
				break;
			case 0x15: // FX15     démarre la minuterie DELAY_TIMER avec la valeur de délais VX*16 
				sprintf(line+strlen(line),"LD DT, V%X\n", r1(b1));
				break;
			case 0x18: // FX18     charge sound timer avec VX
				sprintf(line+strlen(line),"LD ST, V%X\n",r1(b1));
				break;
			case 0x1e: // FX1E     ix := ix + VX 
				sprintf(line+strlen(line),"ADD I, V%X\n",r1(b1));
				break;
			case 0x29: // FX29     fait pointé ix vers le caractère VX dans la police FONT_SHEX
				sprintf(line+strlen(line),"LD F, V%X\n",r1(b1));
				break;
			case 0x30: // FX30 (schip,xchip)    fait pointé ix vers le caractère dans  VX (0..9) pour la police FONT_LHEX
				sprintf(line+strlen(line),"LD LF, V%X\n",r1(b1));
				break;
			case 0x33: // FX33     met la représentation BCD de VX dans M(ix)..M(ix+2)
			    if ((i=search_for_data(ix))<dx) data[i].size=3;	
				sprintf(line+strlen(line),"LD B, V%X\n", r1(b1));
				break;
			case 0x55: // FX55     Sauvegarde les registres V0..VX dans la mémoire SRAM à l'adresse M(ix)
				if ((i=search_for_data(ix))<dx) data[i].size=r1(b1);
				sprintf(line+strlen(line),"LD [I], V%X\n", r1(b1));
				break;
			case 0x65: // FX65     charge les registres V0..VX à partir de la mémoire SRAM à l'adresse M(ix)	
				if ((i=search_for_data(ix))<dx) data[i].size=r1(b1);
				sprintf(line+strlen(line),"LD V%X, [I]\n",r1(b1));
				break;
			case 0x75: // FX75 (modes schip et xchip seulement) sauvegarde les registres V0..VX dans rpl  (X <= 7)
				sprintf(line+strlen(line),"LD R, V%X\n",r1(b1));
				break;
			case 0x85: // FX85 (modes schip et xchip seulement) charge les registres V0..VX à partir de rpl (X <= 7)
				sprintf(line+strlen(line),"LD V%X, R\n",r1(b1),r1(b1));
				break;
			default:
				unknown=1;
				break;
			}//switch
			previous=NOT_SKIP;
			break;
		default:
			unknown=1;
			break;
		}//switch
		if (unknown){
			sprintf(line+strlen(line),".DB #%02X, #%02X  ; not opcode\n",b1,b2);
			unknown=0;
		}
		if (pc==size){
			i=next_target();
			if (i) pc=i;
		}
	} while (pc<size);
	unsigned byte_count=0;
	//decoding data lines
	for (i=0;i<size;i++){
		if (byte_count==0){
			if (!decoded[i]){
				line=malloc(256);
				*line=0;
				dasm[i]=line;
				if (search_for_data(i)<dx){
					sprintf(line+strlen(line),"\ndata_%03X:\n",i);
				}
				sprintf(line+strlen(line),"\tDB #%02X",bytecode[i]);
				byte_count++;
			}
		}else{
			if (!decoded[i]){
				//data_ix=search_for_data(i);
				if (search_for_data(i)<dx){
					sprintf(line+strlen(line),"\ndata_%03X:\n\tDB #%02X",i,bytecode[i]);
					byte_count=0;
				}else{
					sprintf(line+strlen(line),", #%02X",bytecode[i]);
				}
				byte_count++;
				if (byte_count==8){
					byte_count=0;
					sprintf(line+strlen(line),"\n");
				}
			}else{
				sprintf(line+strlen(line),"\n");
				byte_count=0;
			}
		}
	
	}
	for (i=0;i<dx;i++){
		if (data[i].addr>=size){
			line=malloc(256);
			dasm[data[i].addr]=line;
			sprintf(line,"\ndata_%03X:\n",data[i].addr);
			
		}
	}
	for (i=0;i<CODE_SPACE;i++){
		if (dasm[i])
			fputs(dasm[i],out);
	}
	
	fputs("\n",out);
	fclose(out);
	return EXIT_SUCCESS;
}

