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
*   Nom:  ccasm.c
*   Description: assembleur pour la console CHIPcon
*   auteur: Jacques Deschenes
*   Date:  2014-10-28
*   REVISIONS:
*   2015-02-16  added ORG directive
*				assembly begin at 0 instead of 512
*   2015-08-10 adapté pour CHIPcon v2
*              renommé cc2asm.exe
*              ajouté opcodes PUSH, POP, SCRX, SCRY, SCU
*              doublé espace d'adressage en divisant NNN/2 avant encodage
*              supprimé directive ORG et ajoute directive END
*/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdbool.h>


typedef struct data_node{
	char *name;
	union {
		unsigned addr;
		unsigned pc;
		unsigned value;
		char *defn;
	};
	struct data_node *next;
}node_t;

typedef enum token {eNONE,eSYMBOL,eLABEL,eNUMBER,eSTRING,eADDOP,eMULOP,
                    eCOMMA,eLPAREN,eRPAREN,eLBRACKET,eRBRACKET,eDOT} token_t;

token_t tok_id;
char tok_value[256];


node_t *label_list=NULL;
node_t *forward_list=NULL;
node_t *symbol_list=NULL;
node_t *define_list=NULL;

#define add_label(name,addr)   add_node(name,addr,label_list)
#define add_forward_ref(name,pc) add_node(name,pc,forward_list)
#define add_symbol(name,value)  add_node(name,value,symbol_list)
#define add_define(name,str) add_node(name,(unsigned)str,define_list)
#define search_label(name)   search_list(name,label_list)
#define search_ref(name)  search_list(name,forward_list)
#define search_symbol(name) search_list(name,symbol_list)
#define search_define(name) search_list(name,define_list)


FILE *bin=NULL,  // fichier binaire généré par l'assembleur
     *ppf=NULL,  // fichier optionnel généré par le pré-processeur
	 *lbl=NULL;  // fichier des étiquettes avec l'adresse.
	 

int pc; // compteur ordinal
int line_no; //no de ligne en cours d'analyse
int code_size=0; 
bool file_done=false;

#define MEM_SIZE (8192)   
unsigned char binary[MEM_SIZE];


int inp; // pointeur d'analyse ligne d'entrée
char line[256]; // contient la ligne à analyser

#define KW_COUNT (43)

const char *mnemonics[KW_COUNT]={"NOP","CLS","RET","SCR","SCL","EXIT","LOW","HIGH","SCD","JP","CALL",
						 "SHR","SHL","SKP","SKNP","SE","SNE","ADD","SUB","SUBN","OR","AND","XOR",
						 "RND","TONE","PRT","PIXI","LD","DRW","NOISE","PUSH","POP","SCRX","SCRY",
						 "SCU","BSET","BCLR","BINV","BTSS","BTSC","SAVE","RSTR","GPIX"};

typedef enum Mnemo {eNOP,eCLS,eRET,eSCR,eSCL,eEXIT,eLOW,eHIGH,eSCD,eJP,eCALL,eSHR,eSHL,eSKP,eSKNP,eSE,eSNE,eADD,
                    eSUB,eSUBN,eOR,eAND,eXOR,eRND,eTONE,ePRT,ePIXI,eLD,eDRW,eNOISE,ePUSH,ePOP,eSCRX,eSCRY,
					eSCU,eBSET,eBCLR,eBINV,eBTSS,eBTSC,eSAVE,eRSTR,eGPIX} mnemo_t;
						 
#define DIR_COUNT (7)						 
const char *directives[]={"DB","DW","ASCII","EQU","DEFN","END","ORG"};

typedef enum dir_id {eDB,eDW,eASCII,eEQU,eDEFN,eEND,eORG} directive_t;

// search word in a list 
int search_word(char *target, const char *list[], int list_count){
	int i=0;
	while (i<list_count){
		if (!strcmp(target,list[i])) break;
		i++;
	}
	return i;
	
}

bool letter(char c){
	return ((c>='A') && (c<='Z')) || ((c>='a') && (c<='z'));
}

bool digit(char c){
	return (c>='0') && (c<='9');
}

bool alnum(char c){
	return letter(c) || digit(c);
}

bool hex(char c){
	return digit(c) || ((c>='A')&&(c<='F'));
}

bool identifier(char *name){
	if (!letter(*name)) return false;
	name++;
	while (*name){
		if (!(alnum(*name) || *name=='_')) return false;
		name++;
	}
	return true;
}

bool separator(char c){
	strchr("()[]+-*/%,",c);
}

bool match_vx(char *w){
	return (*w=='V') && hex(*(w+1)); 
}


void memory_overflow(){
	printf("CHIPcon program memory overflow at line %d\n", line_no);
}



void next_token();
void parse_identifier();
unsigned get_number();
unsigned expression();


typedef enum ERROR_CODE {eSYNTAX, eALIGN, eMEMORY,eUNKNOWN,eEXPRESSION,eBADARG,
    eRANGE,eBADMNEMO,eNOTREF,eORIGIN, ePCIMPAIR, eERRNONE} error_code_t;

