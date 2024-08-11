RISCVTYPE ?= riscv32-unknown-elf
CC = $(RISCVTYPE)-gcc

COMMON_PATH ?= common

LINKER_SCRIPT ?= $(COMMON_PATH)/link.ld
START_ASM ?= $(COMMON_PATH)/crt0.S

DRIVERS_PATH ?= $(COMMON_PATH)/drivers
DRIVERS ?= $(DRIVERS_PATH)/uart.c $(DRIVERS_PATH)/timer.c

CFLAGS ?= -O0 -mcmodel=medany -static -std=gnu99 -fno-common -fno-unroll-loops -nostdlib -nostartfiles -fno-builtin -ffunction-sections -lm -lgcc -T $(LINKER_SCRIPT) -march=rv32im -mabi=ilp32 -I$(COMMON_PATH) -I$(DRIVERS_PATH)

CFILE ?= demo
CPATH ?= $(CFILE)/$(CFILE)

SRCS ?= $(CPATH).c $(DRIVERS) $(START_ASM)

OUTNAME ?= $(CPATH).riscv

.PHONY: all
all:
	$(CC) $(CFLAGS) $(SRCS) -o $(OUTNAME)
#	$(CC) -S $(CFLAGS) $(SRCS)
#	$(CC) -c $(CFLAGS) $(SRCS)

	$(RISCVTYPE)-objdump -d -M numeric,no-aliases $(CPATH).riscv > $(CPATH).dump

	$(RISCVTYPE)-objcopy -O binary $(CPATH).riscv $(CPATH).bin
	python3 ../tools/bin2hex.py $(CPATH).bin > $(CPATH).hex

	$(RISCVTYPE)-objcopy -O verilog $(CPATH).riscv $(CPATH).vmem

#.PHONY: $(CFILE)
#$(CFILE): all

.PHONY: clean
clean:
	rm -f $(CFILE)/*.log $(CFILE)/*.info $(CFILE)/index.html $(CFILE)/*.o $(CFILE)/*.s $(CFILE)/*.riscv $(CFILE)/*.bin $(CFILE)/*.hex $(CFILE)/*.vh $(CFILE)/*.vmem $(CFILE)/*.coe $(CFILE)/*.txt $(CFILE)/*.v $(CFILE)/*.dump
