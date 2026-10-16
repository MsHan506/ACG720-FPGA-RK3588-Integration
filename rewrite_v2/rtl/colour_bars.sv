module colour_bars (
    input  logic [10:0] x,
    input  logic        de,
    output logic [23:0] rgb
);
    always_comb begin
        if (!de)             rgb = 24'h000000;
        else if (x < 160)    rgb = 24'hFFFFFF;
        else if (x < 320)    rgb = 24'hFFFF00;
        else if (x < 480)    rgb = 24'h00FFFF;
        else if (x < 640)    rgb = 24'h00FF00;
        else if (x < 800)    rgb = 24'hFF00FF;
        else if (x < 960)    rgb = 24'hFF0000;
        else if (x < 1120)   rgb = 24'h0000FF;
        else                 rgb = 24'h000000;
    end
endmodule

