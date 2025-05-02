class axi_read_env extends uvm_env;
  `uvm_component_utils(axi_read_env)

  axi_read_agent       agent;
  axi_read_scoreboard  scoreboard;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent      = axi_read_agent::type_id::create("agent", this);
    scoreboard = axi_read_scoreboard::type_id::create("scoreboard", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agent.mon.ap.connect(scoreboard.ap);
  endfunction
endclass
