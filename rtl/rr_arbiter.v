module rr_arbiter (
    input  wire clk,
    input  wire rst_n,
    input  wire req0,
    input  wire req1,
    output reg  grant
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            grant <= 1'b0;
        end else begin
            if (req0 && !req1)      grant <= 1'b0;
            else if (!req0 && req1) grant <= 1'b1;
            else if (req0 && req1)   grant <= ~grant; // Priority Toggle
        end
    end

endmodule