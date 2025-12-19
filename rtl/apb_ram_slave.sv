`timescale 1ns/1ps

module apb_ram_slave #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32
) (
    input logic pclk,
    input logic presetn,
    input logic psel,
    input logic penable,
    input logic pwrite,
    input logic [ADDR_WIDTH-1:0] paddr,
    input logic [DATA_WIDTH-1:0] pwdata,
    output logic [DATA_WIDTH-1:0] prdata,
    output logic pready,
    output logic pslverr
);
    logic [DATA_WIDTH-1:0] ram [0:63]; // 64 words of RAM
    logic [1:0] wait_cycles;

    always_ff @(posedge pclk or negedge presetn) begin
        if(!presetn) begin
            wait_cycles <= 0;
        end else begin
            if(psel && penable) begin
                wait_cycles <= 2'($urandom_range(0,3)); // Random wait cycles between 0 and 3
            end else if(psel && penable && wait_cycles > 0) begin
                wait_cycles <= wait_cycles - 1;
            end
        end
    end

    assign pready = (wait_cycles == 0)? 1'b1 : 1'b0;

    always_comb begin
        //pready = 1'b1; // Always ready
        pslverr = 1'b0; // No error

        if(psel && !pwrite) begin
            prdata = ram[paddr[7:2]]; // Read operation
        end else begin
            prdata = '0; // Default value for write operations
        end        
    end

    always_ff @(posedge pclk or negedge presetn) begin
        if(!presetn) begin
        
        end else begin
            if(psel && penable) begin
                if(pwrite)
                    ram[paddr[7:2]] <= pwdata; // Write operation
            end
        end
        
    end

endmodule
