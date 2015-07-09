`ifndef __CPU_GENERATOR_SV__
`define __CPU_GENERATOR_SV__

`include "cpu_transaction.sv"
`include "cpu_define.sv"

class cpu_generator;

string name;
cpu_tran_mbox out_box;
int run_for_n_trans = 0;
cpu_transaction cpu_tran;
event done;

extern function new(string name = "CPU Generator", cpu_tran_mbox out_box);
extern task start();

endclass

function cpu_generator::new(string name, cpu_tran_mbox out_box);
    this.name = name;
    this.out_box = out_box;
endfunction

task cpu_generator::start();
    fork
        begin
            for(int i=0; i<run_for_n_trans; i++) begin
                cpu_transaction cpu_tran_cpy = new cpu_tran;
                if(!cpu_tran_cpy.randomize()) begin
                    $display("Error to randomize cpu_tran_cpy");
                end
                out_box.put(cpu_tran_cpy);
            end
            ->done;
        end
    join_none
endtask

`endif

