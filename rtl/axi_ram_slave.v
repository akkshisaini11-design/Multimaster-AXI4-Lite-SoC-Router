module axi_ram_slave #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter MEM_DEPTH  = 256
)(
    input wire clk,
    input wire rst_n,

    // Write Address Channel
    input  wire [ADDR_WIDTH-1:0] awaddr,
    input  wire                  awvalid,
    output reg                   awready,

    // Write Data Channel
    input  wire [DATA_WIDTH-1:0] wdata,
    input  wire [3:0]            wstrb,
    input  wire                  wvalid,
    output reg                   wready,

    // Write Response Channel
    output reg  [1:0]            bresp,
    output reg                   bvalid,
    input  wire                  bready,

    // Read Address Channel
    input  wire [ADDR_WIDTH-1:0] araddr,
    input  wire                  arvalid,
    output reg                   arready,

    // Read Data Channel
    output reg  [DATA_WIDTH-1:0] rdata,
    output reg  [1:0]            rresp,
    output reg                   rvalid,
    input  wire                  rready
);

    reg [DATA_WIDTH-1:0] mem [0:MEM_DEPTH-1];
    wire [$clog2(MEM_DEPTH)-1:0] windex = awaddr[$clog2(MEM_DEPTH)+1:2];
    wire [$clog2(MEM_DEPTH)-1:0] rindex = araddr[$clog2(MEM_DEPTH)+1:2];

    // Write Logic with Byte Strobes (WSTRB)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            awready <= 0; wready <= 0; bvalid <= 0; bresp <= 2'b00;
        end else begin
            awready <= awvalid;
            wready  <= wvalid;
            
            if (awvalid && wvalid) begin
                if (wstrb[0]) mem[windex][ 7: 0] <= wdata[ 7: 0];
                if (wstrb[1]) mem[windex][15: 8] <= wdata[15: 8];
                if (wstrb[2]) mem[windex][23:16] <= wdata[23:16];
                if (wstrb[3]) mem[windex][31:24] <= wdata[31:24];
                
                bvalid <= 1'b1;
                bresp  <= 2'b00; // OKAY Response
            end else if (bready && bvalid) begin
                bvalid <= 1'b0;
            end
        end
    end

    // Read Logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            arready <= 0; rvalid <= 0; rdata <= 0; rresp <= 2'b00;
        end else begin
            arready <= arvalid;
            if (arvalid) begin
                rdata  <= mem[rindex];
                rvalid <= 1'b1;
                rresp  <= 2'b00; // OKAY Response
            end else if (rready && rvalid) begin
                rvalid <= 1'b0;
            end
        end
    end

endmodule