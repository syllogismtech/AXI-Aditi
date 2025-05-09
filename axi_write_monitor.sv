class axi_write_monitor extends uvm_monitor;

  `uvm_component_utils(axi_write_monitor)

  virtual axi_if axi_vif;

  uvm_analysis_port #(axi_write_txn) mon_ap;

  function new(string name = "axi_write_monitor", uvm_component parent = null);
    super.new(name, parent);
    mon_ap = new("mon_ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual axi_if)::get(this, "", "vif", axi_vif))
      `uvm_fatal(get_type_name(), "Virtual interface not set in config DB")
  endfunction

  task run_phase(uvm_phase phase);
    axi_write_txn txn;
    @(posedge axi_vif.clk);
    forever begin
      wait (axi_vif.AWVALID && axi_vif.AWREADY);  // ready - valid handshake for write request channel
      txn = axi_write_txn::type_id::create("txn");

      txn.awaddr  = axi_vif.AWADDR;  // write request channels are captured from here 
      txn.awlen   = axi_vif.AWLEN;
      txn.awsize  = axi_vif.AWSIZE;
      txn.awburst = axi_vif.AWBURST;

      wait (axi_vif.WVALID && axi_vif.WREADY);   // ready - valid handshake for write channel
      txn.wdata = axi_vif.WDATA;
      txn.wstrb = axi_vif.WSTRB;
      txn.wlast = axi_vif.WLAST;

      wait (axi_vif.BVALID && axi_vif.BREADY); // // ready - valid handshake for write response channel
      txn.bresp = axi_vif.BRESP;

      `uvm_info(get_type_name(), $sformatf("Captured AXI write txn: AWADDR=0x%0h WDATA=0x%0h WSTRB=%0b", txn.awaddr, txn.wdata, txn.wstrb), UVM_MEDIUM)
      mon_ap.write(txn); 

      @(posedge axi_vif.clk); // wait for next posedge of clock for further transactions.
    end
  endtask

endclass
