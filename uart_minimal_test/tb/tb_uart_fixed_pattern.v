`timescale 1ns / 1ps

module tb_uart_fixed_pattern;
    localparam integer CLK_FREQ  = 1_000_000;
    localparam integer BAUD_RATE = 100_000;
    localparam integer BIT_CLKS  = CLK_FREQ / BAUD_RATE;

    reg clk = 1'b0;
    reg reset_n = 1'b0;
    wire uart_tx;
    wire status_led;
    integer received_count = 0;
    reg [7:0] received [0:15];
    integer i;

    always #500 clk = ~clk;

    uart_fixed_pattern_top #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE),
        .REPORT_HZ(1_000)
    ) dut (
        .clk50M(clk),
        .reset_n(reset_n),
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
            if (uart_tx !== 1'b1) begin
                $display("FAIL: stop bit low");
                $finish;
            end
            received[received_count] = value;
            received_count = received_count + 1;
        end
    endtask

    initial begin
        repeat (8) @(posedge clk);
        reset_n = 1'b1;
        for (i = 0; i < 16; i = i + 1)
            receive_byte();

        for (i = 0; i < 16; i = i + 1) begin
            case (i % 8)
                0: if (received[i] !== 8'h55) $fatal(1, "byte %0d", i);
                1: if (received[i] !== 8'hAA) $fatal(1, "byte %0d", i);
                2: if (received[i] !== 8'h12) $fatal(1, "byte %0d", i);
                3: if (received[i] !== 8'h34) $fatal(1, "byte %0d", i);
                4: if (received[i] !== 8'h56) $fatal(1, "byte %0d", i);
                5: if (received[i] !== 8'h78) $fatal(1, "byte %0d", i);
                6: if (received[i] !== 8'h0D) $fatal(1, "byte %0d", i);
                7: if (received[i] !== 8'h0A) $fatal(1, "byte %0d", i);
            endcase
        end
        $display("PASS: received two complete fixed UART patterns");
        $finish;
    end

    initial begin
        #10_000_000;
        $fatal(1, "timeout");
    end
endmodule
