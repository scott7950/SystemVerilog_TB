
ifeq ($(GUI), 1)
    GUI_ARG = -gui
endif

PROJECT_DIR = /mnt/svtb
RTL_DIR = $(PROJECT_DIR)/rtl
RTL = $(RTL_DIR)/dut.v

TB_DIR = $(PROJECT_DIR)/env
INCDIR = +incdir+$(TB_DIR)

CPU_INTF_TB_DIR = $(TB_DIR)/cpu_interface_env
INCDIR += +incdir+$(CPU_INTF_TB_DIR)

PKT_TB_DIR = $(TB_DIR)/packet_env
INCDIR += +incdir+$(PKT_TB_DIR)

SVTB = $(TB_DIR)/env.sv $(TB_DIR)/top.sv

TEST_DIR = $(PROJECT_DIR)/test
TEST_FILE = $(TEST_DIR)/test.sv
INCDIR += +incdir+$(TEST_DIR)

COMPILE_LOG_ARG = -l vcs.log

WAVE_ARG = +define+WAVE_ON=1

COMPILE_ARG = -sverilog -debug_all 
COMPILE_ARG += $(INCDIR) $(COMPILE_LOG_ARG) $(WAVE_ARG)

RUN_LOG_ARG = -l simv.log

RUN_ARG  = 
RUN_ARG += $(RUN_LOG_ARG) $(GUI_ARG)

SEED = 1

default: test 

test: compile run

run:
	./simv $(RUN_ARG) +ntb_random_seed=$(SEED)

compile:
	vcs $(COMPILE_ARG) $(RTL) $(SVTB) $(TEST_FILE)

clean:
	rm -rf simv simv.* *log

