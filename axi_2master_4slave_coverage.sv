    class axi_coverage extends uvm_subscriber #(axi_transaction);
    
    `uvm_component_utils(axi_coverage)
    
    function new(string name = "", uvm_component parent);
    super.new(name, parent);
    covgrp = new();
    endfunction
    
    axi_transaction txn;
    real cov;
    
    //-------------------------------------------------------------------------
    covergroup covgrp;
    option.per_instance = 1;

        // Address coverage (assume 32-bit address space, split into ranges)
        coverpoint txn.addr {
          bins low     = {[32'h0000_0000 : 32'h0000_0FFF]};
          bins mid     = {[32'h0000_1000 : 32'h0000_1FFF]};
          bins high    = {[32'h0000_2000 : 32'h0000_FFFF]};
          bins invalid = default;
        }
        
        // Burst length (ARLEN / AWLEN): valid values [0:15] means 1 to 16 beats
        coverpoint txn.burst_len {
          bins single      = {0};
          bins short_burst = {[1:3]};
          bins med_burst   = {[4:7]};
          bins long_burst  = {[8:15]};
        }
        
        // Burst type (ARBURST / AWBURST)
        coverpoint txn.burst_type {
          bins FIXED = {2'b00};
          bins INCR  = {2'b01};
          bins WRAP  = {2'b10};
        }
        
        // Response type coverage (RRESP / BRESP)
        coverpoint txn.resp {
          bins OKAY   = {2'b00};
          bins EXOKAY = {2'b01};
          bins SLVERR = {2'b10};
          bins DECERR = {2'b11};
        }
        
        // Master ID coverage
        coverpoint txn.master_id {
          bins master_0 = {0};
          bins master_1 = {1};
        }
        
        // Slave ID coverage (assume 4 slaves: 0-3)
        coverpoint txn.slave_id {
          bins slave_0 = {0};
          bins slave_1 = {1};
          bins slave_2 = {2};
          bins slave_3 = {3};
        }
        
        // Read or Write Channel type
        coverpoint txn.cmd_type {
          bins READ  = {READ};
          bins WRITE = {WRITE};
        }
        
        // Optional: Cross coverage
        BURST_LEN_X_TYPE: cross burst_len, burst_type;
        MASTER_SLAVE_ACCESS: cross master_id, slave_id;
    endgroup : covgrp

  //-------------------------------------------------------------------------
  function void write(axi_transaction t);
  txn = t;
  covgrp.sample();
  endfunction
  
  function void extract_phase(uvm_phase phase);
  super.extract_phase(phase);
  cov = covgrp.get_coverage();
  endfunction
  
  function void report_phase(uvm_phase phase);
  super.report_phase(phase);
  `uvm_info(get_type_name(), $sformatf("Total AXI Coverage = %0.2f%%", cov), UVM_MEDIUM)
  endfunction
  
  endclass : axi_coverage
