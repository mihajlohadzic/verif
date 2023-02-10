`ifndef AXI_LITE_IF_SV
 `define AXI_LITE_IF_SV

interface axi_lite_if (input clk, logic reset);

   parameter WIDTH = 8;
   parameter SIZE = 10;
   parameter WIDTH_KERNEL = 5;
   parameter SIZE_KERNEL = 5;
   //-- Parameters of Axi Slave Bus Interface 
   parameter C_S00_AXI_DATA_WIDTH    = 32;
   parameter C_S00_AXI_ADDR_WIDTH = 5;

	
//-- Ports of Axi Slave Bus Interface S00_AXI


   logic [C_S00_AXI_ADDR_WIDTH-1 : 0]         s00_axi_awaddr;
   logic [2 : 0] 			      s00_axi_awprot;
   logic 		                      s00_axi_awvalid;
   logic	                              s00_axi_awready; //out
   logic [C_S00_AXI_DATA_WIDTH-1 : 0]         s00_axi_wdata;
   logic [(C_S00_AXI_DATA_WIDTH/8)-1 : 0]     s00_axi_wstrb;
   logic 				      s00_axi_wvalid;
   logic	                              s00_axi_wready;  //out
   logic [1 : 0]                              s00_axi_bresp;   //out
   logic 		                      s00_axi_bvalid;  //out
   logic	                              s00_axi_bready;
   logic [C_S00_AXI_ADDR_WIDTH-1 : 0]         s00_axi_araddr;
   logic [2 : 0] 			      s00_axi_arprot;
   logic 		                      s00_axi_arvalid;
   logic	                              s00_axi_arready; //out
   logic [C_S00_AXI_DATA_WIDTH-1 : 0]         s00_axi_rdata;   //out
   logic [1 : 0] 			      s00_axi_rresp;   //out
   logic                                      s00_axi_rvalid;  //out
   logic	                              s00_axi_rready;

endinterface : axi_lite_if

interface axi_full_if (input clk, logic reset);

   parameter WIDTH = 8;
   parameter SIZE = 10;
   parameter WIDTH_KERNEL = 5;
   parameter SIZE_KERNEL = 5;
   
   //-- Parameters of Axi Slave Bus Interface S01_AXI
   parameter C_S01_AXI_ID_WIDTH      = 1;
   parameter C_S01_AXI_DATA_WIDTH    = 32;
   parameter C_S01_AXI_ADDR_WIDTH    = 12;
   parameter C_S01_AXI_AWUSER_WIDTH  = 1;
   parameter C_S01_AXI_ARUSER_WIDTH  = 1;
   parameter C_S01_AXI_WUSER_WIDTH   = 1;
   parameter C_S01_AXI_RUSER_WIDTH   = 1;
   parameter C_S01_AXI_BUSER_WIDTH   = 1;
   
	
   //AXI FULL 
  
   logic [C_S01_AXI_ID_WIDTH-1 : 0]            s01_axi_awid;
   logic [C_S01_AXI_ADDR_WIDTH-1 : 0]          s01_axi_awaddr;
   logic [7 : 0]                               s01_axi_awlen;
   logic [2 : 0]                               s01_axi_awsize;
   logic [1 : 0]                               s01_axi_awburst;
   logic                                       s01_axi_awlock;
   logic [3 : 0]                               s01_axi_awcache;
   logic [2 : 0]                               s01_axi_awprot;
   logic [3 : 0]                               s01_axi_awqos;
   logic [3 : 0]                               s01_axi_awregion;
   logic [C_S01_AXI_AWUSER_WIDTH-1 : 0]        s01_axi_awuser;
   logic                                       s01_axi_awvalid;
   logic                                       s01_axi_awready; //out
   logic [C_S01_AXI_DATA_WIDTH-1 : 0]          s01_axi_wdata;
   logic [(C_S01_AXI_DATA_WIDTH/8)-1 : 0]      s01_axi_wstrb;
   logic                                       s01_axi_wlast;
   logic [C_S01_AXI_WUSER_WIDTH-1 : 0]         s01_axi_wuser;
   logic                                       s01_axi_wvalid;
   logic                                       s01_axi_wready; //out 
   logic [C_S01_AXI_ID_WIDTH-1 : 0]            s01_axi_bid; //out
   logic [1 : 0]                               s01_axi_bresp; //out
   logic [C_S01_AXI_BUSER_WIDTH-1 : 0]         s01_axi_buser; //out
   logic                                       s01_axi_bvalid; //out
   logic                                       s01_axi_bready;
   logic [C_S01_AXI_ID_WIDTH-1 : 0] 	                s01_axi_arid;
   logic  [C_S01_AXI_ADDR_WIDTH-1 : 0]		        s01_axi_araddr;
   logic	 [7 : 0]	                        s01_axi_arlen;
   logic	 [2 : 0]	                        s01_axi_arsize;
   logic	 [1 : 0]	                        s01_axi_arburst;
   logic		                                s01_axi_arlock;
   logic	 [3 : 0]	                        s01_axi_arcache;
   logic	 [2 : 0]	                        s01_axi_arprot;
   logic	 [3 : 0]	                        s01_axi_arqos;
   logic         [3 : 0] 	                        s01_axi_arregion;
   logic	 [C_S01_AXI_ARUSER_WIDTH-1 : 0]	        s01_axi_aruser;
   logic		                                s01_axi_arvalid;
   logic		                                s01_axi_arready; //out
   logic         [C_S01_AXI_ID_WIDTH-1 : 0]		s01_axi_rid; //out
   logic	 [C_S01_AXI_DATA_WIDTH-1 : 0]	        s01_axi_rdata;//out
   logic	 [1 : 0]	                        s01_axi_rresp; //out
   logic		                                s01_axi_rlast; //out
   logic	 [C_S01_AXI_RUSER_WIDTH-1 : 0]	        s01_axi_ruser; //out
   logic		                                s01_axi_rvalid; //out
   logic 	                                        s01_axi_rready;
   
//-- Ports of Axi Slave Bus Interface S01_AXI
endinterface : axi_full_if


`endif

