class axi_transaction extends uvm_sequence_item;
  rand bit is_read;
  rand bit [3:0] id;
  rand bit [31:0] addr;
  rand bit [3:0] len;
  rand bit [2:0] size;
  rand bit [1:0] burst;
  rand bit [31:0] data[];
  bit [1:0] resp;

  `uvm_object_utils(axi_transaction)

  function new(string name = "axi_transaction");
    super.new(name);
  endfunction
endclass
