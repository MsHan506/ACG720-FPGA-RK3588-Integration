`timescale 1ns / 1ps

// Minimal ACG720 onboard UART test:
// FPGA M15 -> onboard CH9102 -> board J2 Type-C -> RK3588 USB.
module uart_onboard_ch9102_test #(
    parameter integer CLK_FREQ  = 50_000_000,
    parameter integer BAUD_RATE = 9_600,
    parameter integer REPORT_HZ = 2
)(
    input  wire clk50M,
    output wire uart_tx,
    output reg  status_led
);
    localparam integer REPORT_CLKS = CLK_FREQ / REPORT_HZ;
    localparam [1:0] ST_GAP  = 2'd0;
    localparam [1:0] ST_SEND = 2'd1;
    localparam [1:0] ST_WAIT = 2'd2;

    reg [1:0]  state;
    reg [31:0] report_count;
    reg [4:0]  byte_index;
    reg [7:0]  tx_data;
    reg        tx_start;
    wire       tx_busy;
    wire       tx_done;

    // "ONBOARD_UART_OK\r\n"
    function [7:0] message_byte;
        input [4:0] index;
        begin
            case (index)
                5'd0:  message_byte = 8'h4F; // O
                5'd1:  message_byte = 8'h4E; // N
                5'd2:  message_byte = 8'h42; // B
                5'd3:  message_byte = 8'h4F; // O
                5'd4:  message_byte = 8'h41; // A
                5'd5:  message_byte = 8'h52; // R
                5'd6:  message_byte = 8'h44; // D
                5'd7:  message_byte = 8'h5F; // _
                5'd8:  message_byte = 8'h55; // U
                5'd9:  message_byte = 8'h41; // A
                5'd10: message_byte = 8'h52; // R
                5'd11: message_byte = 8'h54; // T
                5'd12: message_byte = 8'h5F; // _
                5'd13: message_byte = 8'h4F; // O
                5'd14: message_byte = 8'h4B; // K
                5'd15: message_byte = 8'h0D;
                default: message_byte = 8'h0A;
            endcase
        end
    endfunction

    initial begin
        state        = ST_GAP;
        report_count = 32'd0;
        byte_index   = 5'd0;
        tx_data      = 8'h00;
        tx_start     = 1'b0;
        status_led   = 1'b0;
    end

    always @(posedge clk50M) begin
        tx_start <= 1'b0;
        case (state)
            ST_GAP: begin
                if (report_count == REPORT_CLKS - 1) begin
                    report_count <= 32'd0;
                    byte_index   <= 5'd0;
                    state        <= ST_SEND;
                end else begin
                    report_count <= report_count + 1'b1;
                end
            end

            ST_SEND: begin
                if (!tx_busy) begin
                    tx_data  <= message_byte(byte_index);
                    tx_start <= 1'b1;
                    state    <= ST_WAIT;
                end
            end

            ST_WAIT: begin
                if (tx_done) begin
                    if (byte_index == 5'd16) begin
                        status_led <= ~status_led;
                        state      <= ST_GAP;
                    end else begin
                        byte_index <= byte_index + 1'b1;
                        state      <= ST_SEND;
                    end
                end
            end

            default: begin
                state        <= ST_GAP;
                report_count <= 32'd0;
            end
        endcase
    end

    uart_tx_byte_onboard #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) u_uart_tx (
        .clk(clk50M),
        .data_in(tx_data),
        .start(tx_start),
        .tx(uart_tx),
        .busy(tx_busy),
        .done(tx_done)
    );
endmodule

module uart_tx_byte_onboard #(
    parameter integer CLK_FREQ  = 50_000_000,
    parameter integer BAUD_RATE = 9_600
)(
    input  wire       clk,
    input  wire [7:0] data_in,
    input  wire       start,
    output reg        tx,
    output reg        busy,
    output reg        done
);
    localparam integer BIT_CLKS = (CLK_FREQ + BAUD_RATE / 2) / BAUD_RATE;

    reg [31:0] clock_count;
    reg [3:0]  bit_index;
    reg [7:0]  data_latched;

    initial begin
        tx           = 1'b1;
        busy         = 1'b0;
        done         = 1'b0;
        clock_count  = 32'd0;
        bit_index    = 4'd0;
        data_latched = 8'h00;
    end

    always @(posedge clk) begin
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
endmodule
