class axi_read_env extends uvm_env;
  `uvm_component_utils(axi_read_env)

  axi_read_agent agent;
  axi_read_scoreboard sb;

  function void build_phase(uvm_phase phase);
    agent = axi_read_agent::type_id::create("agent", this);
    sb = axi_read_scoreboard::type_id::create("sb", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    agent.mon.ap_mon.connect(sb.analysis_imp);
  endfunction
endclass
