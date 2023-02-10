module log_verif_top;
	import uvm_pkg::*;
	`include "uvm_macros.svh"
	import log_test_pkg::*;
	
	logic clk;
	logic reset;
	
	
	//interface 
	axi_lite_if log_vif_1(clk,reset);
	axi_full_if log_vif_2(clk,reset);
	
        //DUT
	
	ip_module_v1_0 DUT(
	   .s00_axi_aclk (clk),
        .s00_axi_aresetn (reset),
        .s00_axi_awaddr (log_vif_1.s00_axi_awaddr),
        .s00_axi_awprot (log_vif_1.s00_axi_awprot),
        .s00_axi_awvalid (log_vif_1.s00_axi_awvalid),
        .s00_axi_awready (log_vif_1.s00_axi_awready),
        .s00_axi_wdata (log_vif_1.s00_axi_wdata ),
        .s00_axi_wstrb (log_vif_1.s00_axi_wstrb ),
        .s00_axi_wvalid (log_vif_1.s00_axi_wvalid ),
        .s00_axi_wready (log_vif_1.s00_axi_wready ),
        .s00_axi_bresp (log_vif_1.s00_axi_bresp ),
        .s00_axi_bvalid (log_vif_1.s00_axi_bvalid ),
        .s00_axi_bready (log_vif_1.s00_axi_bready ),
        .s00_axi_araddr (log_vif_1.s00_axi_araddr ),
        .s00_axi_arprot (log_vif_1.s00_axi_arprot),
        .s00_axi_arvalid (log_vif_1.s00_axi_arvalid ),
        .s00_axi_arready (log_vif_1.s00_axi_arready ),
        .s00_axi_rdata (log_vif_1.s00_axi_rdata ),
        .s00_axi_rresp (log_vif_1.s00_axi_rresp),
        .s00_axi_rvalid (log_vif_1.s00_axi_rvalid),
        .s00_axi_rready (log_vif_1.s00_axi_rready),
        
        .s01_axi_aclk (clk),
        .s01_axi_aresetn (reset),
        .s01_axi_awid (log_vif_2.s01_axi_awid) ,
        .s01_axi_awaddr (log_vif_2.s01_axi_awaddr) ,
        .s01_axi_awlen (log_vif_2.s01_axi_awlen) ,
        .s01_axi_awsize (log_vif_2.s01_axi_awsize) ,
        .s01_axi_awburst (log_vif_2.s01_axi_awburst) ,
        .s01_axi_awlock (log_vif_2.s01_axi_awlock) ,
        .s01_axi_awcache (log_vif_2.s01_axi_awcache) ,
        .s01_axi_awprot (log_vif_2.s01_axi_awprot) ,
        .s01_axi_awqos (log_vif_2.s01_axi_awqos) ,
        .s01_axi_awregion (log_vif_2.s01_axi_awregion) ,
        .s01_axi_awuser (log_vif_2.s01_axi_awuser) ,
        .s01_axi_awvalid (log_vif_2.s01_axi_awvalid) ,
        .s01_axi_awready (log_vif_2.s01_axi_awready) ,
        .s01_axi_wdata (log_vif_2.s01_axi_wdata) ,
        .s01_axi_wstrb (log_vif_2.s01_axi_wstrb) ,
        .s01_axi_wlast (log_vif_2.s01_axi_wlast) ,
        .s01_axi_wuser (log_vif_2.s01_axi_wuser) ,
        .s01_axi_wvalid (log_vif_2.s01_axi_wvalid) ,
        .s01_axi_wready (log_vif_2.s01_axi_wready) ,
        .s01_axi_bid (log_vif_2.s01_axi_bid) ,
        .s01_axi_bresp (log_vif_2.s01_axi_bresp) ,
        .s01_axi_buser (log_vif_2.s01_axi_buser) ,
        .s01_axi_bvalid (log_vif_2.s01_axi_bvalid) ,
        .s01_axi_bready (log_vif_2.s01_axi_bready) ,
        .s01_axi_arid (log_vif_2.s01_axi_arid) ,
        .s01_axi_araddr (log_vif_2.s01_axi_araddr),
        .s01_axi_arlen (log_vif_2.s01_axi_arlen),
        .s01_axi_arsize (log_vif_2.s01_axi_arsize),
        .s01_axi_arburst(log_vif_2.s01_axi_arburst),
        .s01_axi_arlock (log_vif_2.s01_axi_arlock),
        .s01_axi_arcache (log_vif_2.s01_axi_arcache),
        .s01_axi_arprot (log_vif_2.s01_axi_arprot ),
        .s01_axi_arqos (log_vif_2.s01_axi_arqos ),
        .s01_axi_arregion (log_vif_2.s01_axi_arregion),
        .s01_axi_aruser (log_vif_2.s01_axi_aruser ),
        .s01_axi_arvalid (log_vif_2.s01_axi_arvalid ),
        .s01_axi_arready (log_vif_2.s01_axi_arready ),
        .s01_axi_rid (log_vif_2.s01_axi_rid ),
        .s01_axi_rdata (log_vif_2.s01_axi_rdata ),
        .s01_axi_rresp (log_vif_2.s01_axi_rresp),
        .s01_axi_rlast (log_vif_2.s01_axi_rlast ),
        .s01_axi_ruser (log_vif_2.s01_axi_ruser ),
        .s01_axi_rvalid (log_vif_2.s01_axi_rvalid ),
        .s01_axi_rready (log_vif_2.s01_axi_rready)
			
	);
	
	  // run test
   	initial begin
	   uvm_config_db#(virtual axi_lite_if)::set(null, "uvm_test_top.env", "log_if_1",log_vif_1);
	    uvm_config_db#(virtual axi_full_if)::set(null, "uvm_test_top.env", "log_if_2",log_vif_2);
	   
	   //uvm_config_db#(virtual log_if_1)::set(null, "uvm_test_top.env", "log_if_2",log_vif_2);
      	   run_test();
   	end

   // clock and reset init.
   initial begin // clock and reset init.
    
     /*  s00_axi_aclk <= 1;                  
       s00_axi_aresetn <= 0;
       
       s01_axi_aclk <= 1;                  
       s01_axi_aresetn <= 0;
       
       for (int i = 0; i < 8; i++) begin
	   @(posedge s00_axi_aclk);
	   @(posedge s01_axi_aclk);
       end
       s00_axi_aresetn <= 7'h7f;
       s01_axi_aresetn <= 7'h7f;
   	*/
		clk <=1;
		reset <= 0;
		
		for(int i = 0; i < 8; i++) begin
		@(posedge clk);
		end
		reset <= 7'h7f;
   end

   // clock generation
   /*always #50 s00_axi_aclk = ~s00_axi_aclk;
   always #50 s01_axi_aclk = ~s01_axi_aclk;*/
   always #50 clk = ~clk;
   
   
endmodule : log_verif_top
