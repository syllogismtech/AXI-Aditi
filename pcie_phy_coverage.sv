class pcie_coverage extends uvm_subscriber #(pcie_sequence_item);

  `uvm_component_utils(pcie_coverage)

  function new(string name = "", uvm_component parent);
    super.new(name, parent);
    dut_cov = new(); //dut_cov is initialized 
  endfunction

  pcie_sequence_item txn;
  real cov; // this stores the final coverage percentage 

  covergroup dut_cov; // this covergroup will track all bins and cross coverage 
    option.per_instance = 1;

    coverpoint txn.pcie_gen { // this covergroup will check that which pcie gen is covered from gen 1 to gen 6
      bins gen1 = {1};
      bins gen2 = {2};
      bins gen3 = {3};
      bins gen4 = {4};
      bins gen5 = {5};
      bins gen6 = {6};
    }

    coverpoint txn.symbol_encoded_gen1_2 iff (txn.pcie_gen inside {1,2}) { // this coverpoint will check for 8b/10b encoding in gen 1-2
      bins encoded = {1}; // 8b/10b encoding is applied 
      bins raw     = {0}; //not applied
    }
  
    coverpoint txn.symbol_encoded iff (txn.pcie_gen inside {3,4,5}) { // this coverpoint will check for 128b/130b encoding in gen 3, 4, 5
      bins encoded = {1}; // 128b/130b encoding is applied 
      bins raw     = {0}; //not applied 
    }
      
    coverpoint txn.pam4_symbol iff (txn.pcie_gen == 6) { // as PAM-4 uses 4 volateg levels, so this covergroup is used to check that in gen 6 all 4 voltage levels are covered or not
      bins pam4_00 = {2'b00};
      bins pam4_01 = {2'b01};
      bins pam4_10 = {2'b10};
      bins pam4_11 = {2'b11};
    }

    coverpoint txn.flit_start iff (txn.pcie_gen == 6) { // this will check for flits when in gen 6  
      bins start_detected = {1};
    }

    coverpoint txn.flit_end iff (txn.pcie_gen == 6) { // if this is 1, this shows that the flit end is detected or the flit is terminated
      bins end_detected = {1};
    }

    coverpoint txn.fec_error iff (txn.pcie_gen == 6) {  // fec is in gen 6. this coverppoint is used for tracking of error that if error occured or not 
      bins error     = {1};
      bins no_error  = {0};
    }

    coverpoint txn.link_training_active { // if phy is in link training mode or is in normal operation mode 
      bins active     = {1}; // this means that the connection between Tx and Rx is in training
      bins not_active = {0}; 
    }

    coverpoint txn.link_width { // check for no. of lanes supported for transmiss
      bins x1  = {1};
      bins x2  = {2};
      bins x4  = {4};
      bins x8  = {8};
      bins x16 = {16};
      bins x32 = {32};
    }
    
    coverpoint txn.tx_data iff (txn.pcie_gen inside {1,2}) { // this coverpoint will check if our simulation has gone through each range of values or not.
      bins low_byte  = {[0:63]};
      bins mid_byte  = {[64:127]};
      bins high_byte = {[128:191]};
      bins full_byte = {[192:255]};
    }

    cross txn.pcie_gen, txn.link_width;
    cross txn.pcie_gen, txn.link_training_active;
    cross txn.pcie_gen, txn.pam4_symbol iff (txn.pcie_gen == 6);
    cross txn.pcie_gen, txn.fec_error iff (txn.pcie_gen == 6);

  endgroup : dut_cov

  function void write(pcie_sequence_item t);
    txn = t;
    dut_cov.sample(); // this will evaluate the values in dut_cov covergroup
  endfunction

  function void extract_phase(uvm_phase phase);
    super.extract_phase(phase);
    cov = dut_cov.get_coverage(); // this will give the overall coverage percentage 
  endfunction

  function void report_phase(uvm_phase phase); // the final coverage percentage will be written in the simulation log
    super.report_phase(phase);
    `uvm_info(get_type_name(), $sformatf("PCIe PHY Coverage = %0.2f%%", cov), UVM_MEDIUM)
  endfunction

endclass : pcie_coverage
