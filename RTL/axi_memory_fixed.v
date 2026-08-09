module axi4_memory_fixed #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 10,    // For 1024 locations
    parameter DEPTH = 1024
)(
    input  wire                     clk,
    input  wire                     rst_n,
    
    input  wire                     mem_en,
    input  wire                     mem_we,
    input  wire [ADDR_WIDTH-1:0]    mem_addr,
    input  wire [DATA_WIDTH-1:0]    mem_wdata,
    output reg  [DATA_WIDTH-1:0]    mem_rdata
);

    // Memory array
    reg [DATA_WIDTH-1:0] memory [0:DEPTH-1];
    
    
    integer j;
    
    // Memory write
    always @(posedge clk or negedge rst_n) begin // FIX: Asynchronous Reset
        if (!rst_n) begin // FIX: Was Active High instead of Active Low
            mem_rdata <= 0;
            // Initialize memory
            for (j = 0; j < DEPTH; j = j + 1)
                memory[j] = 0;

        end else if (mem_en) begin
            if (mem_we)
                memory[mem_addr] <= mem_wdata;
             else 
               mem_rdata <= memory[mem_addr]; // FIX: Used to Read from Location [mem_addr-1] 
        end
    end
    
endmodule
