`ifndef LOG_VIRTUAL_SEQ_SV
 `define LOG_VIRTUAL_SEQ_SV

class virtual_seq extends log_base_seq;

    `uvm_object_utils (virtual_seq)

    uvm_sequencer #(log_seq_item) interface1_seqr;
   
    
    function new(string name = "virtual_seq");
	   super.new(name);
    endfunction

    virtual task body();

	   log_simple_seq interface1_seq = log_simple_seq::type_id::create("interface1_seq1");
	   
	   interface1_seq.start(interface1_seqr);
	  
	
    endtask : body

endclass : virtual_seq

`endif
