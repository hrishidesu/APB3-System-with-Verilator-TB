`timescale 1ns/1ps

module apb_master #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32
) (
    //test inputs
    input logic transfer,
    input logic [ADDR_WIDTH-1:0] transfer_addr,
    input logic [DATA_WIDTH-1:0] transfer_wdata,
    input logic transfer_write,

    //output to slave
    output logic psel,
    output logic penable,
    output logic pwrite,
    output logic [DATA_WIDTH-1:0] pwdata,
    output logic [ADDR_WIDTH-1:0] paddr,

    //inputs from slave
    input logic pclk,
    input logic presetn,
    input logic pready,
    input logic pslverr,
    input logic [DATA_WIDTH-1:0] prdata
);

    // State machine states
    typedef enum logic [1:0] { 
        IDLE,
        SETUP,
        ACCESS
     } state_t;

     state_t state_current, state_next;

     // Internal registers
     logic [DATA_WIDTH-1:0] data_current, data_next;
     logic [ADDR_WIDTH-1:0] addr_current, addr_next;
     logic write_current, write_next;

    // Combinational logic
    always_comb begin
        // Default assignments
        state_next = state_current;
        psel = 1'b0;
        penable = 1'b0;
        pwrite = write_current;
        pwdata = data_current;
        paddr = addr_current;
        addr_next = addr_current;
        data_next = data_current;
        write_next = write_current;

        case(state_current)
            IDLE: begin
                if(transfer) begin 
                    state_next = SETUP;
                    addr_next = transfer_addr;
                    data_next = transfer_wdata;
                    write_next = transfer_write;
                end else begin
                    state_next = IDLE;
                end
            end

            SETUP: begin
                psel = 1'b1;
                penable = 1'b0;
                state_next = ACCESS;
            end

            ACCESS: begin
                psel = 1'b1;
                penable = 1'b1;
                if(pready) begin
                    state_next = IDLE;
                end else begin
                    state_next = ACCESS;
                end
            end

            default: begin
                state_next = IDLE;
            end
        endcase
    
    end
    
    // Sequential logic
     always_ff @(posedge pclk or negedge presetn) begin
        if(!presetn) begin
            state_current <= IDLE;
            addr_current <= '0;
            data_current <= '0;
            write_current <= 1'b0;
        end else begin

            state_current <= state_next;
            addr_current <= addr_next;
            data_current <= data_next;
            write_current <= write_next;
        end
     end


endmodule