const char *error_msg[eERRNONE]={
"syntax error",
"alignement error",
"memory overflow",
"unknown symbol",
"bad expression",
"bad argument",
"out of range",
"bad mnemonic",
"undefined reference",
"origin can't regress",
"origin address must be even",
};

void error(error_code_t error_code){
	puts(line);
	printf("%s at line %d, position %d\n",error_msg[error_code],line_no,inp-strlen(tok_value));
	exit(EXIT_FAILURE);
}

void store_code(unsigned char b1, unsigned char b2){
	if (pc<(MEM_SIZE-1)){
		binary[pc++]=b1&0xff;
		binary[pc++]=b2&0xff;
		code_size+=2;
	}else{
		error(eMEMORY);
	}
}

//convertie une chaine hexadécimale
//en entier positif
int htoi(char *hnbr){
	unsigned int n=0;
	while (hex(*hnbr)){
		n*=16;
		n+=*hnbr<='9'?*hnbr-'0':*hnbr-'A'+10;
		hnbr++;
	}
	return n;
}

// convertie une chaine binaire
// en entier positif
int btoi(char *bnbr){
	unsigned int n=0;
	while ((*bnbr=='1')||(*bnbr=='.')||(*bnbr=='0')){
		n <<=1;
		n += *bnbr=='1';
		bnbr++;
	}
	return n;
}

//convertie un token numérique
// en entier positif
unsigned token_to_i(){
	switch(tok_value[0]){
	case '#':
		return htoi(tok_value+1);
	case '$':
		return btoi(tok_value+1);
	default:
		return atoi(tok_value);
	}
}


node_t *add_node(char *name, unsigned value, node_t *list){
	node_t *n;
	
	n=malloc(sizeof(node_t));
	n->next=NULL;
	if (list) n->next=list; else list=n;
	n->value=value;
	n->name=malloc(strlen(name)+1);
	strcpy(n->name,name);
	return n;
}

node_t *search_list(char *name, node_t *list){
	node_t *node;
	node=list;
	while (node){
		if (!strcmp(name,node->name)) break;
		node=node->next;
	}
	return node;
}

int parse_vx(){
	next_token();
	if (!(tok_id==eSYMBOL && tok_value[0]=='V' && hex(tok_value[1]))) error(eBADARG);
	return tok_value[1]<='9'?tok_value[1]-'0':tok_value[1]-'A'+10;
}

// codes sans arguments
// "NOP","CLS","RET","SCR","SCL","EXIT","LOW","HIGH","SAVE","RSTR"
void op0(mnemo_t code){
	unsigned b1,b2;
	
	b1=0;
	switch (code){
	case eNOP:
	    b2=0;
		break;
	case eCLS: // CLS
		b2=0xe0;
		break;
	case eSAVE: // SAVE
       b2=0xe1;
       break;
    case eRSTR:  // RSTR
       b2=0xe2;
       break;	   
	case eRET: // RET
		b2=0xee;
		break;
	case eSCR: // SCR
		b2=0xfb;
		break;
	case eSCL: // SCL
		b2=0xfc;
		break;
	case eEXIT: // EXIT
		b2=0xfd;
		break;
	case eLOW: // LOW
		b2=0xfe;
		break;
	case eHIGH: // HIGH
		b2=0xff;
		break;
	}
	store_code(b1,b2);
}

