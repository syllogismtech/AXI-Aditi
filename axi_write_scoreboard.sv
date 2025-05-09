class axi_write_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(axi_write_scoreboard)

  uvm_analysis_imp#(axi_write_transaction, axi_write_scoreboard) expected_ap; // exports to send the expected and actual transactions to scoreboard 
  uvm_analysis_imp#(axi_write_transaction, axi_write_scoreboard) actual_ap;

  axi_write_transaction expected_q[$]; // dynamic queues 
  axi_write_transaction actual_q[$];

  function new(string name, uvm_component parent); 
    super.new(name, parent);
    expected_ap = new("expected_ap", this);
    actual_ap   = new("actual_ap", this);
  endfunction

  function void write_expected(axi_write_transaction tr); // for expected transactions 
    `uvm_info(get_type_name(), $sformatf("Received expected transaction: %s", tr.convert2string()), UVM_MEDIUM)
    expected_q.push_back(tr); // stores the transaction in expected queue
  endfunction

  function void write_actual(axi_write_transaction tr);  // for actual transactions
    `uvm_info(get_type_name(), $sformatf("Received actual transaction: %s", tr.convert2string()), UVM_MEDIUM)
    actual_q.push_back(tr); // stores the transaction in actual queue 
    compare_transactions(); // calls this for comparing expected and actual transactions 
  endfunction

  function void compare_transactions(); // if any queue is empty then no omparison will be done 
    if (expected_q.size() == 0 || actual_q.size() == 0)
      return;

    axi_write_transaction exp_tr = expected_q.pop_front();  // takes 1st txn from the queue and compares it and then make the 2nd transaction as 1st transaction. this is based on FIFO.
    axi_write_transaction act_tr = actual_q.pop_front();

    if (!compare_tr(exp_tr, act_tr)) begin // if txn matches, log successful message and vice versa 
      `uvm_error(get_type_name(), $sformatf("Write transaction mismatch!\nExpected: %s\nActual:   %s",
                     exp_tr.convert2string(), act_tr.convert2string()))
    end else begin
      `uvm_info(get_type_name(), "Write transaction matched", UVM_LOW)
    end
  endfunction

  function bit compare_tr(axi_write_transaction exp, axi_write_transaction act); // comparison of each txn field-by-field 
    if (exp.awaddr !== act.awaddr) return 0;
    if (exp.awlen  !== act.awlen)  return 0;
    if (exp.awsize !== act.awsize) return 0;
    if (exp.awburst!== act.awburst)return 0;
    if (exp.wdata.size() != act.wdata.size()) return 0;

    foreach (exp.wdata[i]) begin // compares each word of data burst 
      if (exp.wdata[i] !== act.wdata[i]) return 0;
    end

    if (exp.bresp !== act.bresp) return 0;

    return 1; // if everything works, return 1 else 0(fail) 
  endfunction
endclass
