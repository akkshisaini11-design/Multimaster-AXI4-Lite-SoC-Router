module address_decoder #(
    parameter ADDR_WIDTH = 32
)(
    input  wire [ADDR_WIDTH-1:0] addr,
    output reg  [1:0]            slave_sel, // 2'b01: Slave 0, 2'b10: Slave 1
    output reg                   decerr     // Decode Error Signal
);

    always @(*) begin
        decerr    = 1'b0;
        slave_sel = 2'b00;

        // Slave 0: RAM (0x0000_0000 - 0x3FFF_FFFF)
        if (addr >= 32'h0000_0000 && addr <= 32'h3FFF_FFFF) begin
            slave_sel = 2'b01;
        end
        // Slave 1: Peripherals (0x4000_0000 - 0x7FFF_FFFF)
        else if (addr >= 32'h4000_0000 && addr <= 32'h7FFF_FFFF) begin
            slave_sel = 2'b10;
        end
        // Unmapped Address
        else begin
            decerr    = 1'b1;
        end
    end

endmodule