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

    // each slave can have 4kb of address 
        coverpoint txn.addr {
            bins slave0 = {[32'h0000_0000 : 32'h0000_0FFF]}; // 0 to 4095 bytes
            bins slave1 = {[32'h0000_1000 : 32'h0000_1FFF]}; // 4096 to 8191 bytes
            bins slave2 = {[32'h0000_2000 : 32'h0000_2FFF]}; // 8192 to 12287 bytes
            bins slave3 = {[32'h0000_3000 : 32'h0000_3FFF]}; // 12288 to 16383 bytes 
        }
        
        // Burst length (ARLEN / AWLEN): valid values [0:15] means 1 to 16 beats
        coverpoint txn.len {
          bins single      = {0};
          bins short_burst = {[1:3]};
          bins med_burst   = {[4:7]};
          bins long_burst  = {[8:15]};
        }
        
        // Burst type (ARBURST / AWBURST)
        coverpoint txn.burst {
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
        
        // Read or Write Channel type
        coverpoint txn.is_read {
            bins READ  = {1'b1};
            bins WRITE = {1'b0};
        }
        
        // Optional: Cross coverage
        cross txn.is_read, txn.burst;
        cross txn.len, txn.is_read;
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
      `uvm_info(get_type_name(), $sformatf("Total AXI Coverage = %0.2f%%", cov), UVM_LOW)
  endfunction
  
  endclass : axi_coverage
