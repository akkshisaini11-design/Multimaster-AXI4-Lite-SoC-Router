`timescale 1ns/1ps

module tb_axi4_lite_interconnect;

    reg clk;
    reg rst_n;

    reg [31:0] m0_araddr; reg m0_arvalid; wire m0_arready;
    wire [31:0] m0_rdata; wire m0_rvalid; reg m0_rready;

    reg [31:0] m1_araddr; reg m1_arvalid; wire m1_arready;
    wire [31:0] m1_rdata; wire m1_rvalid; reg m1_rready;

    reg s0_arready; reg [31:0] s0_rdata; reg s0_rvalid; wire s0_rready;
    reg s1_arready; reg [31:0] s1_rdata; reg s1_rvalid; wire s1_rready;

    axi4_lite_interconnect dut (
        .clk(clk), .rst_n(rst_n),
        .m0_araddr(m0_araddr), .m0_arvalid(m0_arvalid), .m0_arready(m0_arready),
        .m0_rdata(m0_rdata), .m0_rvalid(m0_rvalid), .m0_rready(m0_rready),
        .m1_araddr(m1_araddr), .m1_arvalid(m1_arvalid), .m1_arready(m1_arready),
        .m1_rdata(m1_rdata), .m1_rvalid(m1_rvalid), .m1_rready(m1_rready),
        .s0_arready(s0_arready), .s0_rdata(s0_rdata), .s0_rvalid(s0_rvalid), .s0_rready(s0_rready),
        .s1_arready(s1_arready), .s1_rdata(s1_rdata), .s1_rvalid(s1_rvalid), .s1_rready(s1_rready)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/waveform.vcd");
        $dumpvars(0, tb_axi4_lite_interconnect);

        clk = 0; rst_n = 0;
        m0_arvalid = 0; m1_arvalid = 0;
        m0_rready = 1;  m1_rready = 1;
        s0_arready = 1; s1_arready = 1;
        s0_rdata = 32'hAAAA_AAAA; s0_rvalid = 1;
        s1_rdata = 32'hBBBB_BBBB; s1_rvalid = 1;

        #15 rst_n = 1;

        // Test 1: M0 accesses S0
        #10 m0_araddr = 32'h1000_0000; m0_arvalid = 1;
        #10 m0_arvalid = 0;

        // Test 2: M1 accesses S1
        #10 m1_araddr = 32'h9000_0000; m1_arvalid = 1;
        #10 m1_arvalid = 0;

        #20 $finish;
    end

endmodule