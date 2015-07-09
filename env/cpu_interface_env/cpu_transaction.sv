`ifndef __CPU_TRANSACTION_SV__
`define __CPU_TRANSACTION_SV__

class cpu_transaction;

string name;
rand logic [7:0] addr;
rand logic rw;
rand logic [31:0] dout;
logic [31:0] din = 32'h0;

extern function new(string name = "CPU Transaction");
extern function cpu_transaction copy();
extern function void display(string prefix = "Note");

endclass

function cpu_transaction::new(string name);
    this.name = name;
endfunction

function cpu_transaction cpu_transaction::copy();
    cpu_transaction cpu_tran_cpy = new();

    cpu_tran_cpy.addr = addr;
    cpu_tran_cpy.rw   = rw;
    cpu_tran_cpy.dout = dout;
    cpu_tran_cpy.din  = din;

    return cpu_tran_cpy;
endfunction

function void cpu_transaction::display(string prefix);
  $display("[%s]%t %s addr = %0h, dout = %0h, rw = %d, din = %0h", prefix, $realtime, name, addr, dout, rw, din);
endfunction

`endif

