package memory_packet_pkg;


  class memory_packet;

    parameter DATA_WIDTH = 32;
    parameter ADDR_WIDTH = 10;  // For 1024 locations
    parameter DEPTH = 1024;

    bit clk;
    rand logic rst_n;
    rand logic mem_en;
    rand logic mem_we;
    rand logic [ADDR_WIDTH-1:0] mem_addr;
    rand logic [DATA_WIDTH-1:0] mem_wdata;
    logic  [DATA_WIDTH-1:0]    mem_rdata;


    logic prev_mem_we = 0;
    logic [ADDR_WIDTH-1:0] prev_mem_addr = 0;
    // ======== Constraints ========

    constraint reset_c {
      rst_n dist {
        1 := 90,
        0 := 10
      };
    }

    constraint mem_en_c {
      mem_en dist {
        1 := 90,
        0 := 10
      };
    }

    constraint mem_we_c {
      mem_we dist {
        1 := 50,  // Write
        0 := 50  // Read
      };

      (prev_mem_we == 1) -> {mem_we == 0;}  // Read The Data just Written

    }

    constraint address_c {
      mem_addr inside {[0 : 100]};

      (prev_mem_we == 1) -> {mem_addr == prev_mem_addr;}  // Read The Data just Written
    }

    function void post_randomize();
      prev_mem_we   = mem_we;
      prev_mem_addr = mem_addr;
    endfunction


  endclass

endpackage
