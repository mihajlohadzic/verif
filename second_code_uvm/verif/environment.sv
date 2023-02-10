`ifndef LOG_ENV_SV
 `define LOG_ENV_SV

class log_env extends uvm_env;
  
   log_agent agent1;
   log_agent_full agent2;
   
	log_config cfg;
	virtual interface axi_lite_if vif;
	virtual interface axi_full_if vif1;
   `uvm_component_utils (log_env)

   function new (string name = "log_env", uvm_component parent = null);
      super.new(name,parent);
   endfunction // new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      //*************Geting from configuration database****************************//
      if (!uvm_config_db#(virtual axi_lite_if)::get(this, "", "log_if_1", vif));
	  if (!uvm_config_db#(virtual axi_full_if)::get(this, "", "log_if_2", vif1));
     
      //if (!uvm_config_db#(virtual log_if)::get(this, "", "log_if_2", vif_2))
       
      
     // if(!uvm_config_db#(log_config)::get(this, "log_config",cfg)) 
      //   `uvm_fatal("NOCONFIG",{"Config object must be set for: ",get_full_name(),".cfg"})


      //*************Setting to configuration database****************************//
       uvm_config_db#(log_config)::set(this, "*agent", "log_config", cfg);
       
       uvm_config_db#(virtual axi_lite_if)::set(this, "interface1_agent", "axi_lite_if", vif);
      
       uvm_config_db#(virtual axi_full_if)::set(this, "interface2_agent", "axi_full_if", vif1);
       
       agent1 = log_agent::type_id::create("interface1_agent",this);
       agent2 = log_agent_full::type_id::create("interface2_agent", this);
      
   endfunction : build_phase
   
   
endclass :log_env


`endif
