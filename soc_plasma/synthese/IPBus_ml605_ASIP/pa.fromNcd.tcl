
# PlanAhead Launch Script for Post PAR Floorplanning, created by Project Navigator

create_project -name ml605_ipbus -dir "C:/IPBus/ml605_from_ml507/planAhead_run_1" -part xc6vlx240tff1156-1
set srcset [get_property srcset [current_run -impl]]
set_property design_mode GateLvl $srcset
set_property edif_top_file "C:/IPBus/ml605_from_ml507/top_ml605_extphy.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {C:/IPBus/ml605_from_ml507} {ipcore_dir} {firmware/ethernet/coregen} }
add_files [list {ipcore_dir/dpbr8.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/dpbr_8_32.ncf}] -fileset [get_property constrset [current_run]]
set_property target_constrs_file "C:/IPBus/ml605_from_ml507/firmware/example_designs/ucf/ml605_extphy.ucf" [current_fileset -constrset]
add_files [list {C:/IPBus/ml605_from_ml507/firmware/example_designs/ucf/ml605_extphy.ucf}] -fileset [get_property constrset [current_run]]
open_netlist_design
read_xdl -file "C:/IPBus/ml605_from_ml507/top_ml605_extphy.ncd"
if {[catch {read_twx -name results_1 -file "C:/IPBus/ml605_from_ml507/top_ml605_extphy.twx"} eInfo]} {
   puts "WARNING: there was a problem importing \"C:/IPBus/ml605_from_ml507/top_ml605_extphy.twx\": $eInfo"
}
