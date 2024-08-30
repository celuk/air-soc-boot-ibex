SHELL=/bin/bash

# disabling defaults suffixes
.SUFFIXES:

NETLIST=rtl/netlist.sv
SYNTH_RESULT=results/air_soc.invs_setup.tcl

synth: ${SYNTH_RESULT}
.PHONY: synth

${SYNTH_RESULT} : ${NETLIST} \
  constraints/design.sdc
	./run_synth.sh

${NETLIST} : 
	${MAKE} -C rtl

clean:
	${MAKE} -C rtl clean
	rm -rf results LEC reports
	rm -f genus_synth.* xrun.history
.PHONY: clean
