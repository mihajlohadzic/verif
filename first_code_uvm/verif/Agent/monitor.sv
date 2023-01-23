`ifndef LOG_MONITOR_SV
	`define LOG_MONITOR_SV
	
class log_monitor extends uvm_monitor;


	virtual interface log_if vif;
	int id;
	
	uvm_analysis_port #(log_seq_item) item_collected_port;
	protected log_seq_item log_item;

	`uvm_component_utils_begin(log_monitor)
		`uvm_field_int(id, UVM_DEFAULT)
		`uvm_component_utils_end
		
	function new(string name = "log_monitor", uvm_component parent = null);
		super.new(name,parent);
		log_item = new();
		item_collected_port = new("item_collected_port", this);
		
	endfunction
	
	
	function void connect_phase(uvm_phase phase);
       super.connect_phase(phase);
       if (!uvm_config_db#(virtual log_if)::get(this, "", "log_if", vif))
         `uvm_fatal("NOVIF",{"virtual interface must be set:",get_full_name(),".vif"})
   endfunction
   
   task main_phase(uvm_phase phase);
   
				collect_axi_lite();
				collect_axi_full();
   endtask
	
	virtual protected task collect_axi_lite();
		bit valid = 0;
			forever begin
			
			log_item = new();
				if (vif.s00_axi_aresetn == 'b0)
					@(posedge vif.s00_axi_aresetn);
				if (vif.s00_axi_awvalid == 'b1) begin
				   log_item.trans = 0;	    
				   log_item.addr  = vif.s00_axi_awaddr[15:0];
				   @(posedge vif.s00_axi_awvalid);
				   log_item.data  = vif.s00_axi_wdata;
				   @(negedge vif.s00_axi_awvalid);
				   valid = 1;
				end
				else if (vif.s00_axi_arvalid == 'b1) begin
				   log_item.trans = 1;	    
				   log_item.addr  = vif.s00_axi_araddr[15:0];
				   @(posedge vif.s00_axi_rvalid);
				   log_item.data  = vif.s00_axi_rdata;
				   @(negedge vif.s00_axi_rvalid);
				   valid = 1;
				 end
				@(posedge vif.s00_axi_aclk);
			
				 if (valid == 'b1 ) begin
				   item_collected_port.write(log_item);
				 end
				 valid = 0;
			end
	endtask


	
	virtual protected task collect_axi_full();
		bit valid = 0;
		
		forever begin
			log_item = new();
			if(vif.s00_axi_aresetn == 'b0) @(posedge vif.s00_axi_aresetn);
			@(posedge vif.s00_axi_aclk);
			//axi write
			if(vif.s01_axi_awvalid) begin
				valid = 'b1;
				log_item.trans = 0;
				
				
				//get write address
				log_item.axid = vif.s01_axi_awid;
				log_item.addr = vif.s01_axi_awaddr;
				log_item.length = vif.s01_axi_awlen;
				log_item.bsize = vif.s01_axi_awsize;
			
				case(vif.s01_axi_awburst)
					'b00: log_item.btype = 0;
					'b01: log_item.btype = 1;	
					'b10: log_item.btype = 2;
				endcase
				
				@(posedge vif.s01_axi_wvalid);
				while(vif.s01_axi_wvalid) begin
					if(vif.s01_axi_wready) log_item.data1 = vif.s01_axi_wdata;
					@(posedge vif.s00_axi_aclk);
					if(vif.s01_axi_wlast) break;
				end
				
				while(vif.s01_axi_bvalid != 'b1 && vif.s01_axi_bready != 'b1) begin
					@(posedge vif.s00_axi_aclk);
				end
			end
			
			else if(vif.s01_axi_arvalid) begin
				valid  = 'b1;
				log_item.trans  = 1;
				// get read address
				log_item.axid   = vif.s01_axi_arid;
				log_item.addr   = vif.s01_axi_araddr;
				log_item.length = vif.s01_axi_arlen;
				log_item.bsize  = vif.s01_axi_arsize;
				case (vif.s01_axi_arburst)
				'b00: log_item.btype = 0;
				'b01: log_item.btype = 1;
				'b10: log_item.btype = 2;
				endcase
				
				@(posedge vif.s01_axi_rvalid);
				while(vif.s01_axi_rvalid) begin
					if(vif.s01_axi_rready) begin
						log_item.data1 = vif.s01_axi_rdata;
					end
					@(posedge vif.s00_axi_aclk);
					if(vif.s01_axi_rlast) break;
				end
			end
			
			else begin
				valid = 'b0;
			end
			
			if (valid == 'b1 ) begin
				item_collected_port.write(log_item);
			end
		end
		
	endtask

endclass
`endif