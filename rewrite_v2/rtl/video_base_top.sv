module video_base_top (
    input  wire       clk50M,
    input  wire       reset_n,
    output wire       tmds_clk_p,
    output wire       tmds_clk_n,
    output wire [2:0] tmds_data_p,
    output wire [2:0] tmds_data_n,
    output wire [3:0] led
);
    wire serial_clk_x5;
    wire pixel_clk;
    wire pll_locked;
    wire video_reset;
    wire [10:0] x;
    wire [9:0] y;
    wire hsync, vsync, de, frame_start;
    wire [23:0] rgb;

    camera_pll u_video_pll (
        .clkout0(serial_clk_x5),
        .clkout1(),
        .lock(pll_locked),
        .clkin(clk50M)
    );

    CLKDIV u_pixel_div (
        .RESETN(1'b1),
        .HCLKIN(serial_clk_x5),
        .CLKOUT(pixel_clk),
        .CALIB(1'b1)
    );
    defparam u_pixel_div.DIV_MODE = "5";

    reset_release u_reset_release (
        .clk(pixel_clk),
        .external_reset_n(reset_n),
        .pll_locked_async(pll_locked),
        .reset(video_reset)
    );

    video_timing_720p60 u_timing (
        .pixel_clk(pixel_clk), .reset(video_reset),
        .x(x), .y(y), .hsync(hsync), .vsync(vsync), .de(de),
        .frame_start(frame_start)
    );

    colour_bars u_bars (.x(x), .de(de), .rgb(rgb));

    DVI_TX_Top u_dvi_tx (
        .I_rst_n(1'b1),
        .I_serial_clk(serial_clk_x5),
        .I_rgb_clk(pixel_clk),
        .I_rgb_vs(vsync),
        .I_rgb_hs(hsync),
        .I_rgb_de(de && !video_reset),
        .I_rgb_r(rgb[23:16]),
        .I_rgb_g(rgb[15:8]),
        .I_rgb_b(rgb[7:0]),
        .O_tmds_clk_p(tmds_clk_p),
        .O_tmds_clk_n(tmds_clk_n),
        .O_tmds_data_p(tmds_data_p),
        .O_tmds_data_n(tmds_data_n)
    );

    assign led = {frame_start, de, !video_reset, pll_locked};
endmodule

