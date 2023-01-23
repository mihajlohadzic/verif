module log_verif_top;
	import uvm_pkg::*;
	`include "uvm_macros.svh"
	import log_test_pkg::*;
	
	logic s00_axi_aclk;
	logic s00_axi_aresetn;
	logic s01_axi_aclk;
	logic s01_axi_aresetn;
	//interface 
	log_if log_vif(s00_axi_aclk, s00_axi_aresetn);
        //DUT
	ip_module_v1_0 DUT(
	    .s00_axi_aclk (s00_axi_aclk),
        .s00_axi_aresetn (s00_axi_aresetn),
        .s00_axi_awaddr (log_vif.s00_axi_awaddr),
        .s00_axi_awprot (log_vif.s00_axi_awprot),
        .s00_axi_awvalid (log_vif.s00_axi_awvalid),
        .s00_axi_awready (log_vif.s00_axi_awready),
        .s00_axi_wdata (log_vif.s00_axi_wdata ),
        .s00_axi_wstrb (log_vif.s00_axi_wstrb ),
        .s00_axi_wvalid (log_vif.s00_axi_wvalid ),
        .s00_axi_wready (log_vif.s00_axi_wready ),
        .s00_axi_bresp (log_vif.s00_axi_bresp ),
        .s00_axi_bvalid (log_vif.s00_axi_bvalid ),
        .s00_axi_bready (log_vif.s00_axi_bready ),
        .s00_axi_araddr (log_vif.s00_axi_araddr ),
        .s00_axi_arprot (log_vif.s00_axi_arprot),
        .s00_axi_arvalid (log_vif.s00_axi_arvalid ),
        .s00_axi_arready (log_vif.s00_axi_arready ),
        .s00_axi_rdata (log_vif.s00_axi_rdata ),
        .s00_axi_rresp (log_vif.s00_axi_rresp),
        .s00_axi_rvalid (log_vif.s00_axi_rvalid),
        .s00_axi_rready (log_vif.s00_axi_rready),
        //AXI FULL
	    .s01_axi_aclk (s01_axi_aclk),
        .s01_axi_aresetn (s01_axi_aresetn),
        .s01_axi_awid (log_vif.s01_axi_awid) ,
        .s01_axi_awaddr (log_vif.s01_axi_awaddr) ,
        .s01_axi_awlen (log_vif.s01_axi_awlen) ,
        .s01_axi_awsize (log_vif.s01_axi_awsize) ,
        .s01_axi_awburst (log_vif.s01_axi_awburst) ,
        .s01_axi_awlock (log_vif.s01_axi_awlock) ,
        .s01_axi_awcache (log_vif.s01_axi_awcache) ,
        .s01_axi_awprot (log_vif.s01_axi_awprot) ,
        .s01_axi_awqos (log_vif.s01_axi_awqos) ,
        .s01_axi_awregion (log_vif.s01_axi_awregion) ,
        .s01_axi_awuser (log_vif.s01_axi_awuser) ,
        .s01_axi_awvalid (log_vif.s01_axi_awvalid) ,
        .s01_axi_awready (log_vif.s01_axi_awready) ,
        .s01_axi_wdata (log_vif.s01_axi_wdata) ,
        .s01_axi_wstrb (log_vif.s01_axi_wstrb) ,
        .s01_axi_wlast (log_vif.s01_axi_wlast) ,
        .s01_axi_wuser (log_vif.s01_axi_wuser) ,
        .s01_axi_wvalid (log_vif.s01_axi_wvalid) ,
        .s01_axi_wready (log_vif.s01_axi_wready) ,
        .s01_axi_bid (log_vif.s01_axi_bid) ,
        .s01_axi_bresp (log_vif.s01_axi_bresp) ,
        .s01_axi_buser (log_vif.s01_axi_buser) ,
        .s01_axi_bvalid (log_vif.s01_axi_bvalid) ,
        .s01_axi_bready (log_vif.s01_axi_bready) ,
        .s01_axi_arid (log_vif.s01_axi_arid) ,
	    .s01_axi_araddr (log_vif.s01_axi_araddr),
		.s01_axi_arlen (log_vif.s01_axi_arlen),
		.s01_axi_arsize (log_vif.s01_axi_arsize),
		.s01_axi_arburst(log_vif.s01_axi_arburst),
		.s01_axi_arlock (log_vif.s01_axi_arlock),
		.s01_axi_arcache (log_vif.s01_axi_arcache),
		.s01_axi_arprot (log_vif.s01_axi_arprot ),
		.s01_axi_arqos (log_vif.s01_axi_arqos ),
		.s01_axi_arregion (log_vif.s01_axi_arregion),
		.s01_axi_aruser (log_vif.s01_axi_aruser ),
		.s01_axi_arvalid (log_vif.s01_axi_arvalid ),
		.s01_axi_arready (log_vif.s01_axi_arready ),
		.s01_axi_rid (log_vif.s01_axi_rid ),
		.s01_axi_rdata (log_vif.s01_axi_rdata ),
		.s01_axi_rresp (log_vif.s01_axi_rresp),
		.s01_axi_rlast (log_vif.s01_axi_rlast ),
		.s01_axi_ruser (log_vif.s01_axi_ruser ),
		.s01_axi_rvalid (log_vif.s01_axi_rvalid ),
		.s01_axi_rready (log_vif.s01_axi_rready)	
	);
	
	  // run test
   	initial begin
	   uvm_config_db#(virtual log_if)::set(null, "uvm_test_top.env", "log_if",log_vif);
      	   run_test();
   	end

   // clock and reset init.
   initial begin // clock and reset init.
   
       s00_axi_aclk <= 1;
       s01_axi_aclk <= 1;

       s00_axi_aresetn <= 0;
       s01_axi_aresetn <= 0;
       
       for (int i = 0; i < 8; i++) begin
	   @(posedge s00_axi_aclk);
	   @(posedge s01_axi_aclk);
       end
       s00_axi_aresetn <= 7'h7f;
       s01_axi_aresetn <= 7'h7f;
   end

   // clock generation
   always #100 s00_axi_aclk = ~s00_axi_aclk;
   always #100 s01_axi_aclk = ~s01_axi_aclk;
   
   
endmodule : log_verif_top
