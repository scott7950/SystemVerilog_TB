`ifndef __PACKET_GENERATOR_SV__
`define __PACKET_GENERATOR_SV__

`include "packet_transaction.sv"
`include "packet_define.sv"

class packet_generator;

string name;
packet_tran_mbox drv_mbox;
int run_for_n_trans = 0;
packet_transaction pkt_tran = new();
event done;

extern function new(string name = "CPU Generator", packet_tran_mbox drv_mbox);
extern task start();

endclass

function packet_generator::new(string name, packet_tran_mbox drv_mbox);
    this.name = name;
    this.drv_mbox = drv_mbox;
endfunction

task packet_generator::start();
    fork
        begin
            for(int i=0; i<run_for_n_trans; i++) begin
                packet_transaction pkt_tran_cpy = new pkt_tran;
                if(!pkt_tran_cpy.randomize()) begin
                    $display("Error to randomize pkt_tran_cpy");
                end
                drv_mbox.put(pkt_tran_cpy);
            end
            ->done;
        end
    join_none
endtask

`endif

