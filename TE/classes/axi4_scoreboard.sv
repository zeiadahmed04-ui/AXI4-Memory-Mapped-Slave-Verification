package axi4_Scoreboard_pkg;

import axi4_packet_pkg::*;

class axi4_scoreboard;

    mailbox #(axi4_packet) gen2scb_mbx; // generator
    mailbox #(int)         scb2gen_mbx; // generator sync token

    mailbox #(axi4_packet) mon2scb_mbx; // monitor (sampled data)
    mailbox #(int)         scb2mon_mbx; // monitor ack token

    typedef struct {
        logic [31:0] Data;
        logic [7:0]  Len_burst;
        logic [2:0]  Size_transfer;
    } exp_vals_t;

    exp_vals_t expected_output [logic [15:0]];

    bit right_data_stored;
    bit right_len_burst;
    bit right_size_transfer;

    // ---- bookkeeping for the summary report ----
    int unsigned txn_count;
    int unsigned pass_count;
    int unsigned fail_count;


    function automatic void Golden_ref(
                ref logic [15:0] Waddress,
                ref logic [31:0] Wdata,
                ref logic [7:0]  len_burst,
                ref logic [2:0]  size_tran,
                ref exp_vals_t   exp_out [logic [15:0]]);

        exp_out[Waddress].Data          = Wdata;
        exp_out[Waddress].Len_burst     = len_burst;
        exp_out[Waddress].Size_transfer = size_tran;

    endfunction


    task automatic run_scoreboard();
        axi4_packet gen_txn, mon_txn;

        forever begin
            gen2scb_mbx.get(gen_txn);
            scb2gen_mbx.put(1);

            mon2scb_mbx.get(mon_txn);
            scb2mon_mbx.put(1);  // NOTE: assuming the monitor blocks on an ack like the
                                  // generator does. Remove this line (and the mailbox,
                                  // if unused elsewhere) if your monitor doesn't wait on it.

            txn_count++;

            // Build/refresh the golden model from the write side of this transaction
            Golden_ref(mon_txn.AWADDR,
                       mon_txn.WDATA,
                       mon_txn.AWLEN,
                       mon_txn.AWSIZE,
                       expected_output);

            // ---- Compare read side against the golden model ----
            if (!expected_output.exists(mon_txn.ARADDR)) begin
                $display("[%0t ns] SCOREBOARD WARNING: Txn #%0d - read from ARADDR=0x%0h has no prior recorded write, skipping check",
                          $time, txn_count, mon_txn.ARADDR);
            end
            else begin
                right_data_stored   = (mon_txn.RDATA  == expected_output[mon_txn.ARADDR].Data);
                right_len_burst     = (mon_txn.ARLEN  == expected_output[mon_txn.ARADDR].Len_burst);
                right_size_transfer = (mon_txn.ARSIZE == expected_output[mon_txn.ARADDR].Size_transfer);

                if (right_data_stored)
                    $display("[%0t ns] SCOREBOARD PASS : Txn #%0d Data  @0x%0h  exp=0x%0h act=0x%0h",
                              $time, txn_count, mon_txn.ARADDR,
                              expected_output[mon_txn.ARADDR].Data, mon_txn.RDATA);
                else
                    $error("[%0t ns] SCOREBOARD FAIL : Txn #%0d Data  @0x%0h  exp=0x%0h act=0x%0h",
                              $time, txn_count, mon_txn.ARADDR,
                              expected_output[mon_txn.ARADDR].Data, mon_txn.RDATA);

                if (right_len_burst)
                    $display("[%0t ns] SCOREBOARD PASS : Txn #%0d Len   @0x%0h  exp=%0d act=%0d",
                              $time, txn_count, mon_txn.ARADDR,
                              expected_output[mon_txn.ARADDR].Len_burst, mon_txn.ARLEN);
                else
                    $error("[%0t ns] SCOREBOARD FAIL : Txn #%0d Len   @0x%0h  exp=%0d act=%0d",
                              $time, txn_count, mon_txn.ARADDR,
                              expected_output[mon_txn.ARADDR].Len_burst, mon_txn.ARLEN);

                if (right_size_transfer)
                    $display("[%0t ns] SCOREBOARD PASS : Txn #%0d Size  @0x%0h  exp=%0d act=%0d",
                              $time, txn_count, mon_txn.ARADDR,
                              expected_output[mon_txn.ARADDR].Size_transfer, mon_txn.ARSIZE);
                else
                    $error("[%0t ns] SCOREBOARD FAIL : Txn #%0d Size  @0x%0h  exp=%0d act=%0d",
                              $time, txn_count, mon_txn.ARADDR,
                              expected_output[mon_txn.ARADDR].Size_transfer, mon_txn.ARSIZE);

                if (right_data_stored && right_len_burst && right_size_transfer)
                    pass_count++;
                else
                    fail_count++;
            end
        end
    endtask


    // Call this once at the end of the test (e.g. from your env/top after $finish
    // or in a `final` block) to get a one-line-per-run summary.
    function void report();
        $display("\n==============================================");
        $display("==            SCOREBOARD SUMMARY           ==");
        $display("==============================================");
        $display("  Transactions checked : %0d", pass_count + fail_count);
        $display("  PASS                 : %0d", pass_count);
        $display("  FAIL                 : %0d", fail_count);
        if (fail_count == 0)
            $display("  RESULT               : ALL CHECKS PASSED");
        else
            $display("  RESULT               : %0d CHECK(S) FAILED", fail_count);
        $display("==============================================\n");
    endfunction

endclass

endpackage