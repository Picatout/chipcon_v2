################################################################################
# Automatically-generated file. Do not edit!
################################################################################

SHELL := cmd.exe
RM := rm -rf

USER_OBJS :=

LIBS := 
PROJ := 

O_SRCS := 
C_SRCS := 
S_SRCS := 
S_UPPER_SRCS := 
OBJ_SRCS := 
ASM_SRCS := 
PREPROCESSING_SRCS := 
OBJS := 
OBJS_AS_ARGS := 
C_DEPS := 
C_DEPS_AS_ARGS := 
EXECUTABLES := 
OUTPUT_FILE_PATH :=
OUTPUT_FILE_PATH_AS_ARGS :=
AVR_APP_PATH :=$$$AVR_APP_PATH$$$
QUOTE := "
ADDITIONAL_DEPENDENCIES:=
OUTPUT_FILE_DEP:=
LIB_DEP:=

# Every subdirectory with source files must be described here
SUBDIRS := 


# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS +=  \
../alien.c \
../byteordering.c \
../car.c \
../chipcon_v2.c \
../chipcon_vm.c \
../fat.c \
../filesys.c \
../joystick.c \
../lem.c \
../partition.c \
../sd_raw.c \
../splash.c \
../sram.c \
../text.c \
../tone.c \
../tvout.c \
../vm_test.c \
../worm.c


PREPROCESSING_SRCS += 


ASM_SRCS += 


OBJS +=  \
alien.o \
byteordering.o \
car.o \
chipcon_v2.o \
chipcon_vm.o \
fat.o \
filesys.o \
joystick.o \
lem.o \
partition.o \
sd_raw.o \
splash.o \
sram.o \
text.o \
tone.o \
tvout.o \
vm_test.o \
worm.o

OBJS_AS_ARGS +=  \
alien.o \
byteordering.o \
car.o \
chipcon_v2.o \
chipcon_vm.o \
fat.o \
filesys.o \
joystick.o \
lem.o \
partition.o \
sd_raw.o \
splash.o \
sram.o \
text.o \
tone.o \
tvout.o \
vm_test.o \
worm.o

C_DEPS +=  \
alien.d \
byteordering.d \
car.d \
chipcon_v2.d \
chipcon_vm.d \
fat.d \
filesys.d \
joystick.d \
lem.d \
partition.d \
sd_raw.d \
splash.d \
sram.d \
text.d \
tone.d \
tvout.d \
vm_test.d \
worm.d

C_DEPS_AS_ARGS +=  \
alien.d \
byteordering.d \
car.d \
chipcon_v2.d \
chipcon_vm.d \
fat.d \
filesys.d \
joystick.d \
lem.d \
partition.d \
sd_raw.d \
splash.d \
sram.d \
text.d \
tone.d \
tvout.d \
vm_test.d \
worm.d

OUTPUT_FILE_PATH +=chipcon_v2.elf

OUTPUT_FILE_PATH_AS_ARGS +=chipcon_v2.elf

ADDITIONAL_DEPENDENCIES:=

OUTPUT_FILE_DEP:= ./makedep.mk

LIB_DEP+= 

# AVR32/GNU C Compiler





































./%.o: .././%.c
	@echo Building file: $<
	@echo Invoking: AVR/GNU C Compiler : 3.4.4
	$(QUOTE)C:\Program Files (x86)\Atmel\Atmel Toolchain\AVR8 GCC\Native\3.4.1056\avr8-gnu-toolchain\bin\avr-gcc.exe$(QUOTE)  -funsigned-char -funsigned-bitfields -DDEBUG  -O1 -ffunction-sections -fdata-sections -fpack-struct -fshort-enums -g2 -Wall -mmcu=atmega328p -c -std=gnu99 -MD -MP -MF "$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -MT"$(@:%.o=%.o)"   -o "$@" "$<"
	@echo Finished building: $<
	



# AVR32/GNU Preprocessing Assembler



# AVR32/GNU Assembler




ifneq ($(MAKECMDGOALS),clean)
ifneq ($(strip $(C_DEPS)),)
-include $(C_DEPS)
endif
endif

# Add inputs and outputs from these tool invocations to the build variables 

# All Target
all: $(OUTPUT_FILE_PATH) $(ADDITIONAL_DEPENDENCIES)

$(OUTPUT_FILE_PATH): $(OBJS) $(USER_OBJS) $(OUTPUT_FILE_DEP) $(LIB_DEP)
	@echo Building target: $@
	@echo Invoking: AVR/GNU Linker : 3.4.4
	$(QUOTE)C:\Program Files (x86)\Atmel\Atmel Toolchain\AVR8 GCC\Native\3.4.1056\avr8-gnu-toolchain\bin\avr-gcc.exe$(QUOTE) -o$(OUTPUT_FILE_PATH_AS_ARGS) $(OBJS_AS_ARGS) $(USER_OBJS) $(LIBS) -Wl,-Map="chipcon_v2.map" -Wl,--start-group -Wl,-lm  -Wl,--end-group -Wl,--gc-sections -mmcu=atmega328p 
	@echo Finished building target: $@
	"C:\Program Files (x86)\Atmel\Atmel Toolchain\AVR8 GCC\Native\3.4.1056\avr8-gnu-toolchain\bin\avr-objcopy.exe" -O ihex -R .eeprom -R .fuse -R .lock -R .signature  "chipcon_v2.elf" "chipcon_v2.hex"
	"C:\Program Files (x86)\Atmel\Atmel Toolchain\AVR8 GCC\Native\3.4.1056\avr8-gnu-toolchain\bin\avr-objcopy.exe" -j .eeprom  --set-section-flags=.eeprom=alloc,load --change-section-lma .eeprom=0  --no-change-warnings -O ihex "chipcon_v2.elf" "chipcon_v2.eep" || exit 0
	"C:\Program Files (x86)\Atmel\Atmel Toolchain\AVR8 GCC\Native\3.4.1056\avr8-gnu-toolchain\bin\avr-objdump.exe" -h -S "chipcon_v2.elf" > "chipcon_v2.lss"
	"C:\Program Files (x86)\Atmel\Atmel Toolchain\AVR8 GCC\Native\3.4.1056\avr8-gnu-toolchain\bin\avr-objcopy.exe" -O srec -R .eeprom -R .fuse -R .lock -R .signature  "chipcon_v2.elf" "chipcon_v2.srec"
	"C:\Program Files (x86)\Atmel\Atmel Toolchain\AVR8 GCC\Native\3.4.1056\avr8-gnu-toolchain\bin\avr-size.exe" "chipcon_v2.elf"
	
	





# Other Targets
clean:
	-$(RM) $(OBJS_AS_ARGS) $(EXECUTABLES)  
	-$(RM) $(C_DEPS_AS_ARGS)   
	rm -rf "chipcon_v2.elf" "chipcon_v2.a" "chipcon_v2.hex" "chipcon_v2.lss" "chipcon_v2.eep" "chipcon_v2.map" "chipcon_v2.srec"
	