// codes avec 1 arguments
//"SCD","JP","CALL","SHR","SHL","SKP","SKNP", NOISE, PUSH, POP, SCRX,SCRY, SCU
void op1(mnemo_t code){
	unsigned b1,b2;
	node_t *n;
	char c;
  
 	
	switch (code){
	case eSCD: // SCD
		b2=expression();
		b1=0;
		b2=0xc0|(b2&0xf);
		break;
	case eSCU: // SCU
        b2=expression();
        b1=0;
        b2=0xd0|(b2&0xf);
        break;		
	case eJP: // JP NNN| JP .-n| JP .+n| JP .
		b1=0x10;
		b2=0;
		next_token();
		if (!(tok_id==eSYMBOL || tok_id==eDOT || tok_id==eNUMBER)) error(eSYNTAX);
		if (tok_id==eNUMBER){ // JP NNN
			b2=token_to_i();
			if (b2>MEM_SIZE-2){
				error(eRANGE);
			}
			b1=(((b2>>1)&0xf00)>>8);
			b2=(b2>>1)&0xff;
		}else if (tok_id==eDOT){ // JP .-n|.+n|.
			c='+';
			next_token();
			if (tok_id==eNONE){
				b1|=(pc>>9)&0xf;
				b2=(pc>>1)&0xff;
			}else{
				if (tok_id==eADDOP){
					c=tok_value[0];
					next_token();
				}
				if (tok_id==eNUMBER){
					switch(c){
					case '+':
						b2=pc+(token_to_i()<<1);
						break;
					case '-':
						b2=pc-(token_to_i()<<1);
						break;
						
					}
					if (b2>MEM_SIZE-2){
					    error(eMEMORY);
					}
					b1|=(b2>>9)&0xf;
					b2= (b2>>1)&0xff;
				}else error(eBADARG);
			}
		}else if (!strcmp(tok_value,"V0")){ // JP V0, NNN
			b1=0xB0;
			next_token();
			if (tok_id!=eCOMMA) error(eSYNTAX);
			next_token();
			if (tok_id!=eSYMBOL) error(eBADARG);
			n=search_label(tok_value);
			if (n){
				b1|=(n->addr>>9)&0xf;
				b2=(n->addr>>1)&0xff;
			}else{
				forward_list=add_forward_ref(tok_value,pc);
			}
		}else{
			n=search_label(tok_value);
			if (n){
				b1|=(n->addr>>9)&0xf;
				b2=(n->addr>>1)&0xff;
			}else{
			    b2=0;
				forward_list=add_forward_ref(tok_value,pc);
			}
		}
		break;
	case eCALL: // CALL LABEL
		b1=0x20;
		next_token();
		if (!((tok_id==eSYMBOL)||(tok_id==eNUMBER))) error(eBADARG);
		if (tok_id==eNUMBER){
			b2=token_to_i();
			if (b2>MEM_SIZE-2){
				error(eRANGE);
			}
			b1|=(b2>>9)&0xf;
			b2=(b2>>1)&0xff;
		}else{
			n=search_label(tok_value);
			if (n){
				b1|=(n->addr>>9)&0xf;
				b2=(n->addr>>1)&0xff;
			}else{
				b2=0;
				forward_list=add_forward_ref(tok_value,pc);
			}
		}
		break;
	case eSHR: // SHR
		b1=0x80|parse_vx();
		b2=6;
		break;
	case eSHL: // SHL
		b1=0x80|parse_vx();
		b2=0xe;
		break;
	case eSKP: // SKP
		b1=0xe0|parse_vx();
		b2=0x9e;
		break;
	case eSKNP: // SKNP
		b1=0xe0|parse_vx();
		b2=0xa1;
		break;
	case eNOISE: // NOISE duration
		b1=0x90;
		b2=expression();
		b1|=(b2&0xf0)>>4;
		b2 = ((b2&0xf)<<4)+4;
		break;
	case ePUSH:
		b1=0x90+parse_vx();
		b2=0x06;
	    break;
	case ePOP:
		b1=0x90+parse_vx();
		b2=0x07;
	    break;
	case eSCRX:
		b1=0x90+parse_vx();
		b2=0x08;
	    break;
	case eSCRY:
		b1=0x90+parse_vx();
		b2=0x09;
		break;
	}
	store_code(b1,b2);
}

// codes avec 2 ou 3 arguments
//"SE","SNE","ADD","SUB","SUBN","OR","AND","XOR","RND","TONE","PRT","GPIX"
//"BSET","BCLR","BINV","BTSS","BTSC"
void op2(unsigned code){
	unsigned b1,b2,mark,i;
	bool reg2;
	
	next_token();
	if (tok_id!=eSYMBOL) error(eSYNTAX);
	if (strlen(tok_value)==1 && tok_value[0]=='I'){
		// ADD I,VX  FX1E
		b2=0x1E;
		next_token();
		if (tok_id!=eCOMMA) error(eSYNTAX);
		b1=0xF0|parse_vx();
		goto op2_done;
	}else if (strlen(tok_value)==2 && tok_value[0]=='V' && hex(tok_value[1])){
		b1=(tok_value[1]<='9'?tok_value[1]-'0':tok_value[1]-'A'+10);
	}else error(eSYNTAX);
	next_token();
	if (tok_id!=eCOMMA) error(eSYNTAX);
	mark=inp;
	next_token();
	if ((tok_id==eSYMBOL) && strlen(tok_value)==2 && tok_value[0]=='V' && hex(tok_value[1])){
		reg2=true;
		b2=(tok_value[1]<='9'?tok_value[1]-'0':tok_value[1]-'A'+10)<<4;
	}else{
		reg2=false;
		inp=mark;
		b2=expression()&0xff;
	}
	switch (code){
	case eSE: 
		if (reg2){ // SE VX,VY 5XY0
			b1|=0x50;
		}else{ // SE VX,KK 3XKK
			b1|=0x30;
		}
		break;
	case eSNE: // SNE
		if (reg2){ // SNE VX,VY 9XY0
			b1|=0x90;
		}else{ // SNE VX,KK 4XKK
			b1|=0x40;
		}
		break;
	case eADD: 
		if (reg2){ // ADD VX,VY 8XY4 
			b1|=0x80;
			b2|=4;
		}else{ // ADD VX,KK 7XKK
			b1|=0x70;
		}		
		break;
	case eSUB: 
		if (reg2){ // SUB VX,VY  8XY5
			b1|=0x80;
			b2|=5;
		}else error(eSYNTAX);
		break;
	case eSUBN: 
		if (reg2){ // SUBN VX, VY 8XY7
			b1|=0x80;
			b2|=7;
		} else error(eSYNTAX);
		break;
	case eOR: // OR VX,VY  8XY1
		if (reg2){
			b1|=0x80;
			b2|=1;
		}else error(eSYNTAX);
		break; 
	case eAND: // AND VX,VY  8XY2
		if (reg2){
			b1|=0x80;
			b2|=2;
		}else error(eSYNTAX);
		break;
	case eXOR: // XOR VX,VY  8XY3
		if (reg2){
			b1|=0x80;
			b2|=3;
		}else error(eSYNTAX);
		break;
	case eRND: // RND VX,KK  CXKK
		if (!reg2)
			b1|=0xC0;
		else 
			error(eSYNTAX);	
		break;
	case ePRT: // PRT VX,VY  9XY2
		if (reg2){
			b1|=0x90;
			b2|=2;
		}else error(eSYNTAX);
		break;
	case ePIXI: //PIXI VX,VY  9XY3
		if (reg2){ 
			b1|=0x90;
			b2|=3;
		}else error(eSYNTAX);
		break;
	case eGPIX: // GPIX VX,VY
		if (reg2){ 
			b1|=0x90;
			b2|=0xf;
		}else error(eSYNTAX);
        break;	
	case eBSET: // BSET VX,N 9XNA
	    if (!(reg2 || b2>7)){
			b1|=0x90;
			b2=(b2<<4)|0x0A;
		}else error(eBADARG);
		break;
	case eBCLR: // BCLR VX,N  9XNB
	    if (!(reg2 || b2>7)){
			b1|=0x90;
			b2=(b2<<4)|0x0B;
		}else error(eBADARG);
	    break;
	case eBINV: // BINV VX,N  9XNC
	    if (!(reg2 || b2>7)){
			b1|=0x90;
			b2=(b2<<4)|0x0C;
		}else error(eBADARG);
	    break; 
	case eBTSS: // BTSS VX,N  9XND
	    if (!(reg2 || b2>7)){
			b1|=0x90;
			b2=(b2<<4)|0x0D;
		}else error(eBADARG);
	    break;
	case eBTSC: // BTSC VX,N  9XNE
	    if (!(reg2 || b2>7)){
			b1|=0x90;
			b2=(b2<<4)|0x0E;
		}else error(eBADARG);
	    break;
	}
op2_done:	
	store_code(b1,b2);
}

