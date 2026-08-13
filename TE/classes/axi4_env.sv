package axi4_env_pkg;

  import axi4_packet_pkg::*;
  import axi4_monitor_pkg::*;
  import axi4_generator_pkg::*;
  import axi4_scoreboard_pkg::*;
  import axi4_driver_pkg::*;

  class axi4_env;

    // ======== Components ========

    axi4_monitor mon;
    axi4_driver drv;
    axi4_generator gen;
    axi4_scoreboard scb;

    // ======== Interface ======== 
    virtual axi4_intrf vif;


    // ======== Mailboxes ========

    mailbox #(axi4_packet) gen2drv_mbx;  // Generator to Driver
    mailbox #(int) drv2gen_mbx;  // Driver to Generator acknowledgement

    mailbox #(axi4_packet) gen2scb_mbx;  // Generator to Scoreboard
    mailbox #(int) scb2gen_mbx;  // Scoreboard to Generator acknowledgement

    mailbox #(axi4_packet) mon2scb_mbx;  // Monitor to Scoreboard
    mailbox #(int) scb2mon_mbx;  // Scoreboard to Monitor acknowledgement



    task run_env();

      // === Create Components ===
      mon = new();
      gen = new();
      scb = new();
      drv = new();


      // === Create Mailboxes ===
      gen2drv_mbx = new(1);
      drv2gen_mbx = new(1);
      gen2scb_mbx = new(1);
      scb2gen_mbx = new(1);
      mon2scb_mbx = new(1);
      scb2mon_mbx = new(1);

      // === Share Interface ===
      mon.vif = vif;
      drv.vif = vif;

      // === Connect Mailboxes ===

      // Scoreboard
      scb.gen2scb_mbx = gen2scb_mbx;
      scb.scb2gen_mbx = scb2gen_mbx;
      scb.mon2scb_mbx = mon2scb_mbx;
      scb.scb2mon_mbx = scb2mon_mbx;

      // Monitor
      mon.mon2scb_mbx = mon2scb_mbx;
      mon.scb2mon_mbx = scb2mon_mbx;

      // Generator
      gen.drv2gen_mbx = drv2gen_mbx;
      gen.gen2drv_mbx = gen2drv_mbx;
      gen.gen2scb_mbx = gen2scb_mbx;
      gen.scb2gen_mbx = scb2gen_mbx;

      // Driver
      drv.drv2gen_mbx = drv2gen_mbx;
      drv.gen2drv_mbx = gen2drv_mbx;

      // Reset
      reset();

      fork
        gen.run_generator();
        drv.run_driver();
        mon.run_monitor();
        scb.run_scoreboard();
      join_any

      repeat (4) @(negedge vif.ACLK);

      scb.report();
      $stop;

    endtask

    task reset();
      vif.ARESETn = 0;
      repeat (2) @(negedge vif.ACLK);
      vif.ARESETn = 1;
      @(negedge vif.ACLK);
    endtask


  endclass

endpackage
