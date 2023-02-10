`ifndef TEST_BASE_SV
 `define TEST_BASE_SV

class test_base extends uvm_test;

   `uvm_component_utils(test_base)

   log_env env;
   log_config cfg;
   
   
   function new(string name = "test_base", uvm_component parent = null);
      super.new(name,parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      cfg = log_config::type_id::create("cfg");
      uvm_config_db#(log_config)::set(this,"env","log_config",cfg);
      env = log_env::type_id::create("env",this);
   endfunction : build_phase

   function void end_of_elaboration_phase(uvm_phase phase);
      super.end_of_elaboration_phase(phase);
      uvm_top.print_topology();
   endfunction: end_of_elaboration_phase

   function void init_vseq(virtual_seq vseq);
      vseq.sequencer_lite_if = env.agent1.seqr;
	  vseq.sequencer_full_if = env.agent2.seqr1;
      
   endfunction:init_vseq
   
endclass : test_base
`endif
