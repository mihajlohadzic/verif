class log_agent_full extends uvm_agent;
   //component
   log_driver_full drv1;
   log_sequencer_full seqr1;
   log_monitor_full mon1;
   virtual interface axi_full_if vif1;
   // configuration
//   log_config cfg;
   
   int 	   value;   
   `uvm_component_utils_begin (log_agent_full)
      // `uvm_field_object(cfg, UVM_DEFAULT)
   `uvm_component_utils_end

    function new(string name = "log_agent_full", uvm_component parent = null);
       super.new(name,parent);
    endfunction // new

    function void build_phase(uvm_phase phase);
       super.build_phase(phase);
        /************Geting from configuration database*******************/
       if (!uvm_config_db#(virtual axi_full_if)::get(this, "", "axi_full_if", vif1))
         `uvm_fatal("NOVIF",{"virtual interface must be set:",get_full_name(),".vif"})
       
      // if(!uvm_config_db#(log_config)::get(this, "", "log_config", cfg))
       //  `uvm_fatal("NOCONFIG",{"Config object must be set for: ",get_full_name(),".cfg"})
       /*****************************************************************/
       
       
       
       
       /************xcSetting to configuration database********************/
       uvm_config_db#(virtual axi_full_if)::set(this, "*", "axi_full_if", vif1);
       /*****************************************************************/

          mon1 = log_monitor_full::type_id::create("mon1", this);
  //     if(cfg.is_active == UVM_ACTIVE) begin
           drv1 = log_driver_full::type_id::create("drv1", this);
           seqr1 = log_sequencer_full::type_id::create("seqr1", this);
      // end
    endfunction // build_phase

   
   function void connect_phase(uvm_phase phase);
       super.connect_phase(phase);
       //if(cfg.is_active == UVM_ACTIVE) begin
           drv1.seq_item_port.connect(seqr1.seq_item_export);
      // end
   endfunction : connect_phase

endclass : log_agent_full

