`timescale 1ns/1ps

module tb_apb_top #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32
) ();

    logic pclk, presetn;
    logic psel, penable, pwrite, pready, pslverr;
    logic [DATA_WIDTH-1:0] pwdata, prdata;
    logic [ADDR_WIDTH-1:0] paddr;

    logic transfer;
    logic [ADDR_WIDTH-1:0] transfer_addr;
    logic [DATA_WIDTH-1:0] transfer_wdata;
    logic transfer_write;

    apb_master #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) dut_apb_master (
        .transfer(transfer),
        .transfer_addr(transfer_addr),
        .transfer_wdata(transfer_wdata),
        .transfer_write(transfer_write),
        .psel(psel),
        .penable(penable),
        .pwrite(pwrite),
        .pwdata(pwdata),
        .paddr(paddr),
        .pclk(pclk),
        .presetn(presetn),
        .pready(pready),
        .pslverr(pslverr),
        .prdata(prdata) 
    );

    apb_ram_slave #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) dut_apb_ram_slave (
        .pclk(pclk),
        .presetn(presetn),
        .psel(psel),
        .penable(penable),
        .pwrite(pwrite),
        .paddr(paddr),
        .pwdata(pwdata),
        .prdata(prdata),
        .pready(pready),
        .pslverr(pslverr)
    );

    initial begin
        pclk = 0;
        forever #5 pclk = ~pclk;
    end

    initial begin

        $dumpfile("waves.vcd");
        $dumpvars(0, tb_apb_top);

        presetn = 0;
        transfer = 0;
        transfer_addr = '0;
        transfer_wdata = '0;
        transfer_write = 0;
        
        repeat (5) @(posedge pclk);
        presetn = 1;
        $display("[TIME %0t] Reset de-asserted", $time);
        
        // WRITE
        repeat (2) @(posedge pclk);
        $display("[TIME %0t] Starting WRITE to address 0x00000010", $time);

        transfer_addr <= 32'h0000_0010;
        transfer_wdata <= 32'hDEAD_BEEF;
        transfer_write <= 1;
        transfer <= 1;

        @(posedge pclk);
        transfer <= 0;
        wait (psel == 0);
        $display(" [TIME %0t] Write Completed", $time);

        repeat (4) @(posedge pclk);

        // READ
        $display("[TIME %0t] Starting READ from address 0x00000010", $time);
        transfer_addr <= 32'h0000_0010;
        transfer_write <= 0;
        transfer <= 1;

        @(posedge pclk);
        transfer <= 0;

        // Check read data
        wait (psel && penable && pready);

        if(dut_apb_master.prdata === 32'hDEAD_BEEF) begin
            $display("[TIME %0t] READ data matches expected value: 0x%08h", $time, dut_apb_master.prdata);
        end else begin
            $display("[TIME %0t] READ data mismatch! Expected: 0xDEAD_BEEF, Got: 0x%08h", $time, dut_apb_master.prdata);
        end

        repeat (5) @(posedge pclk);
        $display(" [TIME %0t] Simulation Finished", $time);
        $finish;
    end

endmodule
