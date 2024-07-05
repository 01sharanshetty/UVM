class xgemac_driver extends uvm_driver #(in_sequence_item);

virtual interface_fifo vif; //declaring the interface handle as virtual
  
in_sequence_item isi; //sequence_item handle
 
`uvm_component_utils(driver_fifo)
 
function new(string name = "driver_fifo", uvm_component parent);
    super.new(name, parent);
endfunction

 // Build Phase
virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
   if(!uvm_config_db#(virtual interface_fifo)::get(this, "", "vif", vif))
      `uvm_fatal("Driver: ", "No vif is found!")
endfunction

     
