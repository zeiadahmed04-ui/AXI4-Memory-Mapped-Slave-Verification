package axi4_monitor_pkg;

import axi4_packet_pkg::*;

class axi4_monitor;

    virtual axi4_intrf.MON vif;

    mailbox #(axi4_packet) mon2scb_mbx; // scoreboard
    mailbox #(int)         scb2mon_mbx; // scoreboard ack token

    task run_monitor();

        axi4_packet sampled;
        int token;

        forever begin

            sampled = new();


            forever begin
                @(posedge vif.ACLK);
                if (vif.AWVALID && vif.AWREADY) break;
            end
            sampled.AWADDR = vif.AWADDR;
            sampled.AWLEN  = vif.AWLEN;
            sampled.AWSIZE = vif.AWSIZE;


            sampled.WDATA = new[sampled.AWLEN + 1];
            for (int i = 0; i <= sampled.AWLEN; i++) begin
                forever begin
                    @(posedge vif.ACLK);
                    if (vif.WVALID && vif.WREADY) break;
                end
                sampled.WDATA[i] = vif.WDATA;
                sampled.WLAST    = vif.WLAST;
            end

            // ========== Write Response Phase ==========
            forever begin
                @(posedge vif.ACLK);
                if (vif.BVALID && vif.BREADY) break;
            end
            sampled.BRESP = vif.BRESP;

            // ========== Read Address Phase ==========
            forever begin
                @(posedge vif.ACLK);
                if (vif.ARVALID && vif.ARREADY) break;
            end
            sampled.ARADDR = vif.ARADDR;
            sampled.ARLEN  = vif.ARLEN;
            sampled.ARSIZE = vif.ARSIZE;

            // ========== Read Data Phase ==========
            for (int i = 0; i <= sampled.ARLEN; i++) begin
                forever begin
                    @(posedge vif.ACLK);
                    if (vif.RVALID && vif.RREADY) break;
                end
                if (i == 0) begin
                    sampled.RDATA = vif.RDATA;
                    sampled.RRESP = vif.RRESP;
                end
                sampled.RLAST = vif.RLAST;
            end

            // ========== Coverage sampling ==========
            sampled.sample_write_coverage();
            sampled.sample_read_coverage();

            mon2scb_mbx.put(sampled);

            scb2mon_mbx.get(token);

        end

    endtask

endclass

endpackage