`timescale 1ns / 1ps

// Minimal FPGA -> CP2102 UART hardware test for ACG720-GW5AT60.
// No camera, DDR, sensor, motor, or RK3588 application logic is involved.
module uart_fixed_pattern_top #(
    parameter integer CLK_FREQ  = 50_000_000,
    parameter integer BAUD_RATE = 115_200,
    parameter integer REPORT_HZ = 10
)(
    input  wire clk50M,
    input  wire reset_n,
    output wire uart_tx,
    output reg  status_led
);
    localparam integer REPORT_CLKS = CLK_FREQ / REPORT_HZ;
    localparam [1:0] ST_GAP  = 2'd0;
    localparam [1:0] ST_SEND = 2'd1;
    localparam [1:0] ST_WAIT = 2'd2;

    reg [1:0]  state;
    reg [31:0] report_count;
    reg [2:0]  byte_index;
    reg [7:0]  tx_data;
    reg        tx_start;
    wire       tx_busy;
    wire       tx_done;

    function [7:0] pattern_byte;
        input [2:0] index;
        begin
            case (index)
                3'd0: pattern_byte = 8'h55;
                3'd1: pattern_byte = 8'hAA;
                3'd2: pattern_byte = 8'h12;
                3'd3: pattern_byte = 8'h34;
                3'd4: pattern_byte = 8'h56;
                3'd5: pattern_byte = 8'h78;
                3'd6: pattern_byte = 8'h0D;
                default: pattern_byte = 8'h0A;
            endcase
        end
    endfunction

    always @(posedge clk50M or negedge reset_n) begin
        if (!reset_n) begin
            state        <= ST_GAP;
            report_count <= 32'd0;
            byte_index   <= 3'd0;
            tx_data      <= 8'h00;
            tx_start     <= 1'b0;
            status_led   <= 1'b0;
        end else begin
            tx_start <= 1'b0;
            case (state)
                ST_GAP: begin
                    if (report_count == REPORT_CLKS - 1) begin
                        report_count <= 32'd0;
                        byte_index   <= 3'd0;
                        state        <= ST_SEND;
                    end else begin
                        report_count <= report_count + 1'b1;
                    end
                end

                ST_SEND: begin
                    if (!tx_busy) begin
                        tx_data  <= pattern_byte(byte_index);
                        tx_start <= 1'b1;
                        state    <= ST_WAIT;
                    end
                end

                ST_WAIT: begin
                    if (tx_done) begin
                        if (byte_index == 3'd7) begin
                            status_led <= ~status_led;
                            state      <= ST_GAP;
                        end else begin
                            byte_index <= byte_index + 1'b1;
                            state      <= ST_SEND;
                        end
                    end
                end

                default: state <= ST_GAP;
            endcase
        end
    end

    uart_tx_byte #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) u_uart_tx (
        .clk(clk50M),
        .reset_n(reset_n),
        .data_in(tx_data),
        .start(tx_start),
        .tx(uart_tx),
        .busy(tx_busy),
        .done(tx_done)
    );
endmodule

module uart_tx_byte #(
    parameter integer CLK_FREQ  = 50_000_000,
    parameter integer BAUD_RATE = 115_200
)(
    input  wire       clk,
    input  wire       reset_n,
    input  wire [7:0] data_in,
    input  wire       start,
    output reg        tx,
    output reg        busy,
    output reg        done
);
    // Rounded integer divider: 50 MHz / 115200 -> 434 clocks/bit.
    localparam integer BIT_CLKS = (CLK_FREQ + BAUD_RATE / 2) / BAUD_RATE;

    reg [31:0] clock_count;
    reg [3:0]  bit_index;
    reg [7:0]  data_latched;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            tx           <= 1'b1;
            busy         <= 1'b0;
            done         <= 1'b0;
            clock_count  <= 32'd0;
            bit_index    <= 4'd0;
            data_latched <= 8'h00;
        end else begin
            done <= 1'b0;
            if (!busy) begin
                tx          <= 1'b1;
                clock_count <= 32'd0;
                bit_index   <= 4'd0;
                if (start) begin
                    data_latched <= data_in;
                    busy         <= 1'b1;
                    tx           <= 1'b0;
                end
            end else if (clock_count == BIT_CLKS - 1) begin
                clock_count <= 32'd0;
                if (bit_index < 4'd8) begin
                    tx        <= data_latched[bit_index];
                    bit_index <= bit_index + 1'b1;
                end else if (bit_index == 4'd8) begin
                    tx        <= 1'b1;
                    bit_index <= 4'd9;
                end else begin
                    tx   <= 1'b1;
                    busy <= 1'b0;
                    done <= 1'b1;
                end
            end else begin
                clock_count <= clock_count + 1'b1;
            end
        end
    end
endmodule
