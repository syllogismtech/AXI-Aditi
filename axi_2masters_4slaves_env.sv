class axi_env extends uvm_env;
  `uvm_component_utils(axi_env)

  axi_driver driver;
  axi_monitor monitor;
  axi_scoreboard scoreboard;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    driver     = axi_driver::type_id::create("driver", this);
    monitor    = axi_monitor::type_id::create("monitor", this);
    scoreboard = axi_scoreboard::type_id::create("scoreboard", this);
  endfunction
endclass
