module axi4_lite_bus_matrix_top #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter STRB_WIDTH = DATA_WIDTH/8
)(
    input wire clk,
    input wire rst_n,

    // --- Master 0 Interface ---
    input  wire [ADDR_WIDTH-1:0] m0_awaddr,  input  wire m0_awvalid, output reg  m0_awready,
    input  wire [DATA_WIDTH-1:0] m0_wdata,   input  wire [STRB_WIDTH-1:0] m0_wstrb, input wire m0_wvalid, output reg m0_wready,
    output reg  [1:0]            m0_bresp,   output reg  m0_bvalid,  input  wire m0_bready,
    input  wire [ADDR_WIDTH-1:0] m0_araddr,  input  wire m0_arvalid, output reg  m0_arready,
    output reg  [DATA_WIDTH-1:0] m0_rdata,   output reg  [1:0] m0_rresp, output reg m0_rvalid, input wire m0_rready,

    // --- Master 1 Interface ---
    input  wire [ADDR_WIDTH-1:0] m1_awaddr,  input  wire m1_awvalid, output reg  m1_awready,
    input  wire [DATA_WIDTH-1:0] m1_wdata,   input  wire [STRB_WIDTH-1:0] m1_wstrb, input wire m1_wvalid, output reg m1_wready,
    output reg  [1:0]            m1_bresp,   output reg  m1_bvalid,  input  wire m1_bready,
    input  wire [ADDR_WIDTH-1:0] m1_araddr,  input  wire m1_arvalid, output reg  m1_arready,
    output reg  [DATA_WIDTH-1:0] m1_rdata,   output reg  [1:0] m1_rresp, output reg m1_rvalid, input wire m1_rready,

    // --- Slave 0 Interface ---
    output reg  [ADDR_WIDTH-1:0] s0_awaddr,  output reg  s0_awvalid, input  wire s0_awready,
    output reg  [DATA_WIDTH-1:0] s0_wdata,   output reg  [STRB_WIDTH-1:0] s0_wstrb, output reg s0_wvalid, input wire s0_wready,
    input  wire [1:0]            s0_bresp,   input  wire s0_bvalid,  output reg  s0_bready,
    output reg  [ADDR_WIDTH-1:0] s0_araddr,  output reg  s0_arvalid, input  wire s0_arready,
    input  wire [DATA_WIDTH-1:0] s0_rdata,   input  wire [1:0] s0_rresp, input wire s0_rvalid, output reg s0_rready,

    // --- Slave 1 Interface ---
    output reg  [ADDR_WIDTH-1:0] s1_awaddr,  output reg  s1_awvalid, input  wire s1_awready,
    output reg  [DATA_WIDTH-1:0] s1_wdata,   output reg  [STRB_WIDTH-1:0] s1_wstrb, output reg s1_wvalid, input wire s1_wready,
    input  wire [1:0]            s1_bresp,   input  wire s1_bvalid,  output reg  s1_bready,
    output reg  [ADDR_WIDTH-1:0] s1_araddr,  output reg  s1_arvalid, input  wire s1_arready,
    input  wire [DATA_WIDTH-1:0] s1_rdata,   input  wire [1:0] s1_rresp, input wire s1_rvalid, output reg s1_rready
);

    // Arbiters
    reg r_grant, w_grant;
    wire dec0_err, dec1_err;
    wire [1:0] m0_s_sel, m1_s_sel;

    address_decoder dec0 (.addr(m0_araddr), .slave_sel(m0_s_sel), .dec_err(dec0_err));
    address_decoder dec1 (.addr(m1_araddr), .slave_sel(m1_s_sel), .dec_err(dec1_err));

    // Round-Robin Priority Logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            r_grant <= 0; w_grant <= 0;
        end else begin
            if (m0_arvalid && !m1_arvalid) r_grant <= 0;
            else if (!m0_arvalid && m1_arvalid) r_grant <= 1;
            else if (m0_arvalid && m1_arvalid) r_grant <= ~r_grant;

            if (m0_awvalid && !m1_awvalid) w_grant <= 0;
            else if (!m0_awvalid && m1_awvalid) w_grant <= 1;
            else if (m0_awvalid && m1_awvalid) w_grant <= ~w_grant;
        end
    end

    // Full Dynamic Muxing for Read & Write Channels
    always @(*) begin
        // Reset defaults
        s0_awvalid = 0; s1_awvalid = 0; s0_wvalid = 0; s1_wvalid = 0;
        s0_arvalid = 0; s1_arvalid = 0;
        m0_awready = 0; m1_awready = 0; m0_wready = 0; m1_wready = 0;
        m0_arready = 0; m1_arready = 0;
        m0_bresp = 2'b00; m1_bresp = 2'b00; m0_rresp = 2'b00; m1_rresp = 2'b00;

        // --- READ ROUTING ---
        if (r_grant == 0) begin
            if (dec0_err && m0_arvalid) begin
                m0_arready = 1'b1; m0_rvalid = 1'b1; m0_rresp = 2'b11; // DECERR Response
                m0_rdata = 32'hDEAD_DEAD;
            end else if (m0_s_sel == 2'b01) begin
                s0_araddr = m0_araddr; s0_arvalid = m0_arvalid; m0_arready = s0_arready;
                m0_rdata = s0_rdata; m0_rvalid = s0_rvalid; m0_rresp = s0_rresp; s0_rready = m0_rready;
            end else if (m0_s_sel == 2'b10) begin
                s1_araddr = m0_araddr; s1_arvalid = m0_arvalid; m0_arready = s1_arready;
                m0_rdata = s1_rdata; m0_rvalid = s1_rvalid; m0_rresp = s1_rresp; s1_rready = m0_rready;
            end
        end else begin
            if (dec1_err && m1_arvalid) begin
                m1_arready = 1'b1; m1_rvalid = 1'b1; m1_rresp = 2'b11; // DECERR Response
                m1_rdata = 32'hDEAD_DEAD;
            end else if (m1_s_sel == 2'b01) begin
                s0_araddr = m1_araddr; s0_arvalid = m1_arvalid; m1_arready = s0_arready;
                m1_rdata = s0_rdata; m1_rvalid = s0_rvalid; m1_rresp = s0_rresp; s0_rready = m1_rready;
            end else if (m1_s_sel == 2'b10) begin
                s1_araddr = m1_araddr; s1_arvalid = m1_arvalid; m1_arready = s1_arready;
                m1_rdata = s1_rdata; m1_rvalid = s1_rvalid; m1_rresp = s1_rresp; s1_rready = m1_rready;
            end
        end

        // --- WRITE ROUTING ---
        if (w_grant == 0) begin
            if (m0_awaddr <= 32'h3FFF_FFFF) begin
                s0_awaddr = m0_awaddr; s0_awvalid = m0_awvalid; m0_awready = s0_awready;
                s0_wdata  = m0_wdata;  s0_wstrb  = m0_wstrb;   s0_wvalid  = m0_wvalid; m0_wready = s0_wready;
                m0_bvalid = s0_bvalid; m0_bresp  = s0_bresp;   s0_bready  = m0_bready;
            end else begin
                s1_awaddr = m0_awaddr; s1_awvalid = m0_awvalid; m0_awready = s1_awready;
                s1_wdata  = m0_wdata;  s1_wstrb  = m0_wstrb;   s1_wvalid  = m0_wvalid; m0_wready = s1_wready;
                m0_bvalid = s1_bvalid; m0_bresp  = s1_bresp;   s1_bready  = m0_bready;
            end
        end else begin
            if (m1_awaddr <= 32'h3FFF_FFFF) begin
                s0_awaddr = m1_awaddr; s0_awvalid = m1_awvalid; m1_awready = s0_awready;
                s0_wdata  = m1_wdata;  s0_wstrb  = m1_wstrb;   s0_wvalid  = m1_wvalid; m1_wready = s0_wready;
                m1_bvalid = s0_bvalid; m1_bresp  = s0_bresp;   s0_bready  = m1_bready;
            end else begin
                s1_awaddr = m1_awaddr; s1_awvalid = m1_awvalid; m1_awready = s1_awready;
                s1_wdata  = m1_wdata;  s1_wstrb  = m1_wstrb;   s1_wvalid  = m1_wvalid; m1_wready = s1_wready;
                m1_bvalid = s1_bvalid; m1_bresp  = s1_bresp;   s1_bready  = m1_bready;
            end
        end
    end
endmodule