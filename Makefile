.DEFAULT_GOAL := all
all: analyse compile simulate wave

GHDL ?= ghdl
GTKWAVE ?= gtkwave

analyse:
	$(GHDL) -i --ieee=synopsys --warn-no-vital-generic --workdir=simu --work=work src/*.vhd tests/edge_detection_accelerator_test.vhd

compile:
	$(GHDL) -m --ieee=synopsys --warn-no-vital-generic --workdir=simu --work=work edge_detection_accelerator_test
#
simulate:
	./edge_detection_accelerator_test --vcdgz=simulation_results.vcdgz

wave: simulate
	gunzip --stdout simulation_results.vcdgz | $(GTKWAVE) --vcd --script signals.tcl
