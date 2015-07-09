`timescale 1ns/1ps

`include "cpu_interface.svi"
`include "packet_interface.svi"
`include "test.sv"

module top;
parameter clock_cycle = 10;

logic clk;

cpu_interface cpu_intf(clk);
packet_interface pkt_intf(clk);

test u_test(cpu_intf, pkt_intf);

dut u_dut (
    .clk    (pkt_intf.clk    ) ,
    .rst_n  (pkt_intf.rst_n  ) ,

    .addr   (cpu_intf.addr   ) ,
    .rw     (cpu_intf.rw     ) ,
    .din    (cpu_intf.dout   ) ,
    .dout   (cpu_intf.din    ) ,

    .txd    (pkt_intf.rxd    ) ,
    .tx_vld (pkt_intf.rx_vld ) ,
    .rxd    (pkt_intf.txd    ) ,
    .rx_vld (pkt_intf.tx_vld )   
);

initial begin
    $timeformat(-9, 1, "ns", 10);
    clk = 0;
    forever begin
        #(clock_cycle/2) clk = ~clk;
    end
end

`ifdef WAVE_ON
initial begin
    $vcdpluson();
end
`endif

endmodule

