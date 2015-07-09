`ifndef __CPU_SCOREBOARD_SV__
`define __CPU_SCOREBOARD_SV__

`include "cpu_transaction.sv"
`include "cpu_define.sv"

class cpu_scoreboard;

string name;
cpu_tran_mbox in_box;
cpu_transaction cpu_tran;

logic [31:0] cpu_reg [7:0];
integer error_no = 0;
integer total_no = 0;

extern function new(string name = "CPU Scoreboard", cpu_tran_mbox in_box);
extern task start();
extern task check();
extern function display(string prefix = "CPU Scoreboard Result");

endclass

function cpu_scoreboard::new(string name, cpu_tran_mbox in_box);
    this.name = name;
    this.in_box = in_box;

    for(int i=0; i<128; i++) begin
        cpu_reg[i] = 32'h0;
    end
endfunction

task cpu_scoreboard::start();
    fork
        forever begin
            in_box.get(cpu_tran);
            total_no++;
            check();
        end
    join_none
endtask

task cpu_scoreboard::check();
    string message;
    if(cpu_tran.rw == 1'b0) begin
        cpu_reg[cpu_tran.addr] = cpu_tran.din;
    end
    else if(cpu_tran.rw == 1'b1) begin
        if(cpu_reg[cpu_tran.addr] != cpu_tran.din) begin
            message = $psprintf("[Error] %t Comparision result is not correct\n", $realtime);
            message = { message, $psprintf("cpu_reg[%d] = %0h, cpu_tran.din = %0h\n", cpu_tran.addr, cpu_reg[cpu_tran.addr], cpu_tran.din) };
            $display(message);
            error_no++;
        end
        else begin
            $display("[Note] %t comparison correct", $realtime);
        end
    end
    else begin
        $display("[Error] cpu_tran.rw can only be 0 or 1");
        error_no++;
    end
endtask

function cpu_scoreboard::display(string prefix);
    $display("Total: %d, Error: %d", total_no, error_no);
endfunction

`endif

