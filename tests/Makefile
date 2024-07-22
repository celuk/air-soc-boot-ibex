RISCVTYPE ?= riscv32-unknown-elf
CC = $(RISCVTYPE)-gcc

LINKER_SCRIPT ?= common/link.ld
START_ASM ?= common/crt0.S

DRIVERS_PATH ?= common/drivers
DRIVERS ?= $(DRIVERS_PATH)/uart.c

CFLAGS ?= -O2 -mcmodel=medany -static -std=gnu99 -fno-common -nostdlib -nostartfiles -fno-builtin -ffunction-sections -lm -lgcc -T $(LINKER_SCRIPT) -march=rv32imc -mabi=ilp32 -I$(DRIVERS_PATH)

CFILE ?= pikachu
CPATH ?= $(CFILE)/$(CFILE)

SRCS ?= $(CPATH).c $(DRIVERS) $(START_ASM)

OUTNAME ?= $(CPATH).riscv

all:
	$(CC) $(CFLAGS) $(SRCS) -o $(OUTNAME)
#	$(CC) -S $(CFLAGS) $(SRCS)
#	$(CC) -c $(CFLAGS) $(SRCS)

	$(RISCVTYPE)-objdump -d -M numeric,no-aliases $(CPATH).riscv > $(CPATH).dump

	$(RISCVTYPE)-objcopy -O binary $(CPATH).riscv $(CPATH).bin
	python3 ../tools/bin2hex.py $(CPATH).bin > $(CPATH).hex

	$(RISCVTYPE)-objcopy -O verilog $(CPATH).riscv $(CPATH).vmem

.PHONY: clean
clean:
	rm -f $(CFILE)/*.log $(CFILE)/*.info $(CFILE)/index.html $(CFILE)/*.o $(CFILE)/*.s $(CFILE)/*.riscv $(CFILE)/*.bin $(CFILE)/*.hex $(CFILE)/*.vh $(CFILE)/*.vmem $(CFILE)/*.coe $(CFILE)/*.txt $(CFILE)/*.v $(CFILE)/*.dump
