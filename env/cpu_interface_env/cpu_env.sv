`ifndef __CPU_ENV_SV__
`define __CPU_ENV_SV__

`include "cpu_interface.svi"
`include "cpu_transaction.sv"
`include "cpu_generator.sv"
`include "cpu_define.sv"
`include "cpu_driver.sv"
`include "cpu_scoreboard.sv"

class cpu_env;

cpu_tran_mbox  drv_mbox = new(1);
cpu_tran_mbox  mon_mbox = new();
cpu_generator  cpu_gen;
cpu_driver     cpu_drv;
cpu_scoreboard cpu_sb;

virtual cpu_interface.master cpu_intf;

extern function new(virtual cpu_interface.master cpu_intf);
extern function configure();
extern task reset();
extern task start();

endclass

function cpu_env::new(virtual cpu_interface.master cpu_intf);
    this.cpu_intf = cpu_intf;
    cpu_gen = new("CPU Generator", drv_mbox);
    cpu_drv = new("CPU Driver", drv_mbox, mon_mbox, cpu_intf);
    cpu_sb  = new("CPU Scoreboard", mon_mbox);
endfunction

function cpu_env::configure();
endfunction

task cpu_env::reset();
    cpu_intf.cb.addr <= 8'h0;
    cpu_intf.cb.rw   <= 1'b1;
    cpu_intf.cb.dout <= 31'h0;
    @(cpu_intf.cb);
    cpu_intf.rst_n = 1'b0;
    @(cpu_intf.cb);
    cpu_intf.rst_n = 1'b1;
    @(cpu_intf.cb);
endtask

task cpu_env::start();
    cpu_gen.start();
    cpu_drv.start();
    cpu_sb.start();
endtask

`endif