// TONE  VX, VY | TONE VX, VY, WAIT
void tone(){
	unsigned b1,b2,i;

	b1=0x90+parse_vx();
	next_token();
	if (tok_id!=eCOMMA) error(eSYNTAX);
	b2=parse_vx()<<4;
	next_token();
	if (tok_id==eNONE){
		b2|=1;
	}else{
		if (tok_id!=eCOMMA) error(eSYNTAX);
		next_token();
		if ((tok_id==eSYMBOL) && !strcmp(tok_value,"WAIT")){
			b2|=5;
		}else{
			error(eBADARG);
		}
	}
	store_code(b1,b2);
}//f()

// DRW VX,VY  DXYN
void draw(){
	unsigned b1,b2,n;
	b1=0xD0|parse_vx();
	next_token();
	if (tok_id!=eCOMMA) error(eSYNTAX);
	b2=parse_vx()<<4;
	next_token();
	if (tok_id!=eCOMMA) error(eSYNTAX);
	n=expression();
	b2|=n&0xf;
	store_code(b1,b2);
}

// LD [I],VX  FX55  
void load_indirect(){
	unsigned b1,b2;
	
	next_token();
	if (!(tok_id==eSYMBOL && strlen(tok_value)==1 && tok_value[0]=='I')) error(eSYNTAX);
	next_token();
	if (tok_id!=eRBRACKET) error(eSYNTAX);
	next_token();
	if (tok_id!=eCOMMA) error(eSYNTAX);
	b1=0xF0|parse_vx();
	b2=0x55;
	store_code(b1,b2);
}

