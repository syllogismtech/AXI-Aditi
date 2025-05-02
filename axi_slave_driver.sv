class axi_read_driver extends uvm_driver #(axi_read_xtn);
  virtual axi_if vif;

  `uvm_component_utils(axi_read_driver)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    if (!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "Virtual interface not set")
  endfunction

  task run_phase(uvm_phase phase);
    axi_read_xtn xtn;
    forever begin
      seq_item_port.get_next_item(xtn);

      // Wait for ARVALID from master
      @(posedge vif.clk iff vif.arvalid);
      vif.arready <= 1;
      xtn.araddr = vif.araddr;
      xtn.arid = vif.arid;
      #1;
      vif.arready <= 0;

      // Send RDATA response
      foreach (int i in [0:xtn.arlen]) begin
        @(posedge vif.clk);
        vif.rdata <= $random;
        vif.rid   <= xtn.arid;
        vif.rresp <= 0;
        vif.rvalid <= 1;
        vif.rlast  <= (i == xtn.arlen);
        wait (vif.rready);
        vif.rvalid <= 0;
      end

      seq_item_port.item_done();
    end
  endtask
endclass
