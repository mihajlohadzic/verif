`ifndef LOG_SEQ_ITEM_FULL_SV
 `define LOG_SEQ_ITEM_FULL_SV
 
 class log_seq_item_full extends uvm_sequence_item;

           parameter WIDTH = 8;
	   parameter SIZE = 10;
	   parameter WIDTH_KERNEL = 5;
	   parameter SIZE_KERNEL = 5;
	   
           parameter C_S01_AXI_ID_WIDTH      = 1;
	   parameter C_S01_AXI_DATA_WIDTH    = 8; //32
	   parameter C_S01_AXI_ADDR_WIDTH    = 12;
	   parameter C_S01_AXI_AWUSER_WIDTH  = 1;
	   parameter C_S01_AXI_ARUSER_WIDTH  = 1;
	   parameter C_S01_AXI_WUSER_WIDTH   = 1;
	   parameter C_S01_AXI_RUSER_WIDTH   = 1;
	   parameter C_S01_AXI_BUSER_WIDTH   = 1;
	   
	    //Axi full
   	    rand bit [3:0]                                    axid;
            rand bit [C_S01_AXI_ADDR_WIDTH-1 : 0]             addr1;
            rand bit [C_S01_AXI_DATA_WIDTH-1:0]               data1;
            rand bit                                          trans1;
            rand bit   [7:0]                                  length;
            rand bit   [2:0]                                  bsize;
            rand bit   [2:0]                                  btype;
            int                                              cycles;
             
          constraint address_con {addr1 inside {12'h0,12'h400};}
   	  constraint data_con    {data1 inside {8'h5, 8'h8};}    
         constraint length_con  {length inside {8'h19, 8'h64};}
         
         `uvm_object_utils_begin(log_seq_item_full)
               `uvm_field_int(axid, UVM_DEFAULT)
        	`uvm_field_int(addr1, UVM_DEFAULT)
        	`uvm_field_int(data1,UVM_DEFAULT)
        	`uvm_field_int(trans1,UVM_DEFAULT)
        	`uvm_field_int(length, UVM_DEFAULT)
        	`uvm_field_int(bsize, UVM_DEFAULT)
        	`uvm_field_int(btype, UVM_DEFAULT)
        	`uvm_field_int(cycles, UVM_DEFAULT)
        `uvm_object_utils_end
            
        function new(string name = "log_seq_item_full");
 	    super.new(name);
       endfunction //new
       
endclass : log_seq_item_full

`endif
