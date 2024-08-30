SHELL=/bin/bash

NETLIST=netlist.sv

# disabling defaults suffixes
.SUFFIXES:

${NETLIST} :
	./get_netlist.sh

clean:
	rm -f ${NETLIST} src_file_list.txt xrun.log
	rm -rf xcelium.d
