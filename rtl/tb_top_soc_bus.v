`timescale 1ns/1ps

module tb_top_soc_bus;

    reg clk;
    reg rst_n;

    // Master 0 Signals
    reg [31:0] m0_awaddr; reg [31:0] m0_wdata; reg [3:0] m0_wstrb; reg m0_awvalid, m0_wvalid, m0_bready;
    wire m0_awready, m0_wready, m0_bvalid; wire [1:0] m0_bresp;
    reg [31:0] m0_araddr; reg m0_arvalid, m0_rready;
    wire m0_arready, m0_rvalid; wire [31:0] m0_rdata; wire [1:0] m0_rresp;

    // Master 1 Signals
    reg [31:0] m1_awaddr; reg [31:0] m1_wdata; reg [3:0] m1_wstrb; reg m1_awvalid, m1_wvalid, m1_bready;
    wire m1_awready, m1_wready, m1_bvalid; wire [1:0] m1_bresp;
    reg [31:0] m1_araddr; reg m1_arvalid, m1_rready;
    wire m1_arready, m1_rvalid; wire [31:0] m1_rdata; wire [1:0] m1_rresp;

    // Interconnect <-> Slave Signals
    wire [31:0] s0_awaddr, s0_wdata, s0_araddr, s0_rdata;
    wire [3:0] s0_wstrb; wire s0_awvalid, s0_wvalid, s0_bready, s0_arvalid, s0_rready;
    wire s0_awready, s0_wready, s0_bvalid, s0_arready, s0_rvalid; wire [1:0] s0_bresp, s0_rresp;

    wire [31:0] s1_awaddr, s1_wdata, s1_araddr, s1_rdata;
    wire [3:0] s1_wstrb; wire s1_awvalid, s1_wvalid, s1_bready, s1_arvalid, s1_rready;
    wire s1_awready, s1_wready, s1_bvalid, s1_arready, s1_rvalid; wire [1:0] s1_bresp, s1_rresp;

    // Instantiate Interconnect DUT
    axi4_lite_interconnect dut (
        .clk(clk), .rst_n(rst_n),
        .m0_awaddr(m0_awaddr), .m0_awvalid(m0_awvalid), .m0_awready(m0_awready),
        .m0_wdata(m0_wdata), .m0_wstrb(m0_wstrb), .m0_wvalid(m0_wvalid), .m0_wready(m0_wready),
        .m0_bresp(m0_bresp), .m0_bvalid(m0_bvalid), .m0_bready(m0_bready),
        .m0_araddr(m0_araddr), .m0_arvalid(m0_arvalid), .m0_arready(m0_arready),
        .m0_rdata(m0_rdata), .m0_rresp(m0_rresp), .m0_rvalid(m0_rvalid), .m0_rready(m0_rready),

        .m1_awaddr(m1_awaddr), .m1_awvalid(m1_awvalid), .m1_awready(m1_awready),
        .m1_wdata(m1_wdata), .m1_wstrb(m1_wstrb), .m1_wvalid(m1_wvalid), .m1_wready(m1_wready),
        .m1_bresp(m1_bresp), .m1_bvalid(m1_bvalid), .m1_bready(m1_bready),
        .m1_araddr(m1_araddr), .m1_arvalid(m1_arvalid), .m1_arready(m1_arready),
        .m1_rdata(m1_rdata), .m1_rresp(m1_rresp), .m1_rvalid(m1_rvalid), .m1_rready(m1_rready),

        .s0_awaddr(s0_awaddr), .s0_awvalid(s0_awvalid), .s0_awready(s0_awready),
        .s0_wdata(s0_wdata), .s0_wstrb(s0_wstrb), .s0_wvalid(s0_wvalid), .s0_wready(s0_wready),
        .s0_bresp(s0_bresp), .s0_bvalid(s0_bvalid), .s0_bready(s0_bready),
        .s0_araddr(s0_araddr), .s0_arvalid(s0_arvalid), .s0_arready(s0_arready),
        .s0_rdata(s0_rdata), .s0_rresp(s0_rresp), .s0_rvalid(s0_rvalid), .s0_rready(s0_rready),

        .s1_awaddr(s1_awaddr), .s1_awvalid(s1_awvalid), .s1_awready(s1_awready),
        .s1_wdata(s1_wdata), .s1_wstrb(s1_wstrb), .s1_wvalid(s1_wvalid), .s1_wready(s1_wready),
        .s1_bresp(s1_bresp), .s1_bvalid(s1_bvalid), .s1_bready(s1_bready),
        .s1_araddr(s1_araddr), .s1_arvalid(s1_arvalid), .s1_arready(s1_arready),
        .s1_rdata(s1_rdata), .s1_rresp(s1_rresp), .s1_rvalid(s1_rvalid), .s1_rready(s1_rready)
    );

    // Instantiate Real Memory Slave 0 (RAM)
    axi_ram_slave ram0 (
        .clk(clk), .rst_n(rst_n),
        .awaddr(s0_awaddr), .awvalid(s0_awvalid), .awready(s0_awready),
        .wdata(s0_wdata), .wstrb(s0_wstrb), .wvalid(s0_wvalid), .wready(s0_wready),
        .bresp(s0_bresp), .bvalid(s0_bvalid), .bready(s0_bready),
        .araddr(s0_araddr), .arvalid(s0_arvalid), .arready(s0_arready),
        .rdata(s0_rdata), .rresp(s0_rresp), .rvalid(s0_rvalid), .rready(s0_rready)
    );

    // Instantiate Real Memory Slave 1 (Peripheral Memory)
    axi_ram_slave ram1 (
        .clk(clk), .rst_n(rst_n),
        .awaddr(s1_awaddr), .awvalid(s1_awvalid), .awready(s1_awready),
        .wdata(s1_wdata), .wstrb(s1_wstrb), .wvalid(s1_wvalid), .wready(s1_wready),
        .bresp(s1_bresp), .bvalid(s1_bvalid), .bready(s1_bready),
        .araddr(s1_araddr), .arvalid(s1_arvalid), .arready(s1_arready),
        .rdata(s1_rdata), .rresp(s1_rresp), .rvalid(s1_rvalid), .rready(s1_rready)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/waveform.vcd");
        $dumpvars(0, tb_top_soc_bus);

        clk = 0; rst_n = 0;
        m0_awvalid = 0; m0_wvalid = 0; m0_bready = 1; m0_arvalid = 0; m0_rready = 1;
        m1_awvalid = 0; m1_wvalid = 0; m1_bready = 1; m1_arvalid = 0; m1_rready = 1;

        #15 rst_n = 1;

        // --- TESTCASE 1: Master 0 Writes 0xCAFEBABE into RAM (Slave 0: Addr 0x0000_0004) ---
        #10;
        m0_awaddr = 32'h0000_0004; m0_wdata = 32'hCAFEBABE; m0_wstrb = 4'b1111;
        m0_awvalid = 1; m0_wvalid = 1;
        #10;
        m0_awvalid = 0; m0_wvalid = 0;

        // --- TESTCASE 2: Master 0 Reads back from RAM (Slave 0: Addr 0x0000_0004) ---
        #20;
        m0_araddr = 32'h0000_0004; m0_arvalid = 1;
        #10;
        m0_arvalid = 0;

        // --- TESTCASE 3: Master 1 Accesses Unmapped Address (DECERR Test: Addr 0xF000_0000) ---
        #20;
        m1_araddr = 32'hF000_0000; m1_arvalid = 1;
        #10;
        m1_arvalid = 0;

        #40;
        $display("\n=======================================================");
        $display("   FULL AXI4-LITE BUS MATRIX SIMULATION COMPLETED!   ");
        $display("=======================================================\n");
        $finish;
    end

endmodule