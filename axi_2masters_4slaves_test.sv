class axi_test extends uvm_test;
  `uvm_component_utils(axi_test)

  axi_env env;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    env = axi_env::type_id::create("env", this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    axi_sequence seq;
    phase.raise_objection(this); // notify uvm that this component is doing some activity and preventing run phase to end prematurely
    seq = axi_sequence::type_id::create("seq");
    seq.start(env.driver);
    phase.drop_objection(this); // to tell the uvm that test is complete and now it can drop the run phase 
  endtask
endclass
