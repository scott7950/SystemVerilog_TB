`ifndef __ENV_SV__
`define __ENV_SV__

`include "cpu_interface.svi"
`include "packet_interface.svi"
`include "cpu_env.sv"
`include "packet_env.sv"

class env;

cpu_env cpu_e;
packet_env pkt_e;

extern function new(virtual cpu_interface.master cpu_intf, virtual packet_interface.master pkt_intf);
extern function configure();
extern task reset();
extern task start();

endclass

function env::new(virtual cpu_interface.master cpu_intf, virtual packet_interface.master pkt_intf);
    cpu_e = new(cpu_intf);
    pkt_e = new(pkt_intf);
endfunction

function env::configure();
    cpu_e.configure();
    pkt_e.configure();
endfunction

task env::reset();
    cpu_e.reset();
    pkt_e.reset();
endtask

task env::start();
    cpu_e.start();
    pkt_e.start();
endtask

`endif