// LD VX,KK  6XKK
// LD VX,VY  8XY0
// LD I,label  ANNN
// LD VX,DT  FX07
// LD DT,VX  FX15
// LD ST,VX  FX18
// LD F,VX   FX29
// LD LF,VX  FX30
// LD B,VX   FX33
// LD [I],VX FX55  
// LD VX,[I] FX65
// LD R,VX   FX75
// LD VX,R   FX85
// LD VX,K   FX0A
void load(){
	unsigned b1,b2,mark;
	node_t *n;
	char c=0,c1;
	
	next_token();
	if (tok_id==eLBRACKET){
		load_indirect();
		return;
	}
	if (!((tok_id==eSYMBOL) && ((strlen(tok_value)==1)||(strlen(tok_value)==2)))) error(eSYNTAX);
	if (strlen(tok_value)==1){ // LD I|R|B|F, ...
		c=tok_value[0];
		next_token();
		if (tok_id!=eCOMMA) error(eSYNTAX);
		switch (c){ // 2ième argument
		case 'I': // LD I,label  ANNN
			b1=0xa0;
			b2=0;
			next_token();
			if (!((tok_id==eSYMBOL)||(tok_id==eNUMBER))) error(eBADARG);
			if (tok_id==eNUMBER){
				b2=token_to_i();
				if (b2>MEM_SIZE-2){
					error(eRANGE);
				}
				b1|=(b2>>9)&0xf;
				b2=(b2>>1)&0xff;
			}else{
				n=search_label(tok_value);
				if (n){
					b1|=(n->addr>>9)&0xf;
					b2=(n->addr>>1)&0xff;
				}else{
				    b2=0;
					forward_list=add_forward_ref(tok_value,pc);
				}
			}
			break;
		case 'R': // LD R,VX  FX75
			b1=0xf0|parse_vx();
			b2=0x75;
			break;
		case 'F': // LD F,VX  FX29
			b1=0xf0|parse_vx();
			b2=0x29;
			break;
		case 'B': // LD B,VX  FX33
			b1=0xf0|parse_vx();
			b2=0x33;
			break;
		default:
			error(eSYNTAX);
		}
		goto load_done;
	}
	if (strlen(tok_value)==2){
		if (tok_value[0]=='V' && hex(tok_value[1])){
			// LD VX, ...
			c=tok_value[1];
			b1=c<='9'?c-'0':c-'A'+10;
			next_token();
			if (tok_id!=eCOMMA) error(eSYNTAX);
			mark=inp;
			next_token();
			if (tok_id==eLPAREN || tok_id==eNUMBER||tok_id==eADDOP){
				inp=mark;
				b2=expression()&0xff;
				b1|=0x60;
				goto load_done;
			}
			if (tok_id==eLBRACKET || (tok_id==eSYMBOL  && strlen(tok_value)==1)){
				c=tok_value[0];
				switch (c){ // LD VX, R|K|[I]
				case 'R': // LD VX,R  FX85
					b1|=0xf0;
					b2=0x85;
					break;
				case 'K': // LD VX,K  FX0A
					b1|=0xf0;
					b2=0x0a;
					break;
				case '[':  // LD VX,[I] FX65
					next_token();
					if (!(tok_id==eSYMBOL && strlen(tok_value)==1 && tok_value[0]=='I')) error(eSYNTAX);
					next_token();
					if (tok_id!=eRBRACKET) error(eSYNTAX);
					b1|=0xf0;
					b2=0x65;
					break;
				default:
					error(eSYNTAX);
				}
				goto load_done;
			}
			if (tok_id==eSYMBOL && strlen(tok_value)==2){  // LD VX, DT|VY
				if (!strcmp(tok_value,"DT")){ // LD VX,DT FX07
					b1|=0xf0;
					b2=0x07;
				}else if (tok_value[0]='V' && hex(tok_value[1])){ // LD VX,VY  8XY0
					b1|=0x80;
					c=tok_value[1];
					b2=(c<='9'?c-'0':c-'A'+10)<<4;
				}else error(eSYNTAX);
				goto load_done;
			}
			error(eSYNTAX);
		}else{
			c=tok_value[0];
			c1=tok_value[1];
			next_token();
			if (tok_id!=eCOMMA) error(eSYNTAX);
			b1=0xf0|parse_vx();
			switch(c){
			case 'D':  // LD DT,VX   FX15
				if (c1!='T') error(eBADARG);
				b2=0x15;
				break;
			case 'L': // LD LF,VX   FX30
				if (c1!='F') error(eBADARG);
				b2=0x30;
				break;
			case 'S': // LD ST, VX  FX18
			    if (c1!='T') error(eBADARG);
				b2=0x18;
				break;
			default:
				error(eSYNTAX);
			}
		}
	}
load_done:	
	store_code(b1,b2);
}

void usage(){
	puts("PICVisionPortable assembler");
	puts("USAGE: pvpasm source binary [-p pp_file] [-s labels_file]");
	puts("'source' is CHIPcon(V2) assembly source file.");
	puts("'binary' is generated binary file to be executed on CHIPcon(V2) console.");
	puts("'-p' generate a pre-processing 'pp_file'.");
	puts("'-s' generate a list of labels file.");
    puts("\t'labels_file' this file can be loaded in cc2emul");
    puts("\tto add breakpoints at corresponding addresses.");
	exit (EXIT_FAILURE);
}


bool space(char c){
   return (c==' ')||(c=='\t')||(c=='\n');
}

void skip_white(){
	while(line[inp] && space(line[inp])) inp++;
}

unsigned parse_string(){
	bool quote=false;
	bool escape=false;
	unsigned i=0;
	
	while (line[inp] && !quote){
		switch(line[inp]){
		case '\\':
			if (!escape) escape=true;else{tok_value[i++]=line[inp];escape=false;}
			break;
		case 'n':
			if (!escape) tok_value[i++]=line[inp];else{tok_value[i++]='\n';escape=false;}
			break;
		case '"':
			if (!escape) quote=true;else{tok_value[i++]=line[inp];escape=false;} 
			break;
		default:
			//if ((line[inp]<32)||line[inp]>127) error();else{tok_value[i++]=line[inp];}
            tok_value[i++]=line[inp];			
			break;
		}//switch
		inp++;
	}//while
	if (quote){tok_value[i]=0;inp--;} else error(eSYNTAX);
	return i;
}

