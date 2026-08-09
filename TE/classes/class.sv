class AXI4_Pack_Gen;

    // the inputs of AXI4 desgin
    rand logic [15:0] AWADDR; // address of writting
    rand logic [7:0] AWLEN; // Burst length
    rand logic [2:0] AWSIZE; // size of each transfer in the burst
    logic AWVALID; // Write address Valid
    rand logic [31:0] WDATA; // write data
    logic WLAST, WVALID;
    logic BREADY; // the master can accept the response information
    rand logic [15:0] ARADDR; // address of reading
    rand logic [7:0] ARLEN;
    rand logic [2:0] ARSIZE;
    logic ARVALID;
    logic RREADY;
    // the outputs of the AXI4 desgin
    logic AWREADY; // Write address ready
    logic WREADY;
    logic [1:0] BRESP; // status of the write transaction
    logic BVALID;  // valid write response is available
    logic ARREADY;
    logic [31:0] RDATA;
    logic [1:0] RRESP;
    logic RLAST;
    logic RVALID;


    constraint  Write_Oper {           // the signals used in the WRITE operation

    AWADDR dist { 16'hFFFF:/10 , 16'h000:/10, [16'h0000:16'hFFFF]:/80}; // addres randomize
    AWLEN  dist {8'h00:/ 10 , 8'hFF:/ 10, [8'h00:8'hFF]:/ 80 };
    WDATA  dist {32'hFFFF_FFFF:/20 , 32'h0000_0000:/10, [32'h0000_0000:32'hFFFF_FFFF]:/70};
   }

    constraint  Read_Oper {           // the signals used in the READ operation

    ARADDR dist { 16'hFFFF:/10 , 16'h000:/10, [16'h0000:16'hFFFF]:/80}; // addres randomize
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

    Data_W: coverpoint WDATA {
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
    endfunction

    function pre_randomize();
        $display("-----------------------------------------");
        $display("--------HERE randomization starts--------");
        $display("-----------------------------------------");
    endfunction

    function post_randomize();
        $display("-----------------------------------------");
        $display("--------HERE randomization Ends----------");
        $display("-----------------------------------------");
    endfunction


endclass
