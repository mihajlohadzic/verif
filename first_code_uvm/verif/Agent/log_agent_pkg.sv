`ifndef LOG_AGENT_PKG_SV
 `define LOG_AGENT_PKG_SV

package log_agent_pkg;
	import uvm_pkg::*;
	`include "uvm_macros.svh"
	//iclude agent components : driver, monitor, sequence
	`include "sequencer.sv"
 	`include "log_seq_item.sv"
	`include "driver.sv"
	`include "monitor.sv"
	`include "agent.sv" 
	
	
	
endpackage



`endif

