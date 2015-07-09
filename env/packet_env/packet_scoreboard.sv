`ifndef __PACKET_SCOREBOARD_SV__
`define __PACKET_SCOREBOARD_SV__

`include "packet_transaction.sv"
`include "packet_define.sv"

class packet_scoreboard;

string name;
packet_tran_mbox drv2sb_mbox;
packet_tran_mbox mon2sb_mbox;
packet_transaction ref_pkt_tran[$];

integer error_no = 0;
integer send_no = 0;
integer receive_no = 0;

logic [9:0] min_pkt_size;
logic [9:0] max_pkt_size;

extern function new(string name = "CPU Scoreboard", packet_tran_mbox drv2sb_mbox, packet_tran_mbox mon2sb_mbox);
extern task start();
extern virtual task get_pkt_from_mon_and_check();
extern function display(string prefix = "Packet Scoreboard Result");

endclass

function packet_scoreboard::new(string name, packet_tran_mbox drv2sb_mbox, packet_tran_mbox mon2sb_mbox);
    this.name = name;
    this.drv2sb_mbox = drv2sb_mbox;
    this.mon2sb_mbox = mon2sb_mbox;
endfunction

task packet_scoreboard::start();
    fork
        get_pkt_from_mon_and_check();
    join_none
endtask

task packet_scoreboard::get_pkt_from_mon_and_check();
    string message;
    packet_transaction pkt_tran_mon;
    packet_transaction pkt_tran_drv;
    forever begin
        message = "Scoreboare Comparison:\n";

        mon2sb_mbox.get(pkt_tran_mon);
        receive_no++;

        do begin
            drv2sb_mbox.get(pkt_tran_drv);
            send_no++;
        end while(pkt_tran_drv.payload.size() < min_pkt_size || pkt_tran_drv.payload.size() > max_pkt_size);

        if(!pkt_tran_drv.compare(pkt_tran_mon, message)) begin
            error_no++;
        end
        message = {message, $psprintf(" Send: %3d, Receive: %3d, Error: %3d\n", send_no, receive_no, error_no)};
        $display(message);
    end
endtask

function packet_scoreboard::display(string prefix);
    $display("Send: %d, Receive: %d, Error: %d", send_no + drv2sb_mbox.num(), receive_no, error_no);
endfunction

`endif

