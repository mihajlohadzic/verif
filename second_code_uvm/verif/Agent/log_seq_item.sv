`ifndef LOG_SEQ_ITEM_SV
 `define LOG_SEQ_ITEM_SV

class log_seq_item extends uvm_sequence_item;
	
	   parameter WIDTH = 8;
	   parameter SIZE = 10;
	   parameter WIDTH_KERNEL = 5;
	   parameter SIZE_KERNEL = 5;
	   //-- Parameters of Axi Slave Bus Interface 
	   parameter C_S00_AXI_DATA_WIDTH    = 32;
	   parameter C_S00_AXI_ADDR_WIDTH = 3;
	    //-- Parameters of Axi Slave Bus Interface S01_AXI
	
		
           //Axi lite
            rand logic [C_S00_AXI_DATA_WIDTH-1 : 0]           addr; 
            rand bit [C_S00_AXI_DATA_WIDTH-1: 0] 	       data; //logic
            rand bit 	                                      trans;
            int                                          cycles = 4;
           
           
   constraint addr_con     {addr inside {0,8,12,16};}
   constraint data_con1    {data inside {8'h5, 8'h8, 8'h9, 8'h3,8'h11};}
   
  // constraint cycles_1 {cycles <= 4;}
     	
 `uvm_object_utils_begin(log_seq_item)
	`uvm_field_int(addr, UVM_DEFAULT)
        `uvm_field_int(data, UVM_DEFAULT)
        `uvm_field_int(trans, UVM_DEFAULT)
        `uvm_field_int(cycles, UVM_DEFAULT)
             
`uvm_object_utils_end
   
 function new(string name = "log_seq_item");
 	super.new(name);
 endfunction //new
 
endclass : log_seq_item

`endif



















