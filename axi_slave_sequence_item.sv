class axi_read_xtn extends uvm_sequence_item;
  rand bit [3:0] arid;
  rand bit [31:0] araddr;
  rand bit [3:0] arlen;
  rand bit [2:0] arsize;
  rand bit [1:0] arburst;
  rand bit arvalid;
  bit arready;

  bit [3:0] rid;
  bit [31:0] rdata;
  bit [1:0] rresp;
  bit rlast;
  bit rvalid;
  bit rready;

  `uvm_object_utils(axi_read_xtn)

  function new(string name="axi_read_xtn");
    super.new(name);
  endfunction
endclass
