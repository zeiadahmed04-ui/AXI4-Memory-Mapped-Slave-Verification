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
      $display("==## Generator Finished ##==");
      $display("Time:%0t, Packets_Sent:%0d", $time, num_pkts);
      $display("\n============================\n");

    endtask

  endclass


endpackage
