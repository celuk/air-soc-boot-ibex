SUBMAKE := $(MAKE) --no-print-directory -C

# All args except for the first one (which is the target name)
ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))

.PHONY: all
all: 
	@echo "What are you expecting? (￣ー￣)";
	@echo "Read the makefile.";


.PHONY: sim
sim:
	+@$(SUBMAKE) verification/sim/ $(ARGS)

.PHONY: coremark
coremark:
	+@$(SUBMAKE) tests/coremark clean
	+@$(SUBMAKE) tests/coremark
	
.PHONY: simc
simc:
	+@$(SUBMAKE) verification/sim clean
	+@$(SUBMAKE) verification/sim air

.PHONY: show
show:
	vsim verification/sim/sim_build/vsim.wlf
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
