interface axi_if(input bit clk);
  logic [3:0] arid;
  logic [31:0] araddr;
  logic [3:0] arlen;
  logic [2:0] arsize;
  logic [1:0] arburst;
  logic arvalid, arready;

  logic [3:0] rid;
  logic [31:0] rdata;
  logic [1:0] rresp;
  logic rlast;
  logic rvalid, rready;
endinterface

