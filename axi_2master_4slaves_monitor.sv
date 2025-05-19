class axi_monitor extends uvm_monitor;
  `uvm_component_utils(axi_monitor)
  uvm_analysis_port #(axi_transaction) mon_ap;
  virtual axi_if vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    mon_ap = new("mon_ap", this);
  endfunction

  task run_phase(uvm_phase phase);
    axi_transaction tx;
    tx = axi_transaction::type_id::create("tx"); // new txn object (tx) is created using factory
    forever begin
      @(posedge vif.ACLK);
      if (vif.valid && vif.ready) begin
        tx.addr = vif.addr; 
        tx.len = vif.len;
        tx.size = vif.size;
        tx.burst = vif.burst;
        tx.is_read = 1'b0; // example
        tx.resp = vif.resp;
        mon_ap.write(tx);
      end
    end
  endtask
endclass
