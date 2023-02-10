`ifndef LOG_VIRTUAL_SEQ_SV
 `define LOG_VIRTUAL_SEQ_SV

class virtual_seq extends log_base_seq;

    `uvm_object_utils (virtual_seq)

    uvm_sequencer #(log_seq_item) sequencer_lite_if;
    uvm_sequencer #(log_seq_item_full) sequencer_full_if;
    
    function new(string name = "virtual_seq");
	   super.new(name);
    endfunction

    virtual task body();

	   log_simple_seq      sequence_lite = log_simple_seq::type_id::create("interface1_seq_lite");
	   log_simple_seq_full sequence_full = log_simple_seq_full::type_id::create("interface2_seq_full");
	   
	   
	    sequence_lite.start(sequencer_lite_if);
	    sequence_full.start(sequencer_full_if);
	   
	   
    endtask : body

endclass : virtual_seq

`endif
