`timescale 1ns/1ps
module tb_dvp_rgb565_capture;
    logic clk=0, reset=1, vsync=0, href=0;
    logic [7:0] data=0;
    logic [15:0] pixel;
    logic valid, fs, fe, overflow;
    logic [10:0] x;
    logic [9:0] y;
    integer seen=0;
    always #5 clk=~clk;
    dvp_rgb565_capture #(.WIDTH(4),.HEIGHT(2)) dut(.*,.pclk(clk),.pixel_valid(valid),.frame_start(fs),.frame_end(fe));
    task send_byte(input [7:0] v); begin data=v; @(posedge clk); #1; end endtask
    initial begin
        repeat(2) @(posedge clk); reset=0;
        vsync=1; @(posedge clk); #1; vsync=0; @(posedge clk); #1;
        href=1;
        send_byte(8'h12); send_byte(8'h34); if(!valid || pixel!==16'h1234) $fatal(1,"pixel0"); seen++;
        send_byte(8'hAB); send_byte(8'hCD); if(!valid || pixel!==16'hABCD) $fatal(1,"pixel1"); seen++;
        href=0; @(posedge clk); #1;
        href=1;
        send_byte(8'h55); send_byte(8'hAA); if(!valid || pixel!==16'h55AA || y!=1) $fatal(1,"line1"); seen++;
        href=0; @(posedge clk); #1;
        vsync=1; @(posedge clk); #1;
        if(seen!=3 || overflow) $fatal(1,"summary");
        $display("PASS DVP capture pixels=%0d",seen); $finish;
    end
endmodule