void next_token(){
	unsigned state=0;
	unsigned i=0;
	
	skip_white();
	tok_id=eNONE;
	tok_value[0]=0;
	while ((state<5) && line[inp] && !space(line[inp])){
		switch(state){
		case 0:
			switch(line[inp]){
			case ';':
				tok_id=eNONE;
				tok_value[i++]=0;
				inp=strlen(line);
				state=5;
				break;
			case '+':
			case '-':
				tok_id=eADDOP;
				tok_value[i++]=line[inp];
				state=5;	
				break;
			case '*':
			case '/':
			case '%':
				tok_id=eMULOP;
				tok_value[i++]=line[inp];
				state=5;	
				break;
			case '.':
				tok_id=eDOT;
				tok_value[i++]=line[inp];
				state=5;
				break;
			case '[':
				tok_id=eLBRACKET;
				tok_value[i++]=line[inp];
				state=5;	
				break;
			case ']':
				tok_id=eRBRACKET;
				tok_value[i++]=line[inp];
				state=5;	
				break;
			case '(':
				tok_id=eLPAREN;
				tok_value[i++]=line[inp];
				state=5;	
				break;
			case ')':
				tok_id=eRPAREN;
				tok_value[i++]=line[inp];
				state=5;	
				break;
			case ',':
				tok_id=eCOMMA;
				tok_value[i++]=line[inp];
				state=5;	
				break;
			case '"':
				inp++;
				i=parse_string();
				tok_id=eSTRING;
				state=5;
				break;
			case '#':
				tok_id=eNUMBER;
				tok_value[i++]=line[inp];
				state=1; // nombre hexadécimal
				break;
			case '$':
				tok_id=eNUMBER;
				tok_value[i++]=line[inp];
				state=2; // nombre binaire
			default:
				if (letter(line[inp])||(line[inp]=='_')){
					tok_id=eSYMBOL;
					tok_value[i++]=toupper(line[inp]);
					state=4; // symbole alphanumérique
				}else if (digit(line[inp])){
					tok_id=eNUMBER;
					tok_value[i++]=line[inp];
					state=3; // nombre décimal
				}
			}//switch
			break;
		case 1: // nombre hexadécimal
			if (hex(toupper(line[inp]))){
				tok_value[i++]=toupper(line[inp]);
			}else if (separator(line[inp])){
				inp--;
				state=5;
			}else{
				error(eSYNTAX);
			}
			break;
		case 2: // nombre binaire
			if ((line[inp]=='1') || (line[inp]=='0') || (line[inp]=='.')){
				tok_value[i++]=line[inp];
			}else if (separator(line[inp])){
				inp--;
				state=5;
			}else{
				error(eSYNTAX);
			}
			break;
		case 3: // nombre décimal
			if (digit(line[inp])){
				tok_value[i++]=line[inp];
			}else if (separator(line[inp])){
				inp--;
				state=5;
			}else{
				error(eSYNTAX);
			}
			break;
		case 4: // symbole alphanumérique
			if (alnum(line[inp]) || line[inp]=='_'){
				tok_value[i++]=toupper(line[inp]);
			}else if (line[inp]==':'){
				tok_id=eLABEL;
				inp--;
				state=5;
			}else if (separator(line[inp])){
				inp--;
				state=5;
			}else{
				error(eSYNTAX);
			}
			break;

		}//switch
		inp++;
	}//while
	tok_value[i]=0;
}

void data_byte(){
	unsigned n;
	
	do{
	   n=expression();
	   binary[pc++]=n&0xff;
	   code_size++;
	   next_token();
	   if (tok_id && tok_id!=eCOMMA) error(eSYNTAX);	
   }while((pc<MEM_SIZE) && tok_id);
   if (pc&1) {binary[pc++]=0;code_size++;} //aligne le compteur ordinateur sur adresse paire.
}

void data_word(){
	unsigned n;
	
	do{
		n = expression();
		binary[pc++]=(n>>8)&0xff;
		binary[pc++]=n&0xff;
		code_size+=2;
		next_token();
		if (tok_id && tok_id!=eCOMMA) error(eSYNTAX);
	}while((pc<MEM_SIZE-1) && tok_id);
}

void set_origin(){
	unsigned n;
	
	next_token();
	if (tok_id!=eNUMBER) error(eBADARG);
	n=token_to_i();
	if (n<pc) error(eORIGIN);
	if (n&1) error(ePCIMPAIR);
	for (;pc<n;pc++) binary[pc]=0;
}

void data_ascii(){
	unsigned i=0;
	
	next_token();
	if (tok_id!=eSTRING) error(eSYNTAX);
	while ((pc<MEM_SIZE-1) && tok_value[i]){
		binary[pc++]=tok_value[i++];
		code_size++;
    }
	if (pc<MEM_SIZE){binary[pc++]=0;code_size++;}else {error(eMEMORY);}
	if (pc&1){binary[pc++]=0;code_size++;} //aligne le compteur ordinateur sur adresse paire.
}


void equate(){
	node_t *symbol;
	
	next_token();
	if (tok_id==eSYMBOL){
		symbol=search_symbol(tok_value);
		if (!symbol){ 
			symbol = add_symbol(tok_value,0);
			symbol->value=expression();
			symbol_list=symbol;
		}else{
			symbol->value=expression();
		}
	}else{
		error(eSYNTAX);
	}
}

