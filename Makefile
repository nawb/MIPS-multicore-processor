# Eric Villasenor
# evillase@gmail.com
#
# Makefile for system verilog or vhdl designs.
#
# you DON'T TOUCH THIS FILE!!!
# I jest, you can mess with SIMTIME.
# AND THAT IS IT!
#

# list of grid hosts
GRIDHOSTS = ecegrid

###############################because GRID is funny###########################
ifneq (,$(findstring $(GRIDHOSTS), $(HOST)))
%:
	@$(if \
		$(findstring $@, $(word 1, $(MAKECMDGOALS))), \
		grid $(MAKE) $(MAKECMDGOALS) -$(MAKEFLAGS), \
		echo "do nothing" > /dev/null)
else
###############################and i'm not laughing############################

################################################################################
# variables                                                                    #
################################################################################

# course libs and such
COURSELIBS	= ${LIBS437}

# directories
SRCDIR			= source
INCDIR			= include
TBDIR				= testbench
MAPDIR			= mapped
FPGADIR			= fpga
SCRDIR			= scripts
LIBDIR			= work
DEPDIR			= .deps

# commands and flags
SYN					= synthesize
MAKEDEP			= makehdldep
VSIM				= vsim
VLOG				= vlog
VCOM				= vcom
VERFLAGS		= +acc -sv12compat -mfcu -lint +incdir+$(INCDIR)
VHDFLAGS		= -93 +acc -lint
SIMTIME			= -a

