set script_dir [ file dirname [ file normalize [ info script ] ] ]
puts "Script directory: $script_dir"

set project_dir "$script_dir/../project"

# Set the project name
set project_name "ibex-remaster"

# Set the target board
set part "xczu7ev-ffvc1156-2-e"
set board_part "xilinx.com:zcu104:part0:1.1"

# Create the project
create_project $project_name $project_dir/$project_name -part $part

# Set the target board
set_property board_part $board_part [current_project]
