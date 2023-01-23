`ifndef LOG_SEQ_PKG_SV
 `define LOG_SEQ_PKG_SV
package log_seq_pkg;
	import uvm_pkg::*;
	`include "uvm_macros.svh"	
	import log_agent_pkg::log_seq_item;
	import log_agent_pkg::log_sequencer;
	

	`include "log_base_seq.sv"
	`include "log_simple_seq.sv"
	`include "virtual_sequence.sv"
endpackage: log_seq_pkg;
`endif
