`ifndef in_driver_INCLUDED_
`define PKT_INTERFACE_INCLUDED_

class in_driver extends uvm_driver #(in_sequence_item);

virtual pkt_interface pkt_vif; //declaring the packet interface handle as virtual
  
in_sequence_item isi; //sequence_item handle

int pkt_count=0;
 
`uvm_component_utils(in_driver)
 
function new(string name = "in_driver", uvm_component parent);
    super.new(name, parent);
endfunction

 // Build Phase
virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  if(!uvm_config_db#(virtual pkt_interface)::get(this, "", "pkt_vif", pkt_vif))
      `uvm_fatal("Driver: ", "No vif is found!")
endfunction

//we need to pop the 64 bit values from frame and we need to drive each
     //logic 

virtual task run_phase(uvm_phase phase);
    if(vif.mp_driver.rstn==0)
      begin//check for reset
        $display("RESET CONDITION");
    vif.mp_driver.clk_b_driver.i_wren <= 0;
    vif.mp_driver.clk_b_driver.i_rden <= 0;
    vif.mp_driver.clk_b_driver.i_wrdata <= 0;
   
      end

//  EDITING HERE 
  
    forever begin
      seq_item_port.get_next_item(isi);
      @(posedge pkt_vif.pkt_in_dr_cb)
      begin
        if(isi.frame.size()>1)
          begin
          pkt_vif.pkt_tx_val<=1;
          pkt_vif.pkt_tx_eop<=0;
          if(pkt_count>0)
              pkt_vif.pkt_tx_sop<=1;
          else
              pkt_vif.pkt_tx_sop<=0;
              pkt_vif.pkt_tx_data <= isi.frame.pop_back();
              pkt_count<=pkt_count+1;

          end
        else 
          begin
            pkt_vif.pkt_tx_val<=1;
            pkt_vif.pkt_tx_eop<=1;
            pkt_vip.pkt_tx_data <= isi.frame.pop_back();
          end
        
      end
      if(fsi.i_wren == 1 && fsi.i_rden == 0) begin
          @(posedge vif.mp_driver.clk)
    		vif.mp_driver.clk_b_driver.i_wren <= fsi.i_wren;
            vif.mp_driver.clk_b_driver.i_rden <= fsi.i_rden;
   			vif.mp_driver.clk_b_driver.i_wrdata <= fsi.i_wrdata;
    	 @(negedge vif.mp_driver.clk)
            vif.mp_driver.clk_b_driver.i_wren <= 0;
            vif.mp_driver.clk_b_driver.i_rden <=0; end
      
      else if(fsi.i_wren == 0 && fsi.i_rden == 1) begin
        @(posedge vif.mp_driver.clk)
    		vif.mp_driver.clk_b_driver.i_wren <= fsi.i_wren;
            vif.mp_driver.clk_b_driver.i_rden <= fsi.i_rden;
        @(negedge vif.mp_driver.clk)
            vif.mp_driver.clk_b_driver.i_wren <= 0;
            vif.mp_driver.clk_b_driver.i_rden <=0; end
      
     else if(fsi.i_rden == 1 && fsi.i_wren == 1) begin
       @(posedge vif.mp_driver.clk)
    		vif.mp_driver.clk_b_driver.i_wren <= fsi.i_wren;
            vif.mp_driver.clk_b_driver.i_rden <= fsi.i_rden;
    		vif.mp_driver.clk_b_driver.i_wrdata <= fsi.i_wrdata;
       @(negedge vif.mp_driver.clk)
            vif.mp_driver.clk_b_driver.i_wren <= 0;
            vif.mp_driver.clk_b_driver.i_rden <=0; 
     end
      
     else if(fsi.i_rden == 0 && fsi.i_wren == 0) begin
           @(posedge vif.mp_driver.clk)
    		vif.mp_driver.clk_b_driver.i_wren <= fsi.i_wren;
            vif.mp_driver.clk_b_driver.i_rden <= fsi.i_rden; end
      seq_item_port.item_done();
    end
endtask

   
endclass
