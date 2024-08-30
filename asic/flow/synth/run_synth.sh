#!/bin/bash

make -C rtl clean
make -C rtl || { echo "error: netlist generation failed"; exit 1; }

#source ../env.sh

#update nfs (if any)
ls -laR . >> /dev/null

# remove old log files
rm -f genus_synth.*

# run synthesis in batch mode (exit after synthesis)
genus -abort_on_error -no_gui -batch -files scripts/synthesize.tcl -log genus_synth -overwrite

# if you want to start interactive sesion use:
# genus -log genus_synth -overwrite
