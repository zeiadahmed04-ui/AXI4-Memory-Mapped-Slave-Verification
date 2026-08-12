package axi4_packet_pkg;

class axi4_packet;

    parameter DATA_WIDTH = 32;
    parameter ADDR_WIDTH = 16;
    parameter MEMORY_DEPTH = 1024;

    // =============================
    // === Inputs NOT Randomized ===
    // =============================

    // Write address channel
    logic AWVALID;  // Indicates that valid write address and control information is available:

    // Write data channel
    logic WLAST;  // Write last. Indicates the last transfer in a write burst
    logic WVALID;  // Indicates that valid write data and strobes are available

    // Write response channel
    logic BREADY;  // Indicates that the master can accept the response information

    // Read data channel
    logic RREADY;  // Read ready. This signal indicates that the master can accept the read data

    // Read address channel
    logic ARVALID;  // Indicates that the read address and control information is valid


    // =============================
    // ==== Inputs to Randomize ====
    // =============================

    logic ARESETn;  // Global reset signal

    // Write address channel
    rand logic [ADDR_WIDTH-1:0] AWADDR;  // The Address of first transfer in a write burst trans
    rand logic [7:0] AWLEN;  // Burst length
    rand logic [2:0] AWSIZE;  // Burst size

    // Write data channel
    rand logic [DATA_WIDTH-1:0] WDATA[];  // Write data

    // Read address channel
    rand logic [ADDR_WIDTH-1:0] ARADDR;  // The Initial Address of a read burst transaction
    rand logic [7:0] ARLEN;  // Burst length
    rand logic [2:0] ARSIZE;  // Burst size


    // =============================
    // ==== Outputs to Collect =====
    // =============================

    // Write address channel
    logic AWREADY;  // Write address ready. Indicates that the slave is ready to accept an address

    // Write data channel
    logic WREADY;  // Indicates that the slave can accept the write data

    // Write response channel
    logic [1:0] BRESP;  // Write response. Indicates the status of the write transaction
    logic BVALID;  // Indicates that a valid write response is available

    // Read address channel
    logic ARREADY; // Read address ready. This signal indicates that the slave is ready to accept an address

    // Read data channel
    logic [DATA_WIDTH-1:0] RDATA;  // Read data
    logic [1:0] RRESP;  // Read response. This signal indicates the status of the read transfer
    logic RVALID;  // Read valid. This signal indicates that the required read data is available
    logic RLAST;  // Read last. This signal indicates the last transfer in a read burst

    // Holds each WDATA beat in turn purely so we can cover the Data_W values
    logic [DATA_WIDTH-1:0] current_wdata;

    constraint ADDr_W_R{  // new edit on the constraints needs handle to turn on or off
        ARADDR == AWADDR;
    }

    constraint Write_DATA {
    WDATA.size() == AWLEN + 1;
    foreach (WDATA[i])
        WDATA[i] dist { 32'hFFFF_FFFF:/20, 32'h0000_0000:/10, [32'h0000_0000:32'hFFFF_FFFF]:/70 };
}


    constraint  Write_Oper {           // the signals used in the WRITE operation

    AWADDR dist { 16'hFFFF:/10 , 16'h000:/10, [16'h0000:16'hFFFF]:/80}; // addres randomize
    AWLEN  dist {8'h00:/ 10 , 8'hFF:/ 10, [8'h00:8'hFF]:/ 80 };
    }

    constraint  Read_ADDR {           // the signals used in the READ operation

    ARADDR dist { 16'hFFFF:/10 , 16'h000:/10, [16'h0000:16'hFFFF]:/80}; // addres randomize
    }

    constraint ARlen {
        ARLEN  dist {8'b0000_0000:/ 10 , 8'b1111_1111 :/ 10, [8'h00:8'hFF]:/80};
    }

    constraint Size_c {
        AWSIZE == 3'b010;
        ARSIZE == 3'b010;
    }

    covergroup Write_Oper_cg;

    Addr_W: coverpoint AWADDR {
            bins LOW_ADD    = {[16'h0000 : 16'h07FF]};
            bins MID_ADD   = {[16'h0800 : 16'h4FFF]};
            bins HIGH_ADD  = {[16'h5000 : 16'hFFFE]};
            bins max_addr     = {16'hFFFF};
        }

    Len_W: coverpoint AWLEN {
            bins single       = {0};
            bins burst_2_4    = {[1:4]};
            bins burst_5_8    = {[5:8]};
            bins burst_9_16   = {[9:16]};
            bins burst_17_63  = {[17:63]};
            bins burst_64_127 = {[64:127]};
            bins burst_128_254= {[128:254]};
            bins max_burst    = {255};
        }

    Size_W: coverpoint AWSIZE {
            bins word = {3'b010};
            illegal_bins others = default;
        }

    Data_W: coverpoint current_wdata {
            bins all_zero = {32'h0000_0000};
            bins all_one  = {32'hFFFF_FFFF};
            bins pat_a    = {32'hAAAA_AAAA};
            bins pat_5    = {32'h5555_5555};
            bins q1       = {[32'h0000_0001 : 32'h1FFF_FFFF]};
            bins q2       = {[32'h2000_0000 : 32'h3FFF_FFFF]};
            bins q3       = {[32'h4000_0000 : 32'h7FFF_FFFF]};
            bins q4       = {[32'h8000_0000 : 32'hBFFF_FFFF]};
            bins q5       = {[32'hC000_0000 : 32'hDFFF_FFFF]};
            bins q6       = {[32'hE000_0000 : 32'hFFFF_FFFE]};
        }

    Resp_W: coverpoint BRESP {
            bins okay   = {2'b00};
            bins slverr = {2'b10};
            illegal_bins others = default;   // EXOKAY/DECERR unused in this design
        }

    Last_W: coverpoint WLAST {
            bins asserted   = {1};
            bins deasserted = {0};
        }

    AddrLenCross_W: cross Addr_W, Len_W;
    endgroup

    covergroup Read_Oper_cg;

    Addr_R: coverpoint ARADDR {
            bins LOW_ADD    = {[16'h0000 : 16'h07FF]};
            bins MID_ADD   = {[16'h0800 : 16'h4FFF]};
            bins HIGH_ADD  = {[16'h5000 : 16'hFFFE]};
            bins max_addr     = {16'hFFFF};
        }

    Len_R: coverpoint ARLEN {
            bins single       = {0};
            bins burst_2_4    = {[1:4]};
            bins burst_5_8    = {[5:8]};
            bins burst_9_16   = {[9:16]};
            bins burst_17_63  = {[17:63]};
            bins burst_64_127 = {[64:127]};
            bins burst_128_254= {[128:254]};
            bins max_burst    = {255};
        }

    Size_R: coverpoint ARSIZE {
            bins word = {3'b010};
            illegal_bins others = default;
        }

    Resp_R: coverpoint RRESP {
            bins okay   = {2'b00};
            bins slverr = {2'b10};
            illegal_bins others = default;
        }

    Last_R: coverpoint RLAST {
            bins asserted   = {1};
            bins deasserted = {0};
        }

    AddrLenCross_R: cross Addr_R, Len_R;

    endgroup

    function new();
        Write_Oper_cg = new();
        Read_Oper_cg  = new();
        WDATA = new[AWLEN];
    endfunction

    function void pre_randomize();
        $display("-----------------------------------------");
        $display("--------HERE randomization starts--------");
        $display("-----------------------------------------");
    endfunction

    function void post_randomize();
        $display("-----------------------------------------");
        $display("--------HERE randomization Ends----------");
        $display("-----------------------------------------");
    endfunction

    function void sample_write_coverage();
        foreach (WDATA[i]) begin
            current_wdata = WDATA[i];
            Write_Oper_cg.sample();
        end
    endfunction

    function void sample_read_coverage();
        Read_Oper_cg.sample();
    endfunction

endclass

endpackage
