
# PlanAhead Launch Script for Post PAR Floorplanning, created by Project Navigator

create_project -name FPGA_1_2.0 -dir "D:/xlink/FPGA_1_2.0/planAhead_run_4" -part xc3s700anfgg484-5
set srcset [get_property srcset [current_run -impl]]
set_property design_mode GateLvl $srcset
set_property edif_top_file "D:/xlink/FPGA_1_2.0/testTop.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {D:/xlink/FPGA_1_2.0} {ipcore_dir} }
add_files [list {ipcore_dir/IOBuffer.ncf}] -fileset [get_property constrset [current_run]]
set_property target_constrs_file "exampleTop.ucf" [current_fileset -constrset]
add_files [list {exampleTop.ucf}] -fileset [get_property constrset [current_run]]
link_design
read_xdl -file "D:/xlink/FPGA_1_2.0/testTop.ncd"
if {[catch {read_twx -name results_1 -file "D:/xlink/FPGA_1_2.0/testTop.twx"} eInfo]} {
   puts "WARNING: there was a problem importing \"D:/xlink/FPGA_1_2.0/testTop.twx\": $eInfo"
}
