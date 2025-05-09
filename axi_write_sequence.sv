class axi_write_sequence extends uvm_sequence#(axi_write_transaction);
  `uvm_object_utils(axi_write_sequence)

  function new(string name = "axi_write_sequence");
    super.new(name);
  endfunction

  task body();
    axi_write_transaction tr = axi_write_transaction::type_id::create("tr");
    tr.awaddr = 32'hA000_0000;
    tr.awlen = 4;
    tr.awsize = 2;
    tr.awburst = 1;
    repeat (4) tr.wdata.push_back($urandom);

    start_item(tr);
    finish_item(tr);
  endtask
endclass
