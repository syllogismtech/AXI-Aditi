class axi_read_test extends uvm_test;
  `uvm_component_utils(axi_read_test)

  axi_read_env env;

  function void build_phase(uvm_phase phase);
    env = axi_read_env::type_id::create("env", this);
  endfunction
endclass
