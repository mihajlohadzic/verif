`ifndef LOG_MONITOR_SV
 `define LOG_MONITOR_SV

class log_monitor extends uvm_monitor;

   virtual interface axi_lite_if vif;
   int 	   id;

   uvm_analysis_port #(log_seq_item) item_collected_port;
   protected log_seq_item log_item;
   

   `uvm_component_utils_begin(log_monitor)
      `uvm_field_int(id, UVM_DEFAULT) 
   `uvm_component_utils_end

   
   
   function new (string name = "log_monitor", uvm_component parent = null);
      super.new(name,parent);
      log_item = new();
      item_collected_port = new("item_collected_port", this);
   endfunction // new
   
   function void connect_phase(uvm_phase phase);
       super.connect_phase(phase);
       if (!uvm_config_db#(virtual axi_lite_if)::get(this, "", "axi_lite_if", vif))
         `uvm_fatal("NOVIF",{"virtual interface must be set:",get_full_name(),".vif"})
   endfunction // connect_phase
   

   
   task main_phase(uvm_phase phase);
	 collect_axi_lite();
   endtask // main_phase



   virtual protected task collect_axi_lite();
      
     bit valid = 0;
    
     forever begin
	 log_item = new();
	 if (vif.reset == 'b0)
	   @(posedge vif.reset);
	 if (vif.s00_axi_awvalid == 'b1) begin
	   log_item.trans = 0; //write	    
	   log_item.addr  = vif.s00_axi_awaddr[4:0];
	   @(posedge vif.s00_axi_wvalid);
	   log_item.data  = vif.s00_axi_wdata;
	   @(negedge vif.s00_axi_wvalid);
	   valid = 1;
	 end
	 else if (vif.s00_axi_arvalid == 'b1) begin
	   log_item.trans = 1;	    //read
	   log_item.addr  = vif.s00_axi_araddr[4:0];
	   @(posedge vif.s00_axi_rvalid);
	   log_item.data  = vif.s00_axi_rdata;
	   @(negedge vif.s00_axi_rvalid);
	   valid = 1;
	 end
	 @(posedge vif.clk);
	
	 if (valid == 'b1 ) begin
	   item_collected_port.write(log_item);
	 end
	
	 valid = 0;
     end
   endtask // collect_axi_lite
     
endclass // log_monitor


`endif
