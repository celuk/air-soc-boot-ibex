#------------------------------------------------------------------------------
# (#11) SIGN-OFF EXTRACTION
#------------------------------------------------------------------------------
# Do not modify this file.
#------------------------------------------------------------------------------
source scripts/_00_common_settings.tcl

# Select QRC extraction to be in signoff mode
# Specify the extraction engine to use
set_db extract_rc_engine post_route

# Specify the post-route engine variant to use for performing RC extraction
set_db extract_rc_effort_level signoff

# Separate grounded and coupling capacitance
set_db extract_rc_coupled true

# Specify the location of the optional layer map file for the IQuantus and standalone
# Quantus engines
#set_db extract_rc_lef_tech_file_map extraction.layermap

# Extract resistance and capacitance for the interconnects and store the results in an RC database
extract_rc
