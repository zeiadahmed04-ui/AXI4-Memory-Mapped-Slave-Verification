package axi4_scoreboard_pkg;

import axi4_packet_pkg::*;

class axi4_scoreboard;

    // Local reference model of DUT memory. Sized to match
    // axi4_packet::MEMORY_DEPTH (1024 words)
    // ADDR_WIDTH (16-bit byte address => 4KB address space => 1024 32-bit words).
    localparam MEM_DEPTH = 1024;
    logic [31:0] ref_mem [0:MEM_DEPTH-1];

    mailbox #(axi4_packet) mon2scb_mbx; // from monitor
    mailbox #(int)         scb2mon_mbx; // ack back to monitor

    int unsigned pass_count;
    int unsigned fail_count;

    function new();
        pass_count = 0;
        fail_count = 0;
        foreach (ref_mem[i])
            ref_mem[i] = '0;
    endfunction

    task run_scoreboard();

        axi4_packet pkt;

        forever begin

            mon2scb_mbx.get(pkt);

            check_write(pkt);
            check_read(pkt);

            scb2mon_mbx.put(1);

        end

    endtask

    task check_write(axi4_packet pkt);

        int unsigned index;

        for (int i = 0; i <= pkt.AWLEN; i++) begin
            index = (pkt.AWADDR >> 2) + i;
            if (index < MEM_DEPTH) begin
                ref_mem[index] = pkt.WDATA[i];
            end else begin
                $display("[SCOREBOARD] WRITE addr 0x%0h beat %0d (word idx %0d) out of range (mem depth %0d) - skipped",
                          pkt.AWADDR, i, index, MEM_DEPTH);
            end
        end

        if (pkt.BRESP !== 2'b00) begin
            $display("[SCOREBOARD] WRITE BRESP ERROR: addr=0x%0h resp=%0b (expected OKAY)",
                      pkt.AWADDR, pkt.BRESP);
            fail_count++;
        end else begin
            pass_count++;
        end

    endtask


    task check_read(axi4_packet pkt);

        int unsigned index;
        logic [31:0] expected;

        index = pkt.ARADDR >> 2;

        if (pkt.RRESP !== 2'b00) begin
            $display("[SCOREBOARD] READ RRESP ERROR: addr=0x%0h resp=%0b (expected OKAY)",
                      pkt.ARADDR, pkt.RRESP);
            fail_count++;
            return;
        end

        if (index >= MEM_DEPTH) begin
            $display("[SCOREBOARD] READ addr 0x%0h (word idx %0d) out of range (mem depth %0d) - data check skipped",
                      pkt.ARADDR, index, MEM_DEPTH);
            return;
        end

        expected = ref_mem[index];

        if (pkt.RDATA !== expected) begin
            $display("[SCOREBOARD] READ DATA MISMATCH: addr=0x%0h expected=0x%0h got=0x%0h",
                      pkt.ARADDR, expected, pkt.RDATA);
            fail_count++;
        end else begin
            $display("[SCOREBOARD] READ DATA MATCH: addr=0x%0h data=0x%0h", pkt.ARADDR, pkt.RDATA);
            pass_count++;
        end

    endtask

    function void report();
        $display("=================================================");
        $display("SCOREBOARD REPORT: PASS=%0d  FAIL=%0d", pass_count, fail_count);
        $display("=================================================");
    endfunction

endclass

endpackage
