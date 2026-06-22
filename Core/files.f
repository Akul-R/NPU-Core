#Run this in ModelSim to compile:
#vlog -sv -f files.f
#Then compile testbench and simulate

#compile the systolic array files first
rtl/SystolicArray/f-adder.sv
rtl/SystolicArray/nAdder.sv
rtl/SystolicArray/nMultiplier.sv
rtl/SystolicArray/nMAC.sv
rtl/SystolicArray/nSystolicArray.sv

#compile the control unit
rtl/controlUnit.sv

#compile top leve