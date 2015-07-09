`ifndef __PACKET_ENV_SV__
`define __PACKET_ENV_SV__

`include "packet_interface.svi"
`include "packet_transaction.sv"
`include "packet_generator.sv"
`include "packet_define.sv"
`include "packet_driver.sv"
`include "packet_scoreboard.sv"
`include "packet_monitor.sv"

class packet_env;

packet_tran_mbox  gen2drv_mbox = new(1);
packet_tran_mbox  drv2sb_mbox = new();
packet_tran_mbox  mon2sb_mbox = new();
packet_generator  pkt_gen;
packet_driver     pkt_drv;
packet_scoreboard pkt_sb;
packet_monitor    pkt_mon;

virtual packet_interface.master pkt_intf;

extern function new(virtual packet_interface.master pkt_intf);
extern function configure();
extern task reset();
extern task start();

endclass

function packet_env::new(virtual packet_interface.master pkt_intf);
    this.pkt_intf = pkt_intf;
    pkt_gen = new("Packet Generator", gen2drv_mbox);
    pkt_drv = new("Packet Driver", gen2drv_mbox, drv2sb_mbox, pkt_intf);
    pkt_mon = new("Packet Monitor", mon2sb_mbox, pkt_intf);
    pkt_sb  = new("Packet Scoreboard", drv2sb_mbox, mon2sb_mbox);
endfunction

function packet_env::configure();
endfunction

task packet_env::reset();
    @(pkt_intf.cb);
    pkt_intf.cb.txd <= 8'h0;
    pkt_intf.cb.tx_vld <= 1'b0;

    @(pkt_intf.cb);
    pkt_intf.rst_n = 1'b0;
    @(pkt_intf.cb);
    pkt_intf.rst_n = 1'b1;
    @(pkt_intf.cb);
endtask

task packet_env::start();
    pkt_gen.start();
    pkt_drv.start();
    pkt_mon.start();
    pkt_sb.start();
endtask

`endif

