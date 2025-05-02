interface axi_read_if(input bit clk, input bit rst_n);

  logic [31:0] ARADDR;
  logic [3:0]  ARID;
  logic [7:0]  ARLEN;
  logic        ARVALID;
  logic        ARREADY;

  logic [31:0] RDATA;
  logic [3:0]  RID;
  logic        RLAST;
  logic        RVALID;
  logic        RREADY;

endinterface
