
package axi4_driver_pkg;

  import axi4_packet_pkg::*;

  class axi4_driver;


    // ======== Interface ======== 
    virtual axi4_intrf.TB vif;


    // ======== Mailboxes ========

    mailbox #(axi4_packet) gen2drv_mbx;  // Generator to Driver
    mailbox #(int) drv2gen_mbx;  // Driver to Generator acknowledgement


    task run_driver();

      axi4_packet rx_pkt;

      forever begin

        // Get Generated Packet
        gen2drv_mbx.get(rx_pkt);


        // ================== Write Burst ================== 

        // === Write Address Phase ===
        @(negedge vif.ACLK);
        vif.AWADDR  = rx_pkt.AWADDR;
        vif.AWLEN   = rx_pkt.AWLEN;
        vif.AWSIZE  = rx_pkt.AWSIZE;
        vif.AWVALID = 1;
        @(posedge vif.ACLK iff vif.AWREADY);  // Wait for AWREADY to be asserted
        @(negedge vif.ACLK);
        vif.AWVALID = 0;


        // === Write Data Phase ===
        @(negedge vif.ACLK);
        // Send Data
        for (int i = 0; i <= rx_pkt.AWLEN; i++) begin
          vif.WVALID = 1;
          vif.WDATA  = rx_pkt.WDATA[i];
          if (i == rx_pkt.AWLEN) begin  // Last Beat of the Burst
            vif.WLAST = 1;
          end
          @(posedge vif.ACLK iff vif.WREADY);  // Wait for WREADY to be asserted
          @(negedge vif.ACLK);
        end
        vif.WVALID = 0;  // De-assert WVALID
        vif.WLAST  = 0;  // De-assert WLAST


        // === Write Response Phase ===
        vif.BREADY = 1;  // Ready to recieve the Response
        @(posedge vif.ACLK iff vif.BVALID);  // Wait for BVALID to be asserted
        @(negedge vif.ACLK);
        vif.BREADY = 0;




        // ================== Read Burst ================== 

        // === Read Data Phase ===
        @(negedge vif.ACLK);
        vif.ARADDR  = rx_pkt.ARADDR;
        vif.ARLEN   = rx_pkt.ARLEN;
        vif.ARSIZE  = rx_pkt.ARSIZE;
        vif.ARVALID = 1;
        @(posedge vif.ACLK iff vif.ARREADY);  // Wait for ARREADY to be asserted
        @(negedge vif.ACLK);
        vif.ARVALID = 0;

        vif.RREADY  = 1;  // We are Ready to Recieve Data

        @(posedge vif.ACLK iff vif.RLAST);  // wait until Read Burst is Finished
        @(negedge vif.ACLK);
        vif.RREADY = 0;

        // Stimulus has been driven
        drv2gen_mbx.put(1);  // Acknowledge
      end

    endtask


  endclass

endpackage
