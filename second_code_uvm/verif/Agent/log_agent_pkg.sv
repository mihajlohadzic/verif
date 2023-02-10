`ifndef LOG_AGENT_PKG_SV
 `define LOG_AGENT_PKG_SV

package log_agent_pkg;
	import uvm_pkg::*;
	`include "uvm_macros.svh"
	//iclude agent components : driver, monitor, sequence
	
	
 	
 	`include "log_seq_item.sv"
 	`include "log_seq_item_full.sv"
	`include "driver.sv"
	`include "driver_full.sv"
	//`include "driver_lite.sv"
	`include "monitor.sv"
	`include "monitor_full.sv"
	
	//`include "monitor_full.sv"
	`include "sequencer.sv"
	`include "agent_full.sv"
 	`include "agent.sv"
	
	
	
	
	
endpackage



`endif

