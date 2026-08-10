interface axi4_intrf #(
    parameter DATA_WIDTH   = 32,
    parameter ADDR_WIDTH   = 16,
    parameter MEMORY_DEPTH = 1024
) (
    input bit ACLK
);


  // ======== Signals ========

  logic ARESETn;

  // Write address channel
  logic [ADDR_WIDTH-1:0] AWADDR;
  logic [7:0] AWLEN;
  logic [2:0] AWSIZE;
  logic AWVALID;
  logic AWREADY;

  // Write data channel
  logic [DATA_WIDTH-1:0] WDATA;
  logic WVALID;
  logic WLAST;
  logic WREADY;

  // Write response channel
  logic [1:0] BRESP;
  logic BVALID;
  logic BREADY;

  // Read address channel
  logic [ADDR_WIDTH-1:0] ARADDR;
  logic [7:0] ARLEN;
  logic [2:0] ARSIZE;
  logic ARVALID;
  logic ARREADY;

  // Read data channel
  logic [DATA_WIDTH-1:0] RDATA;
  logic [1:0] RRESP;
  logic RVALID;
  logic RLAST;
  logic RREADY;


  // ======= MODPORTS =======

  modport DUT(
      input ACLK,ARESETn,AWADDR,AWLEN,AWSIZE,AWVALID,WDATA,WVALID,WLAST,BREADY,ARADDR,ARLEN,ARSIZE,ARVALID,RREADY,
      output AWREADY, WREADY, BRESP, BVALID, ARREADY, RDATA, RRESP, RVALID, RLAST
  );


  modport TB(
      output ARESETn,AWADDR,AWLEN,AWSIZE,AWVALID,WDATA,WVALID,WLAST,BREADY,ARADDR,ARLEN,ARSIZE,ARVALID,RREADY,
      input AWREADY, WREADY, BRESP, BVALID, ARREADY, RDATA, RRESP, RVALID, RLAST, ACLK
  );


  modport MON(
      input ACLK,ARESETn,AWADDR,AWLEN,AWSIZE,AWVALID,WDATA,WVALID,WLAST,BREADY,ARADDR,ARLEN,ARSIZE,ARVALID,RREADY,
            AWREADY, WREADY, BRESP, BVALID, ARREADY, RDATA, RRESP, RVALID, RLAST
  );


endinterface
