`ifndef LOG_MONITOR_FULL_SV
 `define LOG_MONITOR_FULL_SV

class log_monitor_full extends uvm_monitor;

   virtual interface axi_full_if vif1;
   int 	   id;

   uvm_analysis_port #(log_seq_item_full) item_collected_port;
   protected log_seq_item_full log_item;
   

   `uvm_component_utils_begin(log_monitor_full)
      `uvm_field_int(id, UVM_DEFAULT) 
   `uvm_component_utils_end

   
   
   function new (string name = "log_monitor_full", uvm_component parent = null);
      super.new(name,parent);
      log_item = new();
      item_collected_port = new("item_collected_port", this);
   endfunction // new
   
   function void connect_phase(uvm_phase phase);
       super.connect_phase(phase);
       if (!uvm_config_db#(virtual axi_full_if)::get(this, "", "axi_full_if", vif1))
         `uvm_fatal("NOVIF",{"virtual interface must be set:",get_full_name(),".vif1"})
   endfunction // connect_phase
   

   
   task main_phase(uvm_phase phase);
	 collect_axi_full();	 
      
   endtask // main_phase


   virtual protected task collect_axi_full();
      
     bit valid = 0;
      forever begin
	 log_item = new();
	 if(vif1.reset == 'b0)@(posedge vif1.reset);
	
	 @(posedge vif1.clk)
	   //axi write
	   if(vif1.s01_axi_awvalid)begin
	      valid = 'b1;
	      //log_item.trans = 0;
	      //get write  address
	 
	      //AXI Full
	      log_item.axid = vif1.s01_axi_awid;
	      log_item.addr1 = vif1.s01_axi_awaddr;
	      log_item.length = vif1.s01_axi_awlen;
	      log_item.bsize = vif1.s01_axi_awsize;

	      case (vif1.s01_axi_awburst)
		'b00: log_item.btype = 0;
		'b01: log_item.btype = 1;
		'b10: log_item.btype = 2;
	      endcase // case (vif.s01_axi_awburst)

	      //get data

	      @(posedge vif1.s01_axi_wvalid);
	      while(vif1.s01_axi_wvalid) begin
		 if(vif1.s01_axi_wready)begin
		    log_item.data1 = vif1.s01_axi_wdata;
		 end 
		@(posedge vif1.clk);
		 if(vif1.s01_axi_wlast)  break;
	      end
	      //wait response

	      while(vif1.s01_axi_bvalid != 'b1 && vif1.s01_axi_bready != 'b1) begin
		 @(posedge vif1.clk);
	      end
	   end // if (vif.s01_axi_awvalid)
	 /*
	  **************************************************************************
	  ******************************  READ AXI **********************************
	  * **************************************************************************
	  * **************************************************************************
	  */
	   else if(vif1.s01_axi_arvalid)begin
	      valid  = 'b1;
         //     log_item.trans  = 1;
	    // get read address
	      log_item.axid   = vif1.s01_axi_arid;
	      log_item.addr1   = vif1.s01_axi_araddr;
	      log_item.length = vif1.s01_axi_arlen;
	      log_item.bsize  = vif1.s01_axi_arsize;
              case (vif1.s01_axi_arburst)
		'b00: log_item.btype = 0;
		'b01: log_item.btype = 1;
		'b10: log_item.btype = 2;
              endcase // case (vif.s01_axi_arburst)

	      @(posedge vif1.s01_axi_rvalid);
	      while (vif1.s01_axi_rvalid)begin
		 if(vif1.s01_axi_rready) begin
		    log_item.data1 = vif1.s01_axi_rdata;
		 end
		 @(posedge vif1.clk);
		 if(vif1.s01_axi_rlast)break;
	      end
	   end // if (vif.s01_axi_arvalid)
	   else begin
	      valid = 'b0;
	   end // else: !if(vif.s01_axi_arvalid)
	 
	 if (valid == 'b1 ) begin
	    item_collected_port.write(log_item);
	 end
	 	 
      end // forever begin

   endtask // collect_axi_full
   
endclass // log_monitor


`endif
