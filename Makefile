SHELL := /bin/bash

SUBMAKE := $(MAKE) --no-print-directory -C

# All args except for the first one (which is the target name)
ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))

.PHONY: all
all: 
	@echo "What are you expecting? (￣ー￣)";
	@echo "Read the makefile.";

XILINX_VIVADO ?= /tools/Xilinx/Vivado/2022.2
VIVADO_DIR    := ./vivado
COMPILED_LIBS := compiled-libs

.PHONY: compx
compx:
	@pushd $(VIVADO_DIR); \
	mkdir -p $(COMPILED_LIBS); \
	vlib $(COMPILED_LIBS); \
	vmap $(COMPILED_LIBS) $(shell pwd)/$(VIVADO_DIR)/$(COMPILED_LIBS); \
	vcom -2008 -work $(COMPILED_LIBS) $(XILINX_VIVADO)/data/vhdl/src/unisims/unisim_VCOMP.vhd $(XILINX_VIVADO)/data/vhdl/src/unisims/unisim_VPKG.vhd; \
	vlog -work $(COMPILED_LIBS) $(XILINX_VIVADO)/data/verilog/src/unisims/*.v; \
	export XILINX_VIVADO=$(XILINX_VIVADO); \
	vlog -work $(COMPILED_LIBS) -f $(XILINX_VIVADO)/data/secureip/secureip_cell.list.f; \
	vlog -work $(COMPILED_LIBS) $(XILINX_VIVADO)/data/verilog/src/glbl.v; \
	popd;
	
.PHONY: rmcompx
rmcompx:
	@pushd $(VIVADO_DIR); \
	rm -rf $(COMPILED_LIBS) \
	rm -f modelsim.ini; \
	popd;

COMPILED_LIBS_X := compxip

.PHONY: compxip
compxip:
	@pushd $(VIVADO_DIR); \
	mkdir -p $(COMPILED_LIBS_X); \
	echo "SOFTINCLUDE ${CDS_XCELIUM}/tools/inca/files/cds.lib" > cds.lib; \
	echo "DEFINE $(COMPILED_LIBS_X) $(shell pwd)/$(VIVADO_DIR)/$(COMPILED_LIBS_X)" >> cds.lib; \
	xmvhdl -relax -work $(COMPILED_LIBS_X) $(XILINX_VIVADO)/data/vhdl/src/unisims/unisim_VCOMP.vhd $(XILINX_VIVADO)/data/vhdl/src/unisims/unisim_VPKG.vhd;

#echo "DEFINE std ${CDS_XCELIUM}/tools/inca/files/STD" > cds.lib; \
#echo "DEFINE ieee ${CDS_XCELIUM}/tools/inca/files/IEEE" >> cds.lib; \

#echo "SOFTINCLUDE ${CDS_XCELIUM}/tools.lnx86/inca/files/cds.lib" > cds.lib; \
#echo "SOFTINCLUDE ${CDS_XCELIUM}/tools.lnx86/inca/files/hdl.var" >> cds.lib; \
#echo "DEFINE $(COMPILED_LIBS_X) $(shell pwd)/$(VIVADO_DIR)/$(COMPILED_LIBS_X)" >> cds.lib; \

.PHONY: rmcompxip
rmcompxip:
	@pushd $(VIVADO_DIR); \
	rm -rf $(COMPILED_LIBS_X) \
	rm -f cds.lib; \
	rm -f *.log; \
	popd;

#.PHONY: sim
#sim:
#	+@$(SUBMAKE) verification/sim/ $(ARGS)

.PHONY: coremark
coremark:
	+@$(SUBMAKE) tests/coremark clean
	+@$(SUBMAKE) tests/coremark

.PHONY: compile
compile:
	+@$(SUBMAKE) tests clean CFILE=$(ARGS)
	+@$(SUBMAKE) tests CFILE=$(ARGS)

.PHONY: clean_test
clean_test:
	+@$(SUBMAKE) tests clean CFILE=$(ARGS)

.PHONY: clean_all_tests
clean_all_tests:
	+@$(SUBMAKE) tests/coremark clean
	+@$(SUBMAKE) tests clean CFILE=demo
	+@$(SUBMAKE) tests clean CFILE=pikachu

.PHONY: sim
sim:
	+@$(SUBMAKE) verification/sim clean
	+@$(SUBMAKE) verification/sim air CFILE=$(ARGS)

.PHONY: send
send:
	@if [ "$(MAKECMDGOALS)" = "send" ]; then \
		python3 ./tools/uart_send_data.py; \
	else \
		python3 ./tools/uart_send_data.py --port /dev/ttyUSB$(word 2, $(MAKECMDGOALS)) --file $(word 3, $(MAKECMDGOALS)); \
	fi

.PHONY: pico
pico:
	picocom -b 115200 /dev/ttyUSB$(ARGS) --imap lfcrlf

.PHONY: vmem2carr
vmem2carr:
	python3 ./tools/vmem2carr.py -f $(ARGS)

%:
	@:

.PHONY: show
show:
	simvision verification/sim/sim_build/cocotb_waves.shm/cocotb_waves.trn
#	vsim verification/sim/sim_build/vsim.wlf -do verification/sim/waveform/wave.do
#-do verification/sim/waveform/wave.do

.PHONY: clean
clean:
	-rm -rf ./build
	-rm -rf ./sim_build
	-+@$(SUBMAKE) synth/quartus/ clean
	-+@$(SUBMAKE) synth/vivado/ clean
	-+@$(SUBMAKE) verification/sim/ clean
	-+@$(SUBMAKE) verification/prove/ clean
	-+@$(SUBMAKE) software/tests/riscv-tests/ clean
