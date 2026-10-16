`timescale 1ns / 1ps

// Board-level locator for the physical P7 pin connected to FPGA ball E14.
// E14 and the known-safe D2 LED (L21) change level together every two seconds.
module e14_pin_locator #(
    parameter integer CLK_FREQ = 50_000_000
)(
    input  wire clk50M,
    output reg  e14_probe,
    output reg  status_led
);
    localparam integer TOGGLE_CLKS = CLK_FREQ * 2;
    reg [31:0] counter;

    initial begin
        counter    = 32'd0;
        e14_probe  = 1'b0;
        status_led = 1'b0;
    end

    always @(posedge clk50M) begin
        if (counter == TOGGLE_CLKS - 1) begin
            counter    <= 32'd0;
            e14_probe  <= ~e14_probe;
            status_led <= ~status_led;
        end else begin
            counter <= counter + 1'b1;
        end
    end
endmodule
