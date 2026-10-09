module axi4_lite_interconnect #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32
)(
    input wire clk,
    input wire rst_n,

    // --- Master 0 Interface ---
    input  wire [ADDR_WIDTH-1:0] m0_awaddr,  input  wire m0_awvalid, output reg  m0_awready,
    input  wire [DATA_WIDTH-1:0] m0_wdata,   input  wire [3:0] m0_wstrb, input wire m0_wvalid, output reg m0_wready,
    output reg  [1:0]            m0_bresp,   output reg  m0_bvalid,  input  wire m0_bready,
    input  wire [ADDR_WIDTH-1:0] m0_araddr,  input  wire m0_arvalid, output reg  m0_arready,
    output reg  [DATA_WIDTH-1:0] m0_rdata,   output reg  [1:0] m0_rresp, output reg m0_rvalid, input wire m0_rready,

    // --- Master 1 Interface ---
    input  wire [ADDR_WIDTH-1:0] m1_awaddr,  input  wire m1_awvalid, output reg  m1_awready,
    input  wire [DATA_WIDTH-1:0] m1_wdata,   input  wire [3:0] m1_wstrb, input wire m1_wvalid, output reg m1_wready,
    output reg  [1:0]            m1_bresp,   output reg  m1_bvalid,  input  wire m1_bready,
    input  wire [ADDR_WIDTH-1:0] m1_araddr,  input  wire m1_arvalid, output reg  m1_arready,
    output reg  [DATA_WIDTH-1:0] m1_rdata,   output reg  [1:0] m1_rresp, output reg m1_rvalid, input wire m1_rready,

    // --- Slave 0 Interface ---
    output reg  [ADDR_WIDTH-1:0] s0_awaddr,  output reg  s0_awvalid, input  wire s0_awready,
    output reg  [DATA_WIDTH-1:0] s0_wdata,   output reg  [3:0] s0_wstrb, output reg s0_wvalid, input wire s0_wready,
    input  wire [1:0]            s0_bresp,   input  wire s0_bvalid,  output reg  s0_bready,
    output reg  [ADDR_WIDTH-1:0] s0_araddr,  output reg  s0_arvalid, input  wire s0_arready,
    input  wire [DATA_WIDTH-1:0] s0_rdata,   input  wire [1:0] s0_rresp, input wire s0_rvalid, output reg s0_rready,

    // --- Slave 1 Interface ---
    output reg  [ADDR_WIDTH-1:0] s1_awaddr,  output reg  s1_awvalid, input  wire s1_awready,
    output reg  [DATA_WIDTH-1:0] s1_wdata,   output reg  [3:0] s1_wstrb, output reg s1_wvalid, input wire s1_wready,
    input  wire [1:0]            s1_bresp,   input  wire s1_bvalid,  output reg  s1_bready,
    output reg  [ADDR_WIDTH-1:0] s1_araddr,  output reg  s1_arvalid, input  wire s1_arready,
    input  wire [DATA_WIDTH-1:0] s1_rdata,   input  wire [1:0] s1_rresp, input wire s1_rvalid, output reg s1_rready
);

    wire read_grant, write_grant;
    wire [1:0] m0_r_sel, m1_r_sel, m0_w_sel, m1_w_sel;
    wire dec0_r_err, dec1_r_err, dec0_w_err, dec1_w_err;

    // Address Decoders
    address_decoder dec_m0_r (.addr(m0_araddr), .slave_sel(m0_r_sel), .decerr(dec0_r_err));
    address_decoder dec_m1_r (.addr(m1_araddr), .slave_sel(m1_r_sel), .decerr(dec1_r_err));
    address_decoder dec_m0_w (.addr(m0_awaddr), .slave_sel(m0_w_sel), .decerr(dec0_w_err));
    address_decoder dec_m1_w (.addr(m1_awaddr), .slave_sel(m1_w_sel), .decerr(dec1_w_err));

    // Round Robin Arbiters
    rr_arbiter r_arb (.clk(clk), .rst_n(rst_n), .req0(m0_arvalid), .req1(m1_arvalid), .grant(read_grant));
    rr_arbiter w_arb (.clk(clk), .rst_n(rst_n), .req0(m0_awvalid), .req1(m1_awvalid), .grant(write_grant));

    // READ MUX ROUTER
    always @(*) begin
        m0_arready = 0; m1_arready = 0; m0_rdata = 0; m1_rdata = 0;
        m0_rvalid = 0;  m1_rvalid = 0;  m0_rresp = 0; m1_rresp = 0;
        s0_arvalid = 0; s1_arvalid = 0; s0_araddr = 0; s1_araddr = 0;
        s0_rready = 0;  s1_rready = 0;

        if (read_grant == 1'b0) begin
            if (dec0_r_err && m0_arvalid) begin
                m0_arready = 1'b1; m0_rvalid = 1'b1; m0_rresp = 2'b11; // DECERR Response
                m0_rdata = 32'hDEAD_DEAD;
            end else if (m0_r_sel == 2'b01) begin
                s0_araddr = m0_araddr; s0_arvalid = m0_arvalid; m0_arready = s0_arready;
                m0_rdata = s0_rdata;   m0_rvalid = s0_rvalid;   m0_rresp = s0_rresp; s0_rready = m0_rready;
            end else if (m0_r_sel == 2'b10) begin
                s1_araddr = m0_araddr; s1_arvalid = m0_arvalid; m0_arready = s1_arready;
                m0_rdata = s1_rdata;   m0_rvalid = s1_rvalid;   m0_rresp = s1_rresp; s1_rready = m0_rready;
            end
        end else begin
            if (dec1_r_err && m1_arvalid) begin
                m1_arready = 1'b1; m1_rvalid = 1'b1; m1_rresp = 2'b11; // DECERR Response
                m1_rdata = 32'hDEAD_DEAD;
            end else if (m1_r_sel == 2'b01) begin
                s0_araddr = m1_araddr; s0_arvalid = m1_arvalid; m1_arready = s0_arready;
                m1_rdata = s0_rdata;   m1_rvalid = s0_rvalid;   m1_rresp = s0_rresp; s0_rready = m1_rready;
            end else if (m1_r_sel == 2'b10) begin
                s1_araddr = m1_araddr; s1_arvalid = m1_arvalid; m1_arready = s1_arready;
                m1_rdata = s1_rdata;   m1_rvalid = s1_rvalid;   m1_rresp = s1_rresp; s1_rready = m1_rready;
            end
        end
    end

    // WRITE MUX ROUTER
    always @(*) begin
        m0_awready = 0; m1_awready = 0; m0_wready = 0; m1_wready = 0;
        m0_bvalid = 0;  m1_bvalid = 0;  m0_bresp = 0;  m1_bresp = 0;
        s0_awvalid = 0; s1_awvalid = 0; s0_wvalid = 0; s1_wvalid = 0;
        s0_awaddr = 0;  s1_awaddr = 0;  s0_wdata = 0;  s1_wdata = 0;
        s0_wstrb = 0;   s1_wstrb = 0;   s0_bready = 0; s1_bready = 0;

        if (write_grant == 1'b0) begin
            if (dec0_w_err && m0_awvalid) begin
                m0_awready = 1'b1; m0_wready = 1'b1; m0_bvalid = 1'b1; m0_bresp = 2'b11; // DECERR
            end else if (m0_w_sel == 2'b01) begin
                s0_awaddr = m0_awaddr; s0_awvalid = m0_awvalid; m0_awready = s0_awready;
                s0_wdata  = m0_wdata;  s0_wstrb  = m0_wstrb;   s0_wvalid  = m0_wvalid; m0_wready = s0_wready;
                m0_bvalid = s0_bvalid; m0_bresp  = s0_bresp;   s0_bready  = m0_bready;
            end else if (m0_w_sel == 2'b10) begin
                s1_awaddr = m0_awaddr; s1_awvalid = m0_awvalid; m0_awready = s1_awready;
                s1_wdata  = m0_wdata;  s1_wstrb  = m0_wstrb;   s1_wvalid  = m0_wvalid; m0_wready = s1_wready;
                m0_bvalid = s1_bvalid; m0_bresp  = s1_bresp;   s1_bready  = m0_bready;
            end
        end else begin
            if (dec1_w_err && m1_awvalid) begin
                m1_awready = 1'b1; m1_wready = 1'b1; m1_bvalid = 1'b1; m1_bresp = 2'b11; // DECERR
            end else if (m1_w_sel == 2'b01) begin
                s0_awaddr = m1_awaddr; s0_awvalid = m1_awvalid; m1_awready = s0_awready;
                s0_wdata  = m1_wdata;  s0_wstrb  = m1_wstrb;   s0_wvalid  = m1_wvalid; m1_wready = s0_wready;
                m1_bvalid = s0_bvalid; m1_bresp  = s0_bresp;   s0_bready  = m1_bready;
            end else if (m1_w_sel == 2'b10) begin
                s1_awaddr = m1_awaddr; s1_awvalid = m1_awvalid; m1_awready = s1_awready;
                s1_wdata  = m1_wdata;  s1_wstrb  = m1_wstrb;   s1_wvalid  = m1_wvalid; m1_wready = s1_wready;
                m1_bvalid = s1_bvalid; m1_bresp  = s1_bresp;   s1_bready  = m1_bready;
            end
        end
    end

endmodule