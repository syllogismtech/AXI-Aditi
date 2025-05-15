// 1. AXI Interface
interface axi_if(input logic ACLK, input logic ARESETn);
    // Read address channel
    logic [3:0]     ARID;
    logic [31:0]    ARADDR;
    logic [3:0]     ARLEN;
    logic [2:0]     ARSIZE;
    logic [1:0]     ARBURST;
    logic           ARVALID;
    logic           ARREADY;
  
    // Read data channel
    logic [3:0]     RID;
    logic [31:0]    RDATA;
    logic [1:0]     RRESP;
    logic           RLAST;
    logic           RVALID;
    logic           RREADY;
  
    // Write address channel
    logic [3:0]     AWID;
    logic [31:0]    AWADDR;
    logic [3:0]     AWLEN;
    logic [2:0]     AWSIZE;
    logic [1:0]     AWBURST;
    logic           AWVALID;
    logic           AWREADY;
  
    // Write data channel
    logic [3:0]     WID;
    logic [31:0]    WDATA;
    logic [3:0]     WSTRB;
    logic           WLAST;
    logic           WVALID;
    logic           WREADY;
  
    // Write response channel
    logic [3:0]     BID;
    logic [1:0]     BRESP;
    logic           BVALID;
    logic           BREADY;
endinterface
