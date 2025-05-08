class axi_write_coverage extends uvm_subscriber #(axi_write_txn);

  `uvm_component_utils(axi_write_coverage)

  axi_write_txn txn;
  real cov;

  function new(string name = "", uvm_component parent = null);
    super.new(name, parent);
    write_cov = new();
  endfunction

  covergroup write_cov;
    option.per_instance = 1;

    coverpoint txn.awaddr { //write address channel - 32 bit address
      bins low[] = {[32'h0000_0000 : 32'h0000_FFFF]}; // 64KB
      bins mid[] = {[32'h0001_0000 : 32'h0FFF_FFFF]}; // general memory region
      bins high[] = {[32'h1000_0000 : 32'hFFFF_EFFF]}; // upper address space
      bins boundary_check[] = {[32'hFFFF_FFF0 : 32'hFFFF_FFFF]}; // edge cases
  } 
      
   coverpoint txn.awlen {
       bins burst_lengths[] = {[0:15]};
   }
      
   coverpoint txn.awsize {
       bins size_1B = {0};   // 1 byte
       bins size_2B = {1};   // 2 bytes
       bins size_4B = {2};   // 4 bytes
       bins size_8B = {3};   // 8 bytes
       bins size_16B = {4};  // 16 bytes
       bins size_32B = {5}; // 32 bytes
    }
      
    coverpoint txn.awburst { // type of burst
       bins fixed = {0};
       bins incr  = {1};
       bins wrap  = {2};
    }
      
    coverpoint txn.wstrb { // Write Data Channel
       bins wstrb_all_1 = {4'hF};  //all bytes are active
       bins wstrb_all_0 = {4'h0};  // no bytes are active
       bins wstrb_partial[] = {[1:14]}; // some bytes are active 
   }
      
       coverpoint txn.wlast {
         bins last = {1};
         bins not_last = {0};
     }
      
       coverpoint txn.bresp { // Write Response Channel
          bins ok = {3'b000};
          bins exokay = {3'b001};
          bins slverr = {3'b010};
          bins decerr = {3'b011};
          bins defer  = {3'b100};
          bins transfault = {3'b101};
          bins reserved = {3'b110};
          bins unsupported = {3'b111};
    }
      
      cross AWBURST, AWSIZE; // burst type vs size
      
    endgroup: write_cov

  // Write method (called when a transaction is seen)
  function void write(axi_write_txn t);
    txn = t;
    write_cov.sample();
  endfunction

  function void extract_phase(uvm_phase phase);
    super.extract_phase(phase);
    cov = write_cov.get_coverage();
  endfunction

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info(get_type_name(), $sformatf("AXI Write Channel Coverage: %0.2f%%", cov), UVM_MEDIUM)
  endfunction

endclass: axi_write_coverage