void define(){
	char *defn_str;
	unsigned i, start;
	next_token();
	if (tok_id!=eSYMBOL) error(eSYNTAX);
	skip_white();
	start=inp;
	while (line[inp] && line[inp]!= ';') inp++;
	if (inp>start){
		line[inp]=0;
		defn_str=malloc(strlen(&line[start])+1);
		for (i=0;line[start+i];i++){ *(defn_str+i)=toupper(line[start+i]);}
		*(defn_str+i)=0;
		define_list=add_define(tok_value,defn_str);
	}
}

/*
void setPC(){ // ORG directive
	unsigned n,mark;
	mark=inp;
	next_token();
	if (tok_id!=eNUMBER){
		inp=mark;
		error(eBADARG);
	}else{
		pc=token_to_i()&0x1fff;
		inp=mark;
		if (pc&1){ 
		    error(eALIGN);
	    }
	}
}//f()
*/

unsigned factor(){
	unsigned n;
	node_t *node;
	char c;
	
	next_token();
	switch(tok_id){
	case eADDOP:
		c=tok_value[0];
		n=factor();
		if (c=='-') n=-n;
		break;
	case eSYMBOL:
		node=search_symbol(tok_value);
		if (node) n=node->value; 
		else error(eEXPRESSION);
		break;
	case eNUMBER:
		n=token_to_i();
		break;
	case eLPAREN:
		n=expression();
		next_token();
		if (tok_id!=eRPAREN) error(eEXPRESSION);
		break;
	default:
		error(eEXPRESSION);
	}
	return n;
}

unsigned term(){
	unsigned n, mark;

	n=factor();
	mark=inp;
	next_token();
	while (tok_id==eMULOP){
		switch (tok_value[0]){
		case '*':
			n*=factor();
			break;
		case '/':
			n/=factor();
			break;
		case '%':
			n%=factor();
			break;
		default:
			error(eEXPRESSION);
		}//switch
		mark=inp;
		next_token();
	}//while
	if (tok_id) inp=mark;
	return n;
}


unsigned expression(){
	unsigned n,mark;
	
	n=term();
	mark=inp;
	next_token();
	while (tok_id==eADDOP){
		switch(tok_value[0]){
		case '+':
			n += term();
			break;
		case '-':
			n -= term();
			break;
		}//switch
		mark=inp;
		next_token();
	}//while
	if (tok_id) inp=mark;
	return n;
}


void assemble_line(){
	int i;

		next_token();
		while (tok_id){
			if (!(tok_id==eSYMBOL || tok_id==eLABEL)) error(eSYNTAX);
			if ((i=search_word(tok_value,mnemonics,KW_COUNT))<KW_COUNT){
				//operation code
				switch(i){
				case eNOP:
				case eCLS:
				case eSAVE:
				case eRSTR:
				case eRET:
				case eSCR:
				case eSCL:
				case eEXIT:
				case eLOW:
				case eHIGH:
					op0(i);
					break;
			    case eSCD:
				case eJP:
				case eCALL:
				case eSHR:
				case eSHL:
				case eSKP:
				case eSKNP:
				case eNOISE:
				case ePUSH:
				case ePOP:
				case eSCRX:
				case eSCRY:
				case eSCU:
					op1(i);
					break;
				case eSE:
				case eSNE:
				case eADD:
                case eSUB:
				case eSUBN:
				case eOR:
				case eAND:
				case eXOR:
				case eRND:
				case ePRT:
				case ePIXI:
				case eGPIX:
				case eBSET:
				case eBCLR:
				case eBINV:
				case eBTSS:
				case eBTSC:
					op2(i);
					break;
				case eTONE:
					tone();
					break;
				case eDRW:
					draw();
					break;
				case eLD:
					load();
					break;
				}
			}else if ((i=search_word(tok_value,directives,DIR_COUNT))<DIR_COUNT){
				// directive d'assembleur
				// les directives 'EQU','DEFN' et les LABELS  sont traité par preprocess() 
				switch(i){
				case 0: // DB
					data_byte();
					break;
				case 1: // DW
					data_word();
					break;
				case 2:  // ASCII
					data_ascii();
					break;
				}//switch 
			}else{
				//unknown code
				error(eBADMNEMO);
			}
			next_token();
		}//while
	
}

void fix_forward_ref(){
	node_t *fwd;
	node_t *lbl;
	
	fwd=forward_list;
	while (fwd){
		lbl=search_label(fwd->name);
		if (lbl){
			binary[fwd->pc] |= (lbl->addr>>9)&0xf;
			binary[fwd->pc+1] = (lbl->addr>>1)&0xff;
		}else{
			printf("%s ?\n",fwd->name);
			error(eNOTREF);
		}
		fwd=fwd->next;
#if defined DEBUG
	if (fwd)
		printf("fwd->name=%s,fwd->pc=#%03X\n",fwd->name,fwd->pc);
#endif	
	}
}

