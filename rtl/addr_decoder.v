module addr_decoder #(
    parameter ADDR_WIDTH = 32
)(
    input  wire [ADDR_WIDTH-1:0] addr,
    output wire [1:0] slave_sel
);

    // MSB bit decoding
    assign slave_sel = (addr[ADDR_WIDTH-1] == 1'b0) ? 2'b01 : 2'b10;

endmodule