class axi_agent extends uvm_agent;
`uvm_component_utils(axi_agent)

  axi_driver driver;
  axi_monitor monitor;
  axi_sequencer sequencer;

  // Agent activity control
  uvm_active_passive_enum is_active = UVM_ACTIVE;

function new(string name, uvm_component parent);
super.new(name, parent);
endfunction

virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(uvm_active_passive_enum)::get(this, "", "is_active", is_active)) begin
      is_active = UVM_ACTIVE;
    end
  
    if (is_active == UVM_ACTIVE) begin
      sequencer = axi_sequencer::type_id::create("sequencer", this);
      driver    = axi_driver   ::type_id::create("driver", this);
    end
  
    monitor = axi_monitor::type_id::create("monitor", this);
endfunction

virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
      if (is_active == UVM_ACTIVE) begin
      driver.seq_item_port.connect(sequencer.seq_item_export);
    end
endfunction
endclass
