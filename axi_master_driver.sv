class axi_read_driver extends uvm_driver#(axi_read_xtn);
  `uvm_component_utils(axi_read_driver)

  virtual axi_read_if vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      axi_read_xtn xtn;
      seq_item_port.get_next_item(xtn);

      // Drive AR channel
      vif.ARADDR   <= xtn.araddr;
      vif.ARID     <= xtn.arid;
      vif.ARLEN    <= xtn.arlen;
      vif.ARVALID  <= 1;
      wait(vif.ARREADY);
      vif.ARVALID  <= 0;

      // Simulate simple read data
      repeat (xtn.arlen+1) begin
        vif.RDATA   <= $random;
        vif.RVALID  <= 1;
        vif.RID     <= xtn.arid;
        vif.RLAST   <= 0;
        wait(vif.RREADY);
      end
      vif.RLAST   <= 1;
      vif.RVALID  <= 0;

      seq_item_port.item_done();
    end
  endtask
endclass
