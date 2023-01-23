`ifndef LOG_DRIVER_SV
 `define 	LOG_DRIVER_SV
class log_driver extends uvm_driver#(log_seq_item);
 `uvm_component_utils (log_driver)
 
 virtual interface log_if vif;

 function new(string name = "log_driver", uvm_component parent = null);
 	/*if (!uvm_config_db#(virtual log_if)::get(this, "", "log_if", vif))
        `uvm_fatal("NOVIF",{"virtual interface must be set:",get_full_name(),".vif"}) */
 	super.new(name,parent);
 endfunction
 
    function void connect_phase(uvm_phase phase);
       super.connect_phase(phase);
       if (!uvm_config_db#(virtual log_if)::get(this, "", "log_if", vif))
         `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"})
   endfunction : connect_phase

 task main_phase(uvm_phase phase);
 
	forever begin
	
	@(posedge vif.s00_axi_aclk);
	
				if (vif.s00_axi_aresetn !=  7'h7f)begin
					seq_item_port.get_next_item(req);
					`uvm_info(get_type_name(),
							   $sformatf("Driver sending...\n%s", req.sprint()),
							   UVM_HIGH)
							   
							   repeat (req.cycles) begin
							   @(posedge vif.s00_axi_aclk);
							   end
							   
							   drive_transfer_axi_lite(req);
							   drive_transfer_axi_full(req);
				end
				seq_item_port.item_done();
	end
	
	reset();

 endtask: main_phase
 
 
	//****************DRIVE TRANSFER************************
    virtual protected task drive_transfer_axi_lite (log_seq_item txn);
      drive_address_phase(txn);
      drive_data_phase(txn);
   endtask : drive_transfer_axi_lite
 //********************DRIVE ADDRES PHASE ****************************  
    virtual protected task drive_address_phase (log_seq_item txn);
     `uvm_info("uvm_axi4lite_master_driver", "drive_address_phase",UVM_HIGH)
      case (txn.trans)
         1 : drive_read_address_channel(txn);
         0 : drive_write_address_channel(txn);
      endcase
   endtask : drive_address_phase
  
 //********************DRIVE DATA PHASE **********************************  
    virtual protected task drive_data_phase (log_seq_item txn);
      bit[31:0] rw_data;
      bit err;

      rw_data = txn.data;
      case (txn.trans)
         1 : drive_read_data_channel(rw_data, err);
         0 : drive_write_data_channel(rw_data, err);
      endcase    
   endtask : drive_data_phase
   
  //***********************DRIVE READ ADDRES CHANNEL***************************
    virtual protected task drive_read_address_channel (log_seq_item txn);
      int to_ctr;
      vif.s00_axi_araddr <= {16'h0, txn.addr};
      vif.s00_axi_arprot <= 3'h0;
      vif.s00_axi_arvalid <= 1'b1;
      
      for(to_ctr = 0; to_ctr <= 31; to_ctr ++)
      begin
      @(posedge vif.s00_axi_aclk);
      if(vif.s00_axi_arready)
      break;
      end
      if (to_ctr == 31) begin
        `uvm_error("uvm_axi4lite_master_driver","ARVALID timeout");
      end 
      @(posedge vif.s00_axi_aclk);
      
      vif.s00_axi_araddr <= 32'h0;
      vif.s00_axi_arprot <= 3'h0;
      vif.s00_axi_arvalid <= 1'b0;
     
     endtask
    //***********************DRIVE WRITE ADDRESS CHANNEL************************************
     virtual protected task drive_write_address_channel (log_seq_item txn);
        int to_ctr;
        
        vif.s00_axi_awaddr <= {16'h0, txn.addr};
        vif.s00_axi_awprot <= 3'h0;
        vif.s00_axi_awvalid <= 1'b1;
        
        for(to_ctr = 0; to_ctr <= 31; to_ctr ++) begin
            @(posedge vif.s00_axi_aclk);
            if (vif.s00_axi_awready) break;
        end
        
        if (to_ctr == 31) begin
        `uvm_error("uvm_axi4lite_master_driver","AWVALID timeout");
      end
        
        @(posedge vif.s00_axi_aclk);
        vif.s00_axi_awaddr <= 32'h0;
        vif.s00_axi_awprot <= 3'h0;
        vif.s00_axi_awvalid <= 1'b0;
      
      endtask
      
      //***************************WRITE DATA CHANNEL*******************
      
      virtual protected task drive_write_data_channel (bit[31:0] data, output bit error);
      int to_ctr;
      
      vif.s00_axi_wdata <= data;
      vif.s00_axi_wstrb <= 4'hf;
      vif.s00_axi_wvalid <= 1'b1;
      @(posedge vif.s00_axi_aclk);
      
      for(to_ctr = 0; to_ctr <= 31; to_ctr ++) begin
         @(posedge vif.s00_axi_aclk);
         if (vif.s00_axi_wready) break;
      end
       if (to_ctr == 31) begin
        `uvm_error("uvm_axi4lite_master_driver","AWVALID timeout");
      end
      
      @(posedge vif.s00_axi_aclk);
      vif.s00_axi_bready <= 1'b1;
      vif.s00_axi_wdata <= 32'h0;
      vif.s00_axi_wstrb <= 4'h0;
      vif.s00_axi_wvalid <= 1'b0;
      
      //wait for response
      for(to_ctr = 0; to_ctr <= 31; to_ctr ++) begin
         @(posedge vif.s00_axi_aclk);
         if (vif.s00_axi_bvalid) break;
      end
      if (to_ctr == 31) begin
        `uvm_error("uvm_axi4lite_master_driver","BVALID timeout");
      end
      else begin
            //&& vif.s00_axi_bresp != 2'h0
        if(vif.s00_axi_bvalid == 1'b1) begin
        `uvm_error("uvm_axi4lite_master_driver","Received ERROR Write Response");
        //vif.s00_axi_bready <= vif.s00_axi_bvalid;
        //vif.s00_axi_bready <= 1'b1;
        @(posedge vif.s00_axi_aclk);
       end
     end
       vif.s00_axi_bready <= 1'b0;
     endtask
     
    //***************DRIVE READ DATA CHANNEL*************************
    virtual protected task drive_read_data_channel (output bit [31:0] data, output bit error);
      int to_ctr;

      for(to_ctr = 0; to_ctr <= 31; to_ctr ++) begin
         @(posedge vif.s00_axi_aclk);
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
         @(posedge vif.s00_axi_aclk);
         
         end
         vif.s00_axi_rready <= 1'b0;
     endtask
 //********************************AXI FULL*******************
    virtual protected task drive_transfer_axi_full (log_seq_item txn);
        case(txn.trans1)
            0: write_axi_full(txn);
            1: read_axi_full(txn);
        endcase
    endtask
    
    virtual protected task write_axi_full(log_seq_item txn);
        bit error;
         `uvm_info("DRV", "write_axi_full", UVM_LOW)
         write_address_axi_full(txn, error);
         
         if(~error) write_data_axi_full(txn,error);
         if(~error) write_response(txn,error);
          
    endtask
    //******************WRITE ADDRES AXI FULL*******************
    virtual protected task write_address_axi_full(log_seq_item txn, output bit out);
    
        int to_ctr;
        @(posedge vif.s00_axi_aclk);
        vif.s01_axi_awid <= txn.axid;
        vif.s01_axi_awaddr <= txn.addr1;
        
        vif.s01_axi_awlen <= txn.length;
        //vif.s01_axi_awlen <= 'h19;
        vif.s01_axi_awsize <= 'b10;
        vif.s01_axi_awvalid <= 'b1;
        //increment mode 01
        vif.s01_axi_awburst <= 'b01;
        
        
    /*    case(txn.btype)
            0: vif.s01_axi_awburst <= 'b00; //fixed
            1: vif.s01_axi_awburst <= 'b01; //incr
            2: vif.s01_axi_awburst <= 'b10; //wrap
        endcase
     */   
        vif.s01_axi_awprot <= 'h0;
        vif.s01_axi_awlock <= 'h0;
        vif.s01_axi_awcache <= 'h0;
        vif.s01_axi_awregion <= 'h0;
        vif.s01_axi_awqos <= 'h0;
        
        
        for(to_ctr = 0; to_ctr <= txn.addr1; to_ctr++) begin
         @(posedge vif.s00_axi_aclk);
         if (vif.s01_axi_awready) break;
        end
        if (to_ctr == txn.addr1) `uvm_error("DRV","AWREADY timeout");
       
            out = (to_ctr == txn.addr1) ? 1 : 0;
            vif.s01_axi_awvalid <= 'b0;
            vif.s01_axi_awlen <= 'h0;
            
    endtask
    
    
    
    virtual protected task write_data_axi_full (log_seq_item txn, output bit out);
        int to_ctr, b_ctr;
        bit[7:0] dt_seed,wr_data;
        
        dt_seed = txn.data1;
        wr_data = $random(dt_seed);
        
        @(posedge vif.s00_axi_aclk);
         for(b_ctr = 0; b_ctr < txn.length; b_ctr++) begin
            vif.s01_axi_wvalid <= 'b1;
            vif.s01_axi_wstrb <= 'hf;
            vif.s01_axi_wdata <= wr_data;
        
            for(to_ctr = 0; to_ctr <= txn.data1; to_ctr++) begin
                @(posedge vif.s00_axi_aclk);
                if (vif.s01_axi_wready) break;
            end
            
            if(to_ctr == txn.data1) begin
                 `uvm_error("DRV","WREADY timeout");
                 out = 1;
                 break;
            end
            else
                out = 0;
                dt_seed = dt_seed + 4;
                wr_data = $random(dt_seed);
         end
         
         
         if(~out) begin
            vif.s01_axi_wdata <= wr_data;
            vif.s01_axi_wlast <= 'b1;
            @(posedge vif.s00_axi_aclk);
         end
         vif.s01_axi_wlast <= 'b0;
         vif.s01_axi_wvalid <= 'b0;
         vif.s01_axi_wstrb <= 'h0;
         vif.s01_axi_wdata <= 'h0;         
         
    endtask
    
    
 //**************WRITE RESPONSE*********************
 
    virtual protected task write_response (log_seq_item txn, output bit error);
    
        int to_ctr;
        @(posedge vif.s00_axi_aclk);
        
        vif.s01_axi_bready <= 'b1;
        for(to_ctr = 0; to_ctr <= 31; to_ctr++) begin
            @(posedge vif.s00_axi_aclk);
            if (vif.s01_axi_bvalid) break;
        end
            
        if(to_ctr == 31) begin
            `uvm_error("DRV","BVALID timeout");
        end
        
        else begin
            if (vif.s01_axi_bid != txn.axid) `uvm_error("DRV","BID mismatched");
	        if (vif.s01_axi_bresp != 'h0) `uvm_error("DRV","ERROR write response");
        end
        if (to_ctr == 31 || vif.s01_axi_bid != txn.axid || vif.s01_axi_bresp != 'h0)
	            error = 'b1;
        else error = 'b0;
                vif.s01_axi_bready <= 'b0;
                
    endtask
        
  //*********************READ***************
  
    virtual protected task read_axi_full(log_seq_item txn);
        bit error;
        `uvm_info("DRV", "read_axi_full", UVM_LOW)
        read_address_axi_full(txn,error);
        if(~error) read_data_axi_full(txn,error);
    endtask
    //****************READ ADDRES***************
    virtual protected task read_address_axi_full(log_seq_item txn, output bit out);
    
      int to_ctr;
      @(posedge vif.s00_axi_aclk);
      vif.s01_axi_arid    <= txn.axid;
      vif.s01_axi_araddr  <= txn.addr1;
      vif.s01_axi_arlen   <= txn.length;
      vif.s01_axi_arsize  <= 'b10;  //txn.bsize;
    //increment mode
      vif.s01_axi_arburst <= 'b01;
     /* case (txn.btype)
         0: vif.s01_axi_arburst <= 'b00;
         1 : vif.s01_axi_arburst <= 'b01;
         2 : vif.s01_axi_arburst <= 'b10;
      endcase */
      
      vif.s01_axi_arprot  <= 'h0;
      vif.s01_axi_arvalid <= 'b1;
      for(to_ctr = 0; to_ctr <= 31; to_ctr++) begin
         @(posedge vif.s00_axi_aclk);
         if (vif.s01_axi_arready) break;
      end
      
      if (to_ctr == 31) `uvm_error("DRV","ARREADY timeout");
      out = (to_ctr == 31) ? 1 : 0;
      vif.s01_axi_arvalid <= 'b0;
      
    endtask
  //******************READ DATA********************
    virtual protected task read_data_axi_full(log_seq_item txn, output bit error);
    
            int to_ctr, d_ctr;
            bit out;      
            @(posedge vif.s00_axi_aclk);

            vif.s01_axi_rready <= 'b1;

      // receive data
            for(d_ctr = 0; d_ctr <= txn.length; d_ctr++) begin
            for(to_ctr = 0; to_ctr <= 31; to_ctr++) begin
            
            @(posedge vif.s00_axi_aclk);
            if (vif.s01_axi_rvalid) break;
            end
	        out = (to_ctr == 31) ? 1 : 0;
            
            if (to_ctr == 31) break;
            end // for (d_ctr = 0; d_ctr <= txn.length; d_ctr++)
            if (vif.s01_axi_rlast != 'b1) `uvm_error("DRV","RLAST not asserted");

            if (out == 1) begin
            `uvm_error("DRV","RVALID timeout");
            end
      
            else begin
	           if (vif.s01_axi_rid != txn.axid) `uvm_error("DRV","RID mismatched");
	           if (vif.s01_axi_rresp != 'h0) `uvm_error("DRV","ERROR read response");
            end

            if (out == 1 || vif.s01_axi_rid != txn.axid || vif.s01_axi_rresp != 'h0)
	           error = 'b1;
            else error = 'b0;

            vif.s00_axi_rready <= 'b0;
    
    endtask
    
    
//*********************RESET*****************
virtual protected task reset();
    forever begin
    
    @(negedge vif.s00_axi_aresetn);
     
     vif.s00_axi_awaddr  <= 32'h0;
     vif.s00_axi_awprot  <=  3'h0;
     vif.s00_axi_awvalid <=  1'b0;
     vif.s00_axi_wdata   <= 32'h0;
     vif.s00_axi_wstrb   <=  4'h0;
     vif.s00_axi_wvalid  <=  1'b0;
     vif.s00_axi_bready  <=  1'b1;
     vif.s00_axi_araddr  <= 32'h0;
     vif.s00_axi_arprot  <=  3'h0;
     vif.s00_axi_arvalid <=  1'b0;
     vif.s00_axi_rready  <=  1'b1;
    
     vif.s01_axi_awid      <= 'b0;
	 vif.s01_axi_awaddr    <= 'h0;
	 vif.s01_axi_awlen     <= 'h0;
     vif.s01_axi_awsize    <= 'h0;
     vif.s01_axi_awburst   <= 'h0;
     vif.s01_axi_awlock    <= 'h0;
     vif.s01_axi_awcache   <= 'h0;   
     vif.s01_axi_awprot    <= 'h0;
     vif.s01_axi_awqos     <= 'h0;
     vif.s01_axi_awregion  <= 'h0;
     vif.s01_axi_awvalid   <= 'h0;
	 vif.s01_axi_wdata     <= 'h0;
     vif.s01_axi_wstrb     <= 'h0;
     vif.s01_axi_wlast     <= 'h0;
     vif.s01_axi_wvalid    <= 'h0;
	 vif.s01_axi_bready    <= 'h0;
	 vif.s01_axi_arid      <= 'h0;
     vif.s01_axi_araddr    <= 'h0;
     vif.s01_axi_arlen     <= 'h0;
     vif.s01_axi_arsize    <= 'h0;
     vif.s01_axi_arburst   <= 'h0;
     vif.s01_axi_arlock    <= 'h0;
     vif.s01_axi_arcache   <= 'h0;
     vif.s01_axi_arprot    <= 'h0;
     vif.s01_axi_arqos     <= 'h0;
     vif.s01_axi_arregion  <= 'h0;
     vif.s01_axi_arvalid   <= 'h0;
	 vif.s01_axi_rready    <= 'h0;
    end
endtask

endclass : log_driver

`endif
