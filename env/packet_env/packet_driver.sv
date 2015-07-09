`ifndef __PACKET_DRIVER_SV__
`define __PACKET_DRIVER_SV__

`include "packet_transaction.sv"
`include "packet_define.sv"
`include "packet_interface.svi"

class packet_driver;

string name;
packet_tran_mbox gen2drv_mbox;
packet_tran_mbox drv2sb_mbox;
virtual packet_interface.master pkt_intf;

extern function new(string name = "CPU Driver", packet_tran_mbox gen2drv_mbox, packet_tran_mbox drv2sb_mbox, virtual packet_interface.master pkt_intf);
extern task start();

endclass

function packet_driver::new(string name, packet_tran_mbox gen2drv_mbox, packet_tran_mbox drv2sb_mbox, virtual packet_interface.master pkt_intf);
    this.name = name;
    this.gen2drv_mbox = gen2drv_mbox;
    this.drv2sb_mbox = drv2sb_mbox;
    this.pkt_intf = pkt_intf;
endfunction

task packet_driver::start();
    integer delay = 0;
    fork
        forever begin
            packet_transaction pkt_tran;
            gen2drv_mbox.get(pkt_tran);
            //pkt_tran.display();
            drv2sb_mbox.put(pkt_tran.copy());

            @(pkt_intf.cb);
            pkt_intf.cb.tx_vld <= 1'b1;
            pkt_intf.cb.txd    <= pkt_tran.header[15:8];
            @(pkt_intf.cb);
            pkt_intf.cb.txd    <= pkt_tran.header[7:0];

            foreach(pkt_tran.payload[i]) begin
                @(pkt_intf.cb);
                pkt_intf.cb.txd    <= pkt_tran.payload[i];
            end

            if(pkt_tran.frame_interval > pkt_tran.payload.size())
                delay = pkt_tran.frame_interval;
            else
                delay = pkt_tran.payload.size();
            repeat(delay) begin
                @(pkt_intf.cb);
                pkt_intf.cb.tx_vld <= 1'b0;
            end

        end
    join_none
endtask

`endif

