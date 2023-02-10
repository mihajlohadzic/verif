`ifndef LOG_SIMPLE_SEQ_SV
 `define LOG_SIMPLE_SEQ_SV
 
//Axi Lite sequence
class log_simple_seq extends log_base_seq;
 `uvm_object_utils (log_simple_seq)
   function new(string name = "log_simple_seq");
      super.new(name);
   endfunction
   
   virtual task body();
	log_seq_item item;
	
	
	bit [3 : 0] addr;
	`uvm_info("SEQ", "executing...WR->WR->RD->RD", UVM_LOW)
	
	for (addr = 0; addr < 8; addr++)begin
		`uvm_create(item)
		item.addr   = $random();
	 	item.trans  = addr[2] ? 1 : 0;
         	item.cycles = 1;//$urandom_range(2,10);
         	item.data   = $urandom_range(0, 12);
        	`uvm_send(item);
        	
	end	
       
   endtask
endclass
//Axi Full sequence

class log_simple_seq_full extends log_base_seq1;
  `uvm_object_utils (log_simple_seq_full)
  
   function new(string name = "log_simple_seq_full");
      super.new(name);
   endfunction
   
   virtual task body();
   log_seq_item_full item_full;
   bit [3:0] addr;
   `uvm_info("SEQ", "executing...WR->WR->RD->RD", UVM_LOW)
   
       for(addr = 0; addr < 8; addr ++) begin
        `uvm_create(item_full)
        
         item_full.axid = $urandom();
	 item_full.addr1   = $urandom();
	 item_full.data1   = $urandom();
	 item_full.trans1  = addr[0] ? 1 : 0;
         item_full.cycles = 1;//$urandom_range(2,10);
         item_full.length = $urandom();
         item_full.bsize = $urandom();
         item_full.btype = $urandom();
         
        `uvm_send(item_full);
       end
   
   endtask
endclass




`endif






















