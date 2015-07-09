`ifndef __CPU_DRIVER_SV__
`define __CPU_DRIVER_SV__

`include "cpu_transaction.sv"
`include "cpu_define.sv"
`include "cpu_interface.svi"

class cpu_driver;

string name;
cpu_tran_mbox in_box;
cpu_tran_mbox out_box;
virtual cpu_interface.master cpu_intf;

extern function new(string name = "CPU Driver", cpu_tran_mbox in_box, cpu_tran_mbox out_box, virtual cpu_interface.master cpu_intf);
extern task start();

endclass

function cpu_driver::new(string name, cpu_tran_mbox in_box, cpu_tran_mbox out_box, virtual cpu_interface.master cpu_intf);
    this.name = name;
    this.in_box = in_box;
    this.out_box = out_box;
    this.cpu_intf = cpu_intf;
endfunction

task cpu_driver::start();
    fork
        forever begin
            cpu_transaction cpu_tran;
            in_box.get(cpu_tran);
            cpu_tran.display();

            @(cpu_intf.cb);
            cpu_intf.cb.addr <= cpu_tran.addr;
            cpu_intf.cb.dout <= cpu_tran.dout;
            cpu_intf.cb.rw   <= cpu_tran.rw;
            if(cpu_tran.rw == 1'b1) begin
                @(cpu_intf.cb);
                cpu_tran.din  = cpu_intf.cb.din;
            end

            out_box.put(cpu_tran);
        end
    join_none
endtask

`endif

