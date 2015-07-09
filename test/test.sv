`ifndef __TEST_SV__
`define __TEST_SV__

`include "env.sv"

program test(cpu_interface.master cpu_intf, packet_interface.master pkt_intf);

class packet_transaction_ext extends packet_transaction;

//constraint con_pkt_len_test {
//    payload.size() == 100;
//    pkt_head_type == GOOD;
//}

endclass

cpu_transaction cpu_tran;
cpu_transaction cpu_tran_cpy;
packet_transaction_ext pkt_tran;
env e;

initial begin
    cpu_tran = new();
    pkt_tran = new();
    e = new(cpu_intf, pkt_intf);
    e.configure();

    e.pkt_e.pkt_gen.pkt_tran = pkt_tran;

    e.reset();
    e.start();

    cpu_tran.randomize() with {addr == 'h4; rw == 1'b0; dout == 'd65;};
    cpu_tran_cpy = cpu_tran.copy();
    e.cpu_e.drv_mbox.put(cpu_tran_cpy);

    cpu_tran.randomize() with {addr == 'h8; rw == 1'b0; dout == 'd500;};
    cpu_tran_cpy = cpu_tran.copy();
    e.cpu_e.drv_mbox.put(cpu_tran_cpy);

    cpu_tran.randomize() with {addr == 'h0; rw == 1'b0; dout == 'h1;};
    cpu_tran_cpy = cpu_tran.copy();
    e.cpu_e.drv_mbox.put(cpu_tran_cpy);

    repeat(100) begin
        @(cpu_intf.cb);
    end

    e.pkt_e.pkt_sb.min_pkt_size = 65;
    e.pkt_e.pkt_sb.max_pkt_size = 500;
    e.pkt_e.pkt_gen.run_for_n_trans = 100;
    e.pkt_e.pkt_gen.start();

    @e.pkt_e.pkt_gen.done;
    repeat(10000) begin
        @(pkt_intf.cb);
        if(e.pkt_e.pkt_sb.send_no == e.pkt_e.pkt_gen.run_for_n_trans) begin
            break;
        end
    end
    e.pkt_e.pkt_sb.display();
    $finish();
end

endprogram
`endif

