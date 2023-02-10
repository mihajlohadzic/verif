`ifndef LOG_SEQUENCER_SV
 `define LOG_SEQUENCER_SV
class log_sequencer extends uvm_sequencer#(log_seq_item);
	`uvm_component_utils(log_sequencer)

	function new(string name = "log_sequencer", uvm_component parent = null);
		super.new(name,parent);
	endfunction
endclass : log_sequencer

class log_sequencer_full extends uvm_sequencer#(log_seq_item_full);
	`uvm_component_utils(log_sequencer_full)

	function new(string name = "log_sequencer_full", uvm_component parent = null);
		super.new(name,parent);
	endfunction
endclass : log_sequencer_full

`endif
