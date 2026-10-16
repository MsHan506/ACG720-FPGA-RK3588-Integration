module reset_release #(
    parameter int STABLE_CYCLES = 1_048_576
) (
    input  logic clk,
    input  logic external_reset_n,
    input  logic pll_locked_async,
    output logic reset
);
    localparam int COUNT_W = $clog2(STABLE_CYCLES + 1);
    (* syn_preserve = 1, ASYNC_REG = "TRUE" *) logic lock_meta, lock_sync;
    logic [COUNT_W-1:0] count;

    always_ff @(posedge clk or negedge external_reset_n) begin
        if (!external_reset_n) begin
            lock_meta <= 1'b0;
            lock_sync <= 1'b0;
            count <= '0;
            reset <= 1'b1;
        end else begin
            lock_meta <= pll_locked_async;
            lock_sync <= lock_meta;
            if (!lock_sync) begin
                count <= '0;
                reset <= 1'b1;
            end else if (count < STABLE_CYCLES) begin
                count <= count + 1'b1;
                reset <= 1'b1;
            end else begin
                reset <= 1'b0;
            end
        end
    end
endmodule
