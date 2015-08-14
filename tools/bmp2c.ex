-- euphoria script
-- convert splash bitmap to c file
constant VRES=88
constant HRES=128
constant BPR=HRES/8
constant SPLASH_SIZE=VRES*BPR
integer fh,fo, j, c, r=VRES
sequence bits=repeat(repeat(0,BPR),VRES)

fo=open("splash.h","wb")
printf(fo,"#ifndef SPLASH_\n")
printf(fo,"#define SPLASH_\n\n")
printf(fo,"#include <stdint.h>\n")
printf(fo,"#include <avr/pgmspace.h>\n\n")
printf(fo,"#define SPLASH_SIZE (%d)\n\n",SPLASH_SIZE)
printf(fo,"extern const uint8_t splash[SPLASH_SIZE];\n\n")
printf(fo,"#endif\n")
close(fo)
fo=open("splash.c","wb")
printf(fo,"#include \"splash.h\"\n\n")
printf(fo,"PROGMEM const uint8_t splash[SPLASH_SIZE]={\n")
j=1
fh=open("splash.bmp","rb")
for i=0 to 0x3d do c=getc(fh) end for
c=getc(fh)
while  c!=-1 do
	bits[r][j]=c
    c=getc(fh)
	j+=1
	if j=17 then
		r-=1
		j=1
	end if
end while
for i=1 to VRES do
	for k=1 to BPR do
		printf(fo,"0x%02x, ",bits[i][k])
	end for
	puts(fo,'\n')
end for
puts(fo,"};\n")
close(fh)
close(fo)

