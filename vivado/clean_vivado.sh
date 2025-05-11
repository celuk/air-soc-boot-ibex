#!/usr/bin/env bash
set -euo pipefail

# List all your Vivado .gitignore patterns here:
patterns=(
  '*.jou'     '*.log'      '*.debug'   '*.str'
  '*.zip'     '*.tmp'      '*.rst'     '*.os'
  '*.js'      '*.pb'       '*.dcp'     '*.hwdef'
  '*.vds'     '*.veo'      '*.wdf'     '*.vdi'
  '*.dmp'     '*.rpx'      '*.rpt'     '*_stub.v'
  '*_stub.vhdl' '*_funcsim.v' '*_funcsim.vhdl' '.project'
  '*.cache'   '.metadata'  '*.data'    '*.ipdefs'
  '.Xil'      '*.sdk'      '*.hw'      '*.ip_user_files'
  '*_synth_*' '*.jobs'
  # synth-run outputs
  '*/.runs/synth*'
  # impl-run outputs
  '*/.runs/impl*'
  # block-design HDL/XDC/TCL/etc
  '*/bd/*/hdl'    '*/bd/*/*.xdc'    '*/bd/*/ip/*'
)

# Recursively delete every file or directory matching any of these patterns.
for pat in "${patterns[@]}"; do
  find . -path "./$pat" -exec rm -rf {} +
done