# modelsim viewing options
ifneq (0,$(words $(filter %.wav,$(MAKECMDGOALS))))
# view waveform in graphical mode and load do file if there is one
DOFILES			= $(notdir $(basename $(wildcard $(SCRDIR)/*.do)))
DOFILE			= $(filter $(MAKECMDGOALS:%.wav=%) $(MAKECMDGOALS:%_tb.wav=%), $(DOFILES))
ifeq (1, $(words  $(DOFILE)))
WAVDO				= do $(SCRDIR)/$(DOFILE).do
else
WAVDO				= add wave *
endif
SIMDO				= "view objects; $(WAVDO); run $(SIMTIME);" -onfinish stop
else
# view text output in cmdline mode
SIMTERM			= -c
SIMDO		= "run $(SIMTIME); exit;"
endif

# mapped files
SYNTH				= $(filter $(MAKECMDGOALS:%.wav=%) \
							$(MAKECMDGOALS:%.sim=%) $(MAKECMDGOALS:%_tb.sim=%) \
							$(MAKECMDGOALS:%_tb.wav=%) $(MAKECMDGOALS:%_tb=%), \
							$(notdir $(basename $(wildcard $(MAPDIR)/*.sv $(MAPDIR)/*.v $(MAPDIR)/*.vhd))))

ifneq (,$(filter $(SYNTH), \
	$(MAKECMDGOALS:%_tb=%) $(MAKECMDGOAlS:%_tb.sim=%) \
	$(MAKECMDGOALS:%_tb.wav=%) $(MAKECMDGOALS:%.wav=%) $(MAKECMDGOALS:%.sim=%)))
SYNDEF		=	+define+MAPPED
#SIMSYN			= -sdftyp /=mapped/$(SYNTH)_v.sdo
endif

# v, sv or vhdl stems
VLSTEM			= $(notdir $(basename $(wildcard $(SRCDIR)/*.v $(TBDIR)/*.v)))
SVSTEM			= $(notdir $(basename $(wildcard $(SRCDIR)/*.sv $(TBDIR)/*.sv)))
VHSTEM			= $(notdir $(basename $(wildcard $(SRCDIR)/*.vhd $(TBDIR)/*.vhd)))
SRCSTEM			= $(VLSTEM) $(SVSTEM) $(VHSTEM)
SRCS				= $(addsuffix .v,$(VLSTEM)) $(addsuffix .sv,$(SVSTEM)) $(addsuffix .vhd,$(VHSTEM))

# dep files
DEPS				= $(addsuffix .d, $(VLSTEM) $(SVSTEM) $(VHSTEM))

# no target files are made
NODEPS			= help clean clean_asm clean_sim clean_map clean_deps clean_fpga

################################################################################
# config                                                                       #
################################################################################

# rules with no output file
.PHONY:			$(NODEPS)

# clear and set suffixes
.SUFFIXES:
.SUFFIXES: .vh .sv .vhd .d .v

# set search paths
vpath %.vh	$(INCDIR)/
vpath %.v		$(SRCDIR)/ $(TBDIR)/
vpath %.sv	$(MAPDIR)/ $(SRCDIR)/ $(TBDIR)/
vpath %.vhd	$(SRCDIR)/ $(TBDIR)/
vpath %.d		$(DEPDIR)/
vpath %			$(DEPDIR)/

# set default rule
default: help

# v,sv library search paths
ifneq (0,$(words $(VLSTEM) $(SVSTEM)))
SIMLIBS=$(addprefix -L ,$(filter %_ver,$(shell ls $(COURSELIBS))))
endif

# include dependencies
ifeq (0,$(words $(findstring $(MAKECMDGOALS), $(NODEPS))))
	# dash keeps this quiet
-include $(addprefix $(DEPDIR)/,$(DEPS))
endif

################################################################################
# auto make rules                                                              #
################################################################################

# dependency rules
$(DEPDIR):
	@test -d $(DEPDIR) || mkdir $(DEPDIR)
$(LIBDIR):
	@test -d $(LIBDIR) || vlib $(LIBDIR)
%.d: | $(DEPDIR)
	@$(SHELL) -ec '$(MAKEDEP) ${*F} $(SRCDIR) $(TBDIR) $(INCDIR) \
		| sed \
		-e "s/$$/ $(filter ${*F}.v ${*F}.sv ${*F}.vhd,$(SRCS))/" \
		-e "s/\.[a-z]\+/&o/g" \
		-e "s/\.vho/\.vh/g" \
		-e "s/^/${*F}: /" \
		> $@'

# verilog rules
%.vo: %.v | $(LIBDIR)
	$(VLOG) $(VERFLAGS) $(SYNDEF) $<
	@touch $(DEPDIR)/$@

# system verilog rules
%.svo: %.sv | $(LIBDIR)
	$(VLOG) $(VERFLAGS) $(SYNDEF) $<
	@touch $(DEPDIR)/$@

# vhdl rules
%.vhdo: %.vhd | $(LIBDIR)
	$(VCOM) $(VHDFLAGS) $<
	@touch $(DEPDIR)/$@

# simulation rules
%_tb.sim %_tb.wav %.sim %.wav: %_tb
	@$(VSIM) $(SIMTERM) -do $(SIMDO) $(SIMLIBS) $(SIMSYN) -wlf $(addsuffix _tb,$*).wlf $(LIBDIR).$(addsuffix _tb,$*)

# synthesis rules for mapped simulation
%_tb.synf %.synf %_tb.synt %.synt %_tb.syn %.syn:
	@$(SYN) $(if $(filter %.synt, $@),-t) $*
	-@rm -f $(DEPDIR)/${*F}_tb.svo

################################################################################
# info clean up rules                                                          #
################################################################################

# cleaning rules
clean: clean_sim clean_asm clean_map clean_deps clean_fpga

clean_sim: clean_deps
	@rm -rf $(LIBDIR) *.log *.wlf transcript

clean_asm:
	@rm -rf *.hex *.ver *.diff *.log

clean_map:
	@rm -rf $(MAPDIR)/* ._* *.summary *.log

clean_fpga:
	@rm -rf $(FPGADIR)/* ._*

clean_deps:
	@rm -rf $(DEPDIR) *.d

help:
	@echo ""
	@echo "Hello $(USER)@$(HOST), you forgot some targets."
	@echo "	If you need instructions to use this Makefile:"
	@echo "		'make <module_name>' to build module"
	@echo "		'make <module_name>_tb' to build module + testbench"
	@echo "		'make <module_name>.sim' to sim tb on cmd line"
	@echo "		'make <module_name>.wav' to sim tb with gui"
	@echo "		'make <module_name>.syn' to synthesize functional net list"
	@echo "		'make <module_name>.synt' to synthesize timing net list"
	@echo "	Clean Rules:"
	@echo "		'make clean' to clean everything"
	@echo "		'make clean_sim' to clean simulation logs and work lib"
	@echo "		'make clean_asm' to clean hex and testasm output"
	@echo "		'make clean_map' to clean mapped dir"
	@echo "		'make clean_fpga' to clean fpga dir"
	@echo "	Obviously a testbench file must exist for some options."
	@echo ""

################################################################################
endif # end GRID nonsense                                                      #
################################################################################
