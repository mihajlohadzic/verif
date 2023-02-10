`ifndef LOG_DRIVER_FULL_SV
 `define 	LOG_DRIVER_FULL_SV
class log_driver_full extends uvm_driver#(log_seq_item_full);
 `uvm_component_utils (log_driver_full)
 
 virtual interface axi_full_if vif1;

 function new(string name = "log_driver_full", uvm_component parent = null);
 	super.new(name,parent);
 endfunction
 
    function void connect_phase(uvm_phase phase);
       super.connect_phase(phase);
       if (!uvm_config_db#(virtual axi_full_if)::get(this, "", "axi_full_if", vif1))
         `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif1"})
   endfunction : connect_phase
   
 task main_phase(uvm_phase phase);

    fork
	go_go_go();
        reset();
    join
    
 endtask: main_phase

   virtual protected task go_go_go();
   	forever begin
	
	@(posedge vif1.clk);
	
	if (vif1.reset !=  7'h7f)begin
		seq_item_port.get_next_item(req);
		`uvm_info(get_type_name(), $sformatf("Driver sending...\n%s", req.sprint()), UVM_HIGH)
	   repeat (req.cycles)begin
	      @(posedge vif1.clk);
	   end
	   
	   drive_transfer_axi_full(req);
	end
	seq_item_port.item_done();
	end // forever begin
   endtask
   

virtual protected task drive_transfer_axi_full (log_seq_item_full txn);
      case (txn.trans1)
	0: write_axi_full(txn);
	1: read_axi_full(txn);
      endcase // case (txn.trans1)
endtask // drive_transfer_axi_full

virtual protected task write_axi_full(log_seq_item_full txn);
      bit error;
     `uvm_info("DRV", "write_axi_full", UVM_LOW)
      
      write_address_axi_full(txn, error);
      if(~error) write_data_axi_full(txn, error);
      
      if(~error) write_response(txn, error);
endtask // write_axi_full 

   virtual protected task write_address_axi_full(log_seq_item_full txn, output bit out);

   int 	   to_ctr;
   @(posedge vif1.clk);
   vif1.s01_axi_awid <= txn.axid;
   vif1.s01_axi_awaddr <= txn.addr1;

   vif1.s01_axi_awlen <= txn.length;
   vif1.s01_axi_awsize <= 'b10;
   vif1.s01_axi_awvalid <= 'b1;
   //Increment mode  01
   vif1.s01_axi_awburst <= 'b01;

  
   vif1.s01_axi_awprot <= 'h0;
   vif1.s01_axi_awlock <= 'b0;
   vif1.s01_axi_awcache <= 'h0;
   vif1.s01_axi_awregion <= 'h0;
   vif1.s01_axi_awqos <= 'h0;
 
   for(to_ctr = 0; to_ctr <= txn.addr1; to_ctr++) begin
         @(posedge vif1.clk);
         if (vif1.s01_axi_awready) break;
   end
   if (to_ctr == txn.addr1) `uvm_error("DRV","AWREADY timeout");
  

 
  
   out = (to_ctr == txn.addr1) ? 1 : 0;
   vif1.s01_axi_awvalid <= 'b0;
   
   //vif1.s01_axi_awlen <= 'h0;
      
  
      
   endtask // write_address_axi_full

   virtual protected task write_data_axi_full(log_seq_item_full txn, output bit out);
      int to_ctr, b_ctr;
      bit [8:0] dt_seed, wr_data;

      dt_seed = txn.data1;
      wr_data = $random(dt_seed);

      @(posedge vif1.clk)
      //send data

      for(b_ctr = 0; b_ctr < txn.length; b_ctr++) begin
	 vif1.s01_axi_wvalid <= 'b1;
	 vif1.s01_axi_wstrb <= 'hf;
	 vif1.s01_axi_wdata <= wr_data;
	 
				//txn.data1
	 for(to_ctr = 0; to_ctr <= txn.addr1; to_ctr++) begin
            @(posedge vif1.clk);
            if (vif1.s01_axi_wready) break;
         end

	 if(to_ctr == txn.addr1) begin
	    `uvm_error("DRV","WREADY timeout");
	    out = 1;
	    break;
	 end
	 else
	   out = 0;
	 dt_seed = dt_seed + 4;
	 wr_data = $random(dt_seed);
      end // for (b_ctr = 0; b_ctr < txn.length; b_ctr++)

      //send last data


      if (~out) begin
	 vif1.s01_axi_wdata <= wr_data;
	 vif1.s01_axi_wlast <= 'b1;
	 @(posedge vif1.clk);
      end
      vif1.s01_axi_wlast <= 'b0;
      vif1.s01_axi_wvalid <= 'b0;
      vif1.s01_axi_wstrb <= 'h0;
      vif1.s01_axi_wdata <= 'h0;
   endtask // write_data_axi_full

   virtual protected task write_response(log_seq_item_full txn, output bit error);
      int to_ctr;
      @(posedge vif1.clk);

      vif1.s01_axi_bready <= 'b1;
      
      for(to_ctr = 0; to_ctr <= 31; to_ctr++) begin
         @(posedge vif1.clk);
         if (vif1.s01_axi_bvalid) break;
      end

      if(to_ctr == 31)begin
	 `uvm_error("DRV","BVALID timeout");
      end
      else begin
	 if (vif1.s01_axi_bid != txn.axid) `uvm_error("DRV","BID mismatched");
	 if (vif1.s01_axi_bresp != 'h0) `uvm_error("DRV","ERROR write response");
      end
      if (to_ctr == 31 || vif1.s01_axi_bid != txn.axid || vif1.s01_axi_bresp != 'h0)
	   error = 'b1;
      else error = 'b0;
      vif1.s01_axi_bready <= 'b0;
   endtask // write_response

   /*
    *************************************READ*************************
    */

   virtual protected task read_axi_full(log_seq_item_full txn);
      bit error;
      `uvm_info("DRV", "read_address_axi_full", UVM_LOW)
       read_address_axi_full(txn, error);
      if(~error) read_data_axi_full(txn, error);
   endtask // read_axi_full

   virtual protected task read_address_axi_full(log_seq_item_full txn,output bit out );
      int to_ctr;
      @(posedge vif1.clk);
      vif1.s01_axi_arid    <= txn.axid;
      vif1.s01_axi_araddr  <= txn.addr1;
      vif1.s01_axi_arlen   <= txn.length;
      vif1.s01_axi_arsize  <= 'b10;  //txn.bsize;
      
      //Increment mode
      vif1.s01_axi_arburst <= 'b01;
     
      vif1.s01_axi_arprot  <= 'h0;
      vif1.s01_axi_arvalid <= 'b1;
      for(to_ctr = 0; to_ctr <= 31; to_ctr++) begin
         @(posedge vif1.clk);
         if (vif1.s01_axi_arready) break;
      end
      if (to_ctr == 31) `uvm_error("DRV","ARREADY timeout");
      out = (to_ctr == 31) ? 1 : 0;
      vif1.s01_axi_arvalid <= 'b0; 
   endtask // read_address_axi_full

   virtual protected task read_data_axi_full(log_seq_item_full txn, output bit error);
       int to_ctr, d_ctr;
      bit out;      
      @(posedge vif1.clk);

      vif1.s01_axi_rready <= 'b1;

      // receive data
      for(d_ctr = 0; d_ctr <= txn.length; d_ctr++) begin
         for(to_ctr = 0; to_ctr <= 31; to_ctr++) begin
            @(posedge vif1.clk);
            if (vif1.s01_axi_rvalid) break;
         end
	 out = (to_ctr == 31) ? 1 : 0;
         if (to_ctr == 31) break;
      end // for (d_ctr = 0; d_ctr <= txn.length; d_ctr++)
      if (vif1.s01_axi_rlast != 'b1) `uvm_error("DRV","RLAST not asserted");

      if (out == 1) begin
        `uvm_error("DRV","RVALID timeout");
      end
      else begin
	 if (vif1.s01_axi_rid != txn.axid) `uvm_error("DRV","RID mismatched");
	 if (vif1.s01_axi_rresp != 'h0) `uvm_error("DRV","ERROR read response");
      end

      if (out == 1 || vif1.s01_axi_rid != txn.axid || vif1.s01_axi_rresp != 'h0)
	   error = 'b1;
      else error = 'b0;

      vif1.s01_axi_rready <= 'b0;
   endtask // read_data_axi_full
   
   
   
   virtual protected task reset();
      forever begin
	 @(negedge vif1.reset);
	 
	 vif1.s01_axi_awid      <= 'b0;
	 vif1.s01_axi_awaddr    <= 'h0;
	 vif1.s01_axi_awlen     <= 'h0;
         vif1.s01_axi_awsize    <= 'h0;
         vif1.s01_axi_awburst   <= 'h0;
         vif1.s01_axi_awlock    <= 'h0;
         vif1.s01_axi_awcache   <= 'h0;   
         vif1.s01_axi_awprot    <= 'h0;
         vif1.s01_axi_awqos     <= 'h0;
         vif1.s01_axi_awregion  <= 'h0;
         vif1.s01_axi_awvalid   <= 'h0;
         //vif1.s01_axi_wid     <= 'h0; not supported in axi4
	 vif1.s01_axi_wdata     <= 'h0;
         vif1.s01_axi_wstrb     <= 'h0;
         vif1.s01_axi_wlast     <= 'h0;
         vif1.s01_axi_wvalid    <= 'h0;
	 vif1.s01_axi_bready    <= 'h0;
	 vif1.s01_axi_arid      <= 'h0;
         vif1.s01_axi_araddr    <= 'h0;
         vif1.s01_axi_arlen     <= 'h0;
         vif1.s01_axi_arsize    <= 'h0;
         vif1.s01_axi_arburst   <= 'h0;
         vif1.s01_axi_arlock    <= 'h0;
         vif1.s01_axi_arcache   <= 'h0;
         vif1.s01_axi_arprot    <= 'h0;
         vif1.s01_axi_arqos     <= 'h0;
         vif1.s01_axi_arregion  <= 'h0;
         vif1.s01_axi_arvalid   <= 'h0;
	 vif1.s01_axi_rready    <= 'h0;
      end
   endtask // reset
   
   
endclass : log_driver_full

`endif