// traitement des directives et substitution des DEFN
// retourne 'true' si l'analyse de cette ligne est complétée.
// sinon 'false'
bool preprocess(){
	char ppline[256];
	unsigned i,pos=0;
	node_t *n;
	bool completed=false;
	bool double_tab;
	
	if (strlen(line)){
		next_token();
		if (tok_id==eNONE) return true;
		if (!(tok_id==eSYMBOL || tok_id==eLABEL)) error(eSYNTAX);
		if (tok_id==eLABEL){
			inp++;
			label_list=add_label(tok_value,pc);
			next_token();
			if (tok_id==eNONE) return true;
			if (!(tok_id==eSYMBOL)) error(eSYNTAX);
		}
		i=search_word(tok_value,directives,DIR_COUNT);
		if ((i<DIR_COUNT) && (i>1)){
			switch(i){
			case eASCII:
				strcpy(ppline,"ASCII \"");
				pos=strlen(ppline);
				next_token();
				if (tok_id!=eSTRING) error(eSYNTAX);
				tok_value[strlen(tok_value)+1]=0;
				tok_value[strlen(tok_value)]='"';
				strcpy(&ppline[pos],tok_value);
				strcpy(line,ppline);
				if (ppf) fprintf(ppf,"%d\t\t%s\n",line_no,line);
				break;
			case eEQU:
				equate();
				completed=true;
				break;
			case eDEFN:
				define();
				completed=true;
				break;
		    case eEND:
				if (ppf) fprintf(ppf,"\nEND\n");
				completed=true;
				file_done=true;
				break;
			case eORG:
                set_origin();
				completed=true;
                break;				
			}//switch
		}else{
			if (ppf) fprintf(ppf,"%d",line_no);
			double_tab=true;
			while (tok_id){
				if (tok_id==eSYMBOL && (n=search_define(tok_value))){
					strcpy(&ppline[pos],n->defn);
				}else if (tok_id==eSYMBOL && (n=search_symbol(tok_value))){
					itoa(n->value,&ppline[pos],10);
				}else{
					switch (tok_id){
					case eLABEL:
						tok_value[strlen(tok_value)+1]=0;
						tok_value[strlen(tok_value)]=':';
						double_tab=false;
						break;
					}//switch	
					strcpy(&ppline[pos],tok_value);
				}
				pos = strlen(ppline);
				if (tok_id!=eADDOP) ppline[pos++]=' ';
				next_token();
			}//while
			ppline[pos]=0;
			strcpy(line,ppline);
			completed=false;
			if (ppf){
				if (double_tab) fprintf(ppf,"\t");
				fprintf(ppf,"\t%s\n",line);
			}
		}
	}else completed=true;
	return completed;
}


void add_predefined(){
	symbol_list=add_symbol("UP",2);
	symbol_list=add_symbol("DOWN",4);
	symbol_list=add_symbol("LEFT",8);
	symbol_list=add_symbol("RIGHT",16);
	symbol_list=add_symbol("FIRE_BTN",32);
	define_list=add_define("W","V0"); // working register
	define_list=add_define("C","VF"); // carry register
}

int main(int argc, char **argv){
	FILE *src;
	char *ppf_name;
	char *lbl_name;
	int i;
	
	if (argc < 3) usage();
	for (i=1;i<argc;i++){
		switch (i){
		case 1:
			if (!(src=fopen(argv[1],"r"))){
				printf("Failed to open %s\n",argv[1]); 
				exit(EXIT_FAILURE);
			}
			break;
		case 2:
			if (!(bin=fopen(argv[2],"wb"))){
				printf("Failed to open %s\n",argv[2]); 
				exit(EXIT_FAILURE);
			}
			break;
		default:
			if (argv[i][0]!='-') usage();
			if (argv[i][1]=='p'){
				if (strlen(argv[i])>2){
					ppf_name=malloc(strlen(argv[i])-1);
					strcpy(ppf_name,argv[i]+2);
				}else if (argc>i){
					i++;
					ppf_name=malloc(strlen(argv[i])+1);
					strcpy(ppf_name,argv[i]);
				}else usage();
				ppf=fopen(ppf_name,"w");
				if (!ppf) printf("failed to create %s file.\n",ppf_name);
			}else if (argv[i][1]=='s'){
				if (strlen(argv[i])>2){
					lbl_name=malloc(strlen(argv[i])-1);
					strcpy(lbl_name,argv[i]+2);
				}else if (argc>i){
					i++;
					lbl_name=malloc(strlen(argv[i])+1);
					strcpy(lbl_name,argv[i]);
				}else usage();
				lbl=fopen(lbl_name,"w");
				if (!lbl) printf("failed to create %s file.\n",lbl_name);
			}else usage();
			break;
		}
	}
	add_predefined();
	pc=0;
	memset(line,0,256);
	line_no=0;
	while (!file_done && (pc<(MEM_SIZE-1)) && fgets(line,256,src)){
		line_no++;
		if (line[strlen(line)-1]<32) line[strlen(line)-1]=0;
		inp=0;
		if (!preprocess()){
			inp=0;
			assemble_line();
		}
		memset(line,0,256);
	}
	if (pc>MEM_SIZE-2 && !feof(src)) error(eMEMORY);
	fclose(src);
	fix_forward_ref();
	fwrite(binary,1,pc,bin);
	fclose(bin);
	if (ppf) fclose(ppf);
	if (lbl){ //labels file 
		while (label_list){
			fprintf(lbl,"%s\t%d\n",label_list->name,label_list->addr);
			label_list=label_list->next;
		}
	}
	printf("Total lines read: %d\ncode size: %d\n",line_no, pc);
	return EXIT_SUCCESS;
}
