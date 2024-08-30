#------------------------------------------------------------------------------
# (#03) CREATE FLOORPLAN
#------------------------------------------------------------------------------
# This is usefull if you run the script many times
delete_all_floorplan_objs

source scripts/bmp2lay_offset.tcl

#bmp2lay -f /home/ananas/Downloads/hava2.bmp -layer metal11 -px 1 -py 1 -offsetx 75 -offsety 75

split_row

write_db $saveDir/${DESIGN}_03_floorplan.db
