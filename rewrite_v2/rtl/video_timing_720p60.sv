module video_timing_720p60 (
    input  logic        pixel_clk,
    input  logic        reset,
    output logic [10:0] x,
    output logic [9:0]  y,
    output logic        hsync,
    output logic        vsync,
    output logic        de,
    output logic        frame_start
);
    localparam int H_ACTIVE = 1280;
    localparam int H_FRONT  = 110;
    localparam int H_SYNC   = 40;
    localparam int H_TOTAL  = 1650;
    localparam int V_ACTIVE = 720;
    localparam int V_FRONT  = 5;
    localparam int V_SYNC   = 5;
    localparam int V_TOTAL  = 750;

    always_ff @(posedge pixel_clk) begin
        if (reset) begin
            x <= 0;
            y <= 0;
        end else if (x == H_TOTAL - 1) begin
            x <= 0;
            y <= (y == V_TOTAL - 1) ? 10'd0 : y + 10'd1;
        end else begin
            x <= x + 11'd1;
        end
    end

    always_comb begin
        de = (x < H_ACTIVE) && (y < V_ACTIVE);
        hsync = (x >= H_ACTIVE + H_FRONT) &&
                (x <  H_ACTIVE + H_FRONT + H_SYNC);
        vsync = (y >= V_ACTIVE + V_FRONT) &&
                (y <  V_ACTIVE + V_FRONT + V_SYNC);
        frame_start = (x == 0) && (y == 0);
    end
endmodule
