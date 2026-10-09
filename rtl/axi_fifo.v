module axi_fifo #(
    parameter DATA_WIDTH = 32,
    parameter DEPTH = 4
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire [DATA_WIDTH-1:0] wdata,
    input  wire                  wvalid,
    output wire                  wready,
    output wire [DATA_WIDTH-1:0] rdata,
    output wire                  rvalid,
    input  wire                  rready
);

    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    reg [$clog2(DEPTH):0] wptr, rptr, count;

    assign wready = (count < DEPTH);
    assign rvalid = (count > 0);
    assign rdata  = mem[rptr[$clog2(DEPTH)-1:0]];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wptr <= 0; rptr <= 0; count <= 0;
        end else begin
            if (wvalid && wready) begin
                mem[wptr[$clog2(DEPTH)-1:0]] <= wdata;
                wptr <= wptr + 1;
            end
            if (rvalid && rready) begin
                rptr <= rptr + 1;
            end
            case ({wvalid && wready, rvalid && rready})
                2'b10: count <= count + 1;
                2'b01: count <= count - 1;
                default: count <= count;
            endcase
        end
    end
endmodule