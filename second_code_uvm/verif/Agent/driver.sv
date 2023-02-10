`ifndef LOG_DRIVER_SV
 `define 	LOG_DRIVER_SV
class log_driver extends uvm_driver#(log_seq_item);
 `uvm_component_utils (log_driver)
 
 virtual interface axi_lite_if vif;

 function new(string name = "log_driver", uvm_component parent = null);
 	super.new(name,parent);
 endfunction
 
    function void connect_phase(uvm_phase phase);
       super.connect_phase(phase);
       if (!uvm_config_db#(virtual axi_lite_if)::get(this, "", "axi_lite_if", vif))
         `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"})
   endfunction : connect_phase
   
 task main_phase(uvm_phase phase);

    fork
	go_go_go();
        reset();
    join
    
 endtask: main_phase

   virtual protected task go_go_go();
   	forever begin
	@(posedge vif.clk);
	
	if (vif.reset !=  7'h7f)begin
		seq_item_port.get_next_item(req);
		`uvm_info(get_type_name(), $sformatf("Driver sending...\n%s", req.sprint()), UVM_HIGH)
	   repeat (req.cycles)begin
	      @(posedge vif.clk);
	      drive_transfer_axi_lite(req);
	   end
      	   
	end
	seq_item_port.item_done();
	end // forever begin
   endtask
  
 
  
  
   // drive_transfer
   virtual protected task drive_transfer_axi_lite (log_seq_item txn);
     fork
      drive_address_phase(txn);
      drive_data_phase(txn);
     join
   endtask : drive_transfer_axi_lite
   
    // drive_address_phase
   virtual protected task drive_address_phase (log_seq_item txn);
     `uvm_info("uvm_axi4lite_master_driver", "drive_address_phase",UVM_HIGH)
     case (txn.trans)
         1 : drive_read_address_channel(txn); //read
         0 : drive_write_address_channel(txn); //write
     endcase
   endtask : drive_address_phase

//*****************************READ AND WRITE ADDRESS*********************//
   virtual protected task drive_read_address_channel (log_seq_item txn);
      
     int to_ctr;
      vif.s00_axi_araddr <= {3'h0, txn.addr};
     // vif.s00_axi_araddr <= 5'h2;
      vif.s00_axi_arprot <= 3'h0;
      vif.s00_axi_arvalid <= 1'b1;

      for (to_ctr = 0; to_ctr <=txn.addr; to_ctr ++)begin
	 @(posedge vif.clk);
	 if (vif.s00_axi_arready)
	   break;
      end
      
      if (to_ctr == 31) begin
        `uvm_error("uvm_axi4lite_master_driver","ARVALID timeout");
      end

      @(posedge vif.clk);
      
      vif.s00_axi_araddr <= 5'h0;
      vif.s00_axi_arprot <= 3'h0;
      vif.s00_axi_arvalid <= 1'b0;
   endtask // drive_read_address_channel

   virtual protected task drive_write_address_channel(log_seq_item txn);
      int to_ctr;

      vif.s00_axi_awaddr <= {3'h0, txn.addr};
      vif.s00_axi_awprot <= 3'h0;
      vif.s00_axi_awvalid <= 1'b1;
      
      for (to_ctr = 0; to_ctr <=txn.addr; to_ctr ++)begin
	 @(posedge vif.clk);
	 if (vif.s00_axi_awready)
	   break;
      end
      
      if (to_ctr == 31) begin
        `uvm_error("uvm_axi4lite_master_driver","AWVALID timeout");
      end 
      
      @(posedge vif.clk);
      vif.s00_axi_awaddr <= 5'h0;
      vif.s00_axi_awprot <= 3'h0;
      vif.s00_axi_awvalid <= 1'b0;
   endtask // drive_write_address_channel
//***********************************************************************   

   
     // drive_data_phase
   virtual protected task drive_data_phase (log_seq_item txn);
      bit[31:0] rw_data;
      bit err;

      rw_data = txn.data;
      case (txn.trans)
         1 : drive_read_data_channel(rw_data, err); //read
         0 : drive_write_data_channel(rw_data, err); //write
      endcase     
   endtask : drive_data_phase

   virtual protected task drive_write_data_channel(bit[31:0] data, output bit error);
      int to_ctr;
      
      
      vif.s00_axi_bready <= 1'b1;
      vif.s00_axi_wdata <= data;
      
      vif.s00_axi_wstrb <= 4'hf;
      vif.s00_axi_wvalid <= 1'b1;
      @(posedge vif.clk);
      
      for(to_ctr = 0; to_ctr <= 31; to_ctr ++) begin
         @(posedge vif.clk);
         if (vif.s00_axi_wready) break;
      end

      if (to_ctr == 31) begin
        `uvm_error("uvm_axi4lite_master_driver","AWVALID timeout");
      end

      vif.s00_axi_wdata <= 32'h0;
      vif.s00_axi_wstrb <= 4'h0;
      vif.s00_axi_wvalid <= 1'b0;

      //wait for response

      for(to_ctr = 0; to_ctr <= 31; to_ctr ++) begin
         @(posedge vif.clk);
         if (vif.s00_axi_bvalid) break;
      end

      if (to_ctr == 31) begin
        `uvm_error("uvm_axi4lite_master_driver","BVALID timeout");
      end
      else begin
      //&& vif.s00_axi_bresp != 2'h0
	 if(vif.s00_axi_bvalid == 1'b1 )begin
	  `uvm_error("uvm_axi4lite_master_driver","Received ERROR Write Response");
	   //vif.s00_axi_bready <= vif.s00_axi_bvalid;
	  // vif.s00_axi_bready <= 1'b1; 
	 
	
	 @(posedge vif.clk);
	 end
      end
      vif.s00_axi_bready <= 1'b0;
   endtask // drive_write_data_channel
   //    
//read data channel
   virtual protected task drive_read_data_channel(output bit [31:0] data, output bit error);
      int to_ctr;

      for(to_ctr = 0; to_ctr <= 31; to_ctr ++) begin
         @(posedge vif.clk);
         if (vif.s00_axi_rvalid) break;
      end
       
      data = vif.s00_axi_rdata;
      vif.s00_axi_rready <= 1'b1;
      if (to_ctr == 31) begin
        `uvm_error("uvm_axi4lite_master_driver","RVALID timeout");
      end

      else begin
      	// && vif.s00_axi_rresp != 2'h0
	 if (vif.s00_axi_rvalid == 1'b1)
 	   `uvm_error("uvm_axi4lite_master_driver","Received ERROR Read Response");
         //vif.s00_axi_rready <= vif.s00_axi_rvalid;
         @(posedge vif.clk);
      end
      vif.s00_axi_rready <= 1'b0;
   endtask // drive_read_data_channel
   
   virtual protected task reset();
      forever begin
	 @(negedge vif.reset);

	
         vif.s00_axi_awaddr  <= 32'h0;
         vif.s00_axi_awprot  <=  3'h0;
         vif.s00_axi_awvalid <=  1'b0;
         vif.s00_axi_wdata   <= 32'h0;
         vif.s00_axi_wstrb   <=  4'h0;
         vif.s00_axi_wvalid  <=  1'b0;
         vif.s00_axi_bready  <=  1'b1; //b1
         vif.s00_axi_araddr  <= 32'h0;
         vif.s00_axi_arprot  <=  3'h0;
         vif.s00_axi_arvalid <=  1'b0;
         vif.s00_axi_rready  <=  1'b1;
         
      end
   endtask // reset
   
   
endclass : log_driver

`endif
