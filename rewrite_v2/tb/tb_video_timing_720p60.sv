`timescale 1ns/1ps
module tb_video_timing_720p60;
    logic clk = 0;
    logic reset = 1;
    logic [10:0] x;
    logic [9:0] y;
    logic hs, vs, de, frame_start;
    integer cycles = 0;
    integer active = 0;
    integer hs_high = 0;
    integer vs_lines = 0;

    always #5 clk = ~clk;
    video_timing_720p60 dut(.pixel_clk(clk), .reset(reset), .x(x), .y(y),
        .hsync(hs), .vsync(vs), .de(de), .frame_start(frame_start));

    initial begin
        repeat (3) @(posedge clk);
        reset <= 0;
        repeat (1650*750) begin
            @(negedge clk);
            cycles = cycles + 1;
            if (de) active = active + 1;
            if (hs) hs_high = hs_high + 1;
            if (x == 0 && vs) vs_lines = vs_lines + 1;
        end
        if (cycles != 1237500) $fatal(1, "bad frame cycles %0d", cycles);
        if (active != 1280*720) $fatal(1, "bad active pixels %0d", active);
        if (hs_high != 40*750) $fatal(1, "bad hsync width total %0d", hs_high);
        if (vs_lines != 5) $fatal(1, "bad vsync lines %0d", vs_lines);
        $display("PASS video timing cycles=%0d active=%0d", cycles, active);
        $finish;
    end
endmodule

