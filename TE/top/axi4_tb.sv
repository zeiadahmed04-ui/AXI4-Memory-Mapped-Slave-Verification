
import axi4_env_pkg::*;

module axi4_tb;

  // ==== Clock Generation ====
  bit clk;
  initial begin
    clk = 0;
    forever #5ns clk = ~clk;
  end

  // ==== Interface ====
  axi4_intrf ifc (.ACLK(clk));


  // ==== DUT ====
  axi4_fixed DUT (
      .ACLK(ifc.ACLK),
      .ARESETn(ifc.ARESETn),
      .AWADDR(ifc.AWADDR),
      .AWLEN(ifc.AWLEN),
      .AWSIZE(ifc.AWSIZE),
      .AWREADY(ifc.AWREADY),
      .AWVALID(ifc.AWVALID),
      .WDATA(ifc.WDATA),
      .WLAST(ifc.WLAST),
      .WREADY(ifc.WREADY),
      .WVALID(ifc.WVALID),
      .BREADY(ifc.BREADY),
      .BRESP(ifc.BRESP),
      .BVALID(ifc.BVALID),
      .ARADDR(ifc.ARADDR),
      .ARLEN(ifc.ARLEN),
      .ARSIZE(ifc.ARSIZE),
      .ARREADY(ifc.ARREADY),
      .ARVALID(ifc.ARVALID),
      .RDATA(ifc.RDATA),
      .RLAST(ifc.RLAST),
      .RREADY(ifc.RREADY),
      .RRESP(ifc.RRESP),
      .RVALID(ifc.RVALID)
  );



  // ==== Environment ====
  axi4_env env;

  initial begin
    env = new();
    env.vif = ifc;
    env.run_env();
  end

endmodule
