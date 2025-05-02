class axi_read_test extends uvm_test;
  `uvm_component_utils(axi_read_test)

  axi_read_env env;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = axi_read_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    axi_read_seq seq = axi_read_seq::type_id::create("seq");
    seq.start(env.agent.drv);
  endtask
endclass
