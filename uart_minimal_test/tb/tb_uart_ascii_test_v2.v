`timescale 1ns / 1ps

module tb_uart_ascii_test_v2;
    localparam integer CLK_FREQ  = 1_000_000;
    localparam integer BAUD_RATE = 100_000;
    localparam integer BIT_CLKS  = CLK_FREQ / BAUD_RATE;

    reg clk = 1'b0;
    wire uart_tx;
    wire status_led;
    integer received_count = 0;
    reg [7:0] received [0:27];
    integer i;

    always #500 clk = ~clk;

    uart_ascii_test_v2 #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE),
        .REPORT_HZ(10_000)
    ) dut (
        .clk50M(clk),
        .uart_tx(uart_tx),
        .status_led(status_led)
    );

    task receive_byte;
        integer bit_no;
        reg [7:0] value;
        begin
            @(negedge uart_tx);
            repeat (BIT_CLKS + BIT_CLKS/2) @(posedge clk);
            for (bit_no = 0; bit_no < 8; bit_no = bit_no + 1) begin
                value[bit_no] = uart_tx;
                repeat (BIT_CLKS) @(posedge clk);
            end
            if (uart_tx !== 1'b1)
                $fatal(1, "stop bit low");
            received[received_count] = value;
            received_count = received_count + 1;
        end
    endtask

    function [7:0] expected_byte;
        input integer index;
        begin
            case (index % 14)
                0: expected_byte = 8'h46;
                1: expected_byte = 8'h50;
                2: expected_byte = 8'h47;
                3: expected_byte = 8'h41;
                4: expected_byte = 8'h5F;
                5: expected_byte = 8'h55;
                6: expected_byte = 8'h41;
                7: expected_byte = 8'h52;
                8: expected_byte = 8'h54;
                9: expected_byte = 8'h5F;
                10: expected_byte = 8'h4F;
                11: expected_byte = 8'h4B;
                12: expected_byte = 8'h0D;
                default: expected_byte = 8'h0A;
            endcase
        end
    endfunction

    initial begin
        for (i = 0; i < 28; i = i + 1)
            receive_byte();
        for (i = 0; i < 28; i = i + 1)
            if (received[i] !== expected_byte(i))
                $fatal(1, "byte %0d expected %02x got %02x", i,
                       expected_byte(i), received[i]);
        $display("PASS: received two FPGA_UART_OK messages");
        $finish;
    end

    initial begin
        #10_000_000;
        $fatal(1, "simulation timeout");
    end
endmodule
