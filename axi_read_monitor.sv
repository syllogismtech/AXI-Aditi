class axi_read_monitor extends uvm_monitor;

  virtual axi_if vif;
  `uvm_component_utils(axi_read_monitor)

  uvm_analysis_port #(axi_read_addr_txn) ar_port;
  uvm_analysis_port #(axi_read_data_txn) r_port;

  event ar_event;
  event r_event;

  covergroup ar_cov @(posedge vif.aclk); // functionnal coverage points
    coverpoint vif.arid; // read request transaction id 
    coverpoint vif.araddr; // read re address 
    coverpoint vif.arburst;
    coverpoint vif.arlen;
    coverpoint vif.arsize;
  endgroup

  covergroup r_cov @(posedge vif.aclk);
    coverpoint vif.rid;
    coverpoint vif.rresp;
    coverpoint vif.rdata; 
  endgroup

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ar_port = new("ar_port", this);
    r_port  = new("r_port", this);

    ar_cov = new(); //constructor is initializing coverage groups of read request and read channel
    r_cov  = new();
  endfunction

  virtual function void build_phase(uvm_phase phase);
    if (!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif))
      `uvm_fatal("NO_VIF", "Virtual interface not set for axi_read_monitor")
  endfunction

  virtual task run_phase(uvm_phase phase);
    fork // for 2 parallel tasks 
      monitor_ar_channel();
      monitor_r_channel();
    join_none // let both tasks run independently
  endtask

  task monitor_ar_channel();
    axi_read_addr_txn ar_txn;
    forever begin
      @(posedge vif.aclk);
      if (vif.arvalid && vif.arready) begin
        ar_cov.sample();  // trigger the AR coverage group and 
        ar_txn = new(); // new transaction object created
        ar_txn.addr   = vif.araddr;
        ar_txn.burst  = vif.arburst;
        ar_txn.len    = vif.arlen;
        ar_txn.size   = vif.arsize;
        ar_txn.id     = vif.arid;
        ar_port.write(ar_txn);
        -> ar_event;
        `uvm_info(get_type_name(), $sformatf("Captured AR txn: %s", ar_txn.convert2string()), UVM_LOW)
      end
    end
  endtask

  task monitor_r_channel();
    axi_read_data_txn r_txn;
    forever begin
      @(posedge vif.aclk);
      if (vif.rvalid && vif.rready) begin
        r_cov.sample();  //  trigger R coverage group
        if (r_txn == null) begin
          r_txn = new();
          r_txn.id = vif.rid;
        end
        r_txn.data_queue.push_back(vif.rdata);
        r_txn.resp_queue.push_back(vif.rresp);
        if (vif.rlast) begin
          r_port.write(r_txn);
          -> r_event;
          `uvm_info(get_type_name(), $sformatf("Captured R txn: %s", r_txn.convert2string()), UVM_LOW)
          r_txn = null;
        end
      end
    end
  endtask

endclass
