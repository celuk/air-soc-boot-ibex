#------------------------------------------------------------------------------
# (#14) SIGN-OFF DRC LVS
#------------------------------------------------------------------------------
# Do not modify this file.
#------------------------------------------------------------------------------
source scripts/_00_common_settings.tcl

# Check for DRC violations and create violation markers in the design database
# that can be seen on the GUI and browsed with the Violation Browser
check_drc -out_file $reportDir/14_check_drc.rpt

# Detect conditions such as opens, unconnected wires (geometric antennas),
# unconnected pins, loops, partial routing, and unrouted nets; generate violation markers
# in the design window; report violations
check_connectivity -out_file $reportDir/14_check_connectivity.rpt

check_antenna -out_file $reportDir/14_check_antenna.rpt
