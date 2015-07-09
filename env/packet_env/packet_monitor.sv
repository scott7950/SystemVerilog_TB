`ifndef __PACKET_MONITOR_SV__
`define __PACKET_MONITOR_SV__

`include "packet_transaction.sv"
`include "packet_define.sv"
`include "packet_interface.svi"

class packet_monitor;

string name;
packet_tran_mbox out_box;
virtual packet_interface.master pkt_intf;

extern function new(string name = "CPU monitor", packet_tran_mbox out_box, virtual packet_interface.master pkt_intf);
extern task start();

endclass

function packet_monitor::new(string name, packet_tran_mbox out_box, virtual packet_interface.master pkt_intf);
    this.name = name;
    this.out_box = out_box;
    this.pkt_intf = pkt_intf;
endfunction

task packet_monitor::start();
    fork
        forever begin
            logic [7:0] rxd[$];
            packet_transaction pkt_tran = new();

            @(pkt_intf.cb);
            while(pkt_intf.cb.rx_vld == 1'b0) begin
                @(pkt_intf.cb);
            end

            while(pkt_intf.cb.rx_vld == 1'b1) begin
                rxd.push_back(pkt_intf.cb.rxd);
                @(pkt_intf.cb);
            end

            pkt_tran.byte2pkt(rxd);
            //pkt_tran.display("Monitor");

            out_box.put(pkt_tran);
        end
    join_none
endtask

`endif

