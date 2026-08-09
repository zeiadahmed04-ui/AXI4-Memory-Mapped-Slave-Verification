// =====================================================================================================
//               A simple Testbench meant to check The Functionality of the axi4_memory module
// =====================================================================================================

module memory_tb;

  import memory_packet_pkg::*;

  parameter DATA_WIDTH = 32;
  parameter ADDR_WIDTH = 10;

  bit clk;
  logic rst_n;
  logic mem_en;
  logic mem_we;
  logic [ADDR_WIDTH-1:0] mem_addr;
  logic [DATA_WIDTH-1:0] mem_wdata;
  logic [DATA_WIDTH-1:0] mem_rdata;


  memory_packet stimulus;

  logic [ADDR_WIDTH-1:0] write_address_hit[logic [ADDR_WIDTH-1:0]];
  logic [DATA_WIDTH-1:0] write_address_data[logic [ADDR_WIDTH-1:0]];

  logic [ADDR_WIDTH-1:0] read_address_hit[logic [ADDR_WIDTH-1:0]];
  logic [DATA_WIDTH-1:0] read_address_data[logic [ADDR_WIDTH-1:0]];

  int pass, fail;


  axi4_memory_fixed DUT (.*);

  // ======== Clock Generation ======== 
  initial begin
    clk = 0;
    forever #5ns clk = ~clk;
  end


  initial begin

    // ======= Initialize =======
    mem_en = 0;
    mem_we = 0;
    mem_addr = 0;
    mem_wdata = 0;

    pass = 0;
    fail = 0;

    stimulus = new();

    // ====== Reset ======
    rst_n = 0;
    @(negedge clk);
    rst_n = 1;


    repeat (100) begin
      generate_stim();
      drive_stim();
    end
    scoreboard();


    $stop;
  end



  // ================================ Routines ================================

  task generate_stim;

    assert (stimulus.randomize())
    else $error("Randomization Failed!!!");

  endtask

  // ---------------------------------------------------------------------------------------------------

  task drive_stim;

    mem_en = stimulus.mem_en;
    mem_we = stimulus.mem_we;
    mem_addr = stimulus.mem_addr;
    mem_wdata = stimulus.mem_wdata;
    @(negedge clk);
    collect_address_data();

  endtask

  // ---------------------------------------------------------------------------------------------------

  task collect_address_data;

    if (mem_en && mem_we) begin  // Write Operation
      write_address_hit[mem_addr]  = mem_addr;
      write_address_data[mem_addr] = mem_wdata;
    end else if (mem_en && !mem_we) begin  // Read Operation
      if (write_address_hit.exists(mem_addr)) begin  // Only Store If Written First
        read_address_hit[mem_addr]  = mem_addr;
        read_address_data[mem_addr] = mem_rdata;
        check_address_data();  // Checking Read Data
      end
    end

  endtask

  // ---------------------------------------------------------------------------------------------------

  task check_address_data;

    if (write_address_hit.size() <= 0 || read_address_hit.size() <= 0) begin // No Elements in the Arrays
      return;
    end

    $display("\n==============================================\n");

    if (write_address_data[mem_addr] === read_address_data[mem_addr]) begin
      $display("PASS: Data Written then Read Correctly\n");
      pass++;
    end else begin
      $display("FAIL: Data Written and Read Mismatch\n");
      fail++;
    end

    $display("Wr_add:%10b, Rd_add:%10b", write_address_hit[mem_addr], read_address_hit[mem_addr]);
    $display("Expected_Written_Data:%8h, Read_Data:%8h", write_address_data[mem_addr],
             read_address_data[mem_addr]);

    $display("\n==============================================\n");

  endtask

  // ---------------------------------------------------------------------------------------------------

  task scoreboard;

    $display("\n==============================\n");

    $display("===== Pass Count: %0d =====", pass);
    $display("===== Fail Count: %0d =====", fail);

    if (pass != 0 && fail == 0) $display("\n=========## All Cases Passed ##=========");

    $display("\n==============================\n");


  endtask


endmodule
