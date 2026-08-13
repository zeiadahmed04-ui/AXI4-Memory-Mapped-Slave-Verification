package axi4_generator_pkg;

  import axi4_packet_pkg::*;

  class axi4_generator;

    // ======== Mailboxes ========

    mailbox #(axi4_packet) gen2drv_mbx;  // Generator to Driver
    mailbox #(int) drv2gen_mbx;  // Driver to Generator acknowledgement

    mailbox #(axi4_packet) gen2scb_mbx;  // Generator to Scoreboard
    mailbox #(int) scb2gen_mbx;  // Scoreboard to Generator acknowledgement


    const int unsigned num_pkts = 200;  // Number of Stimulus Packets to send

    task run_generator;

      axi4_packet tx_pkt;
      int ack;

      repeat (num_pkts) begin


        tx_pkt = new();
        tx_pkt.ADDr_W_R.constraint_mode(1);
        tx_pkt.Read_ADDR.constraint_mode(0);


        assert (tx_pkt.randomize())
        else $error("!!Randomization Failed!!");

        // == Send to Driver ==
        gen2drv_mbx.put(tx_pkt);
        drv2gen_mbx.get(ack);  // To Synchronize with Driver

        // == Send to Scoreboard
        gen2scb_mbx.put(tx_pkt);
        scb2gen_mbx.get(ack);  // To Synchronize with Scoreboard

      end

      $display("\n============================\n");
      $display("==## Generator Finished test 1 ##==");
      $display("Time:%0t, Packets_Sent:%0d", $time, num_pkts);
      $display("\n============================\n");

      // **********************  new section *************************//

      repeat (num_pkts) begin

        tx_pkt = new();
        tx_pkt.ADDr_W_R.constraint_mode(0);
        tx_pkt.Read_ADDR.constraint_mode(1);

        assert (tx_pkt.randomize())
        else $error("!!Randomization Failed!!");

        // == Send to Driver ==
        gen2drv_mbx.put(tx_pkt);
        drv2gen_mbx.get(ack);  // To Synchronize with Driver

        // == Send to Scoreboard
        gen2scb_mbx.put(tx_pkt);
        scb2gen_mbx.get(ack);  // To Synchronize with Scoreboard

      end

      $display("\n===================================\n");
      $display("==## Generator Finished test num 2 ##==");
      $display("Time:%0t, Packets_Sent:%0d", $time, num_pkts);
      $display("\n===================================\n");


    endtask

  endclass


endpackage
