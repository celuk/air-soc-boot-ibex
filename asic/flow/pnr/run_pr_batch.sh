#!/bin/bash

#source ../env.sh

#update nfs (if any)
ls -laR . >> /dev/null

# run synthesis in batch mode (exit after synthesis)
innovus -stylus -abort_on_error -files ./scripts/run_pr.tcl -log innovus_riscv -overwrite

# innovus -stylus -log innovus_riscv -overwrite "$@"
