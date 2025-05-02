class axi_read_xtn extends uvm_sequence_item;
  rand bit [31:0] araddr;
  rand bit [3:0]  arid;
  rand bit [7:0]  arlen;

  bit [31:0] rdata;
  bit [3:0]  rid;
  bit        rlast;

  `uvm_object_utils(axi_read_xtn)

  function new(string name = "axi_read_xtn");
    super.new(name);
  endfunction

  function string convert2string();
    return $sformatf("ARADDR=%0h ARID=%0h ARLEN=%0h RDATA=%0h", araddr, arid, arlen, rdata);
  endfunction
endclass
