module dvp_rgb565_capture #(
    parameter int WIDTH = 1280,
    parameter int HEIGHT = 720
) (
    input  logic        pclk,
    input  logic        reset,
    input  logic        vsync,
    input  logic        href,
    input  logic [7:0]  data,
    output logic [15:0] pixel,
    output logic        pixel_valid,
    output logic [10:0] x,
    output logic [9:0]  y,
    output logic        frame_start,
    output logic        frame_end,
    output logic        overflow
);
    logic vsync_d, href_d, high_byte;
    logic [7:0] first_byte;

    always_ff @(posedge pclk) begin
        if (reset) begin
            vsync_d <= 1'b0;
            href_d <= 1'b0;
            high_byte <= 1'b0;
            first_byte <= 8'd0;
            pixel <= 16'd0;
            pixel_valid <= 1'b0;
            x <= 0;
            y <= 0;
            frame_start <= 1'b0;
            frame_end <= 1'b0;
            overflow <= 1'b0;
        end else begin
            vsync_d <= vsync;
            href_d <= href;
            pixel_valid <= 1'b0;
            frame_start <= 1'b0;
            frame_end <= 1'b0;

            if (vsync && !vsync_d) begin
                x <= 0;
                y <= 0;
                high_byte <= 1'b0;
                frame_start <= 1'b1;
                overflow <= 1'b0;
            end else if (!vsync && vsync_d) begin
                frame_end <= 1'b1;
            end

            if (!href) begin
                high_byte <= 1'b0;
                x <= 0;
                if (href_d && y < HEIGHT-1)
                    y <= y + 10'd1;
            end else if (!high_byte) begin
                first_byte <= data;
                high_byte <= 1'b1;
            end else begin
                high_byte <= 1'b0;
                pixel <= {first_byte, data};
                if (x < WIDTH && y < HEIGHT) begin
                    pixel_valid <= 1'b1;
                    x <= x + 11'd1;
                end else begin
                    overflow <= 1'b1;
                end
            end
        end
    end
endmodule

