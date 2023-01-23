`ifndef LOG_TEST_PKG_SV
 `define LOG_TEST_PKG_SV

package log_test_pkg;

	import uvm_pkg::*;
	`include "uvm_macros.svh"
	import log_agent_pkg::*;
	
	
	
	import log_seq_pkg::*;
	import configurations_pkg::*;
	
	`include "environment.sv"
	`include "test_base.sv"
	`include "test_simple.sv"
	`include "test_simple2.sv"
	

endpackage: log_test_pkg

`include "log_if.sv"


`endif
