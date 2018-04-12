#########################################################################################
#   HPCBench
#
#   File: Makefile
#   Description:  Toplevel Makefile
#
#   Version:  1.0
#
#   Author:  Jan Treibig (jt), jan.treibig@gmail.com
#   Company:  RRZE Erlangen
#   Copyright:  Copyright (c) 2011, Jan Treibig
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License, v2, as
#   published by the Free Software Foundation
#  
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#  
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
#########################################################################################


# Specify your system. For the build the file ./system/include_<SYSTEM>.mk 
# containing the build configuration must exist
export SYSTEM=TEMPLATE


#########################################################################################
# DO NOT EDIT BELOW
export HPC_BENCH_BASEDIR=$(shell pwd)
BENCH_BASEDIR=$(HPC_BENCH_BASEDIR)/bench
export HPC_BENCH_RESULTDIR=$(HPC_BENCH_BASEDIR)/bench_$(SYSTEM)

include benchset.mk


all: prepare $(HPC_BENCH_RESULTDIR)/bin/wll $(HPC_BENCH_RESULTDIR)/bin/endian $(TARGETS) end

prepare:
	@test -d $(HPC_BENCH_RESULTDIR) || mkdir $(HPC_BENCH_RESULTDIR)
	@test -d $(HPC_BENCH_RESULTDIR)/bin || mkdir $(HPC_BENCH_RESULTDIR)/bin
	@test -d $(HPC_BENCH_RESULTDIR)/results || mkdir $(HPC_BENCH_RESULTDIR)/results

$(HPC_BENCH_RESULTDIR)/bin/wll: util/wll.c
	$(CC) util/wll.c -o $(HPC_BENCH_RESULTDIR)/bin/wll

$(HPC_BENCH_RESULTDIR)/bin/endian: util/endian.c
	$(CC) util/endian.c -o $(HPC_BENCH_RESULTDIR)/bin/endian

$(TARGETS): prepare $(HPC_BENCH_RESULTDIR)/bin/wll $(HPC_BENCH_RESULTDIR)/bin/endian
	$(MAKE) -C $(BENCH_BASEDIR)/$($@_DIR)/ $@-$(SYSTEM) BENCHMARK=$@

end:
	@echo ""
	@echo "*****************************"
	@echo ' hpc-bench build complete! '
	@echo "*****************************"

.PHONY: clean distclean  avail

avail: 
	@echo "Available Benchmark targets:"
	@echo "$(TARGETS)"

CLEAN_TARGETS = $(foreach target,$(TARGETS),clean_$(target))

$(CLEAN_TARGETS):
	  $(MAKE) -C $(BENCH_BASEDIR)/$($(subst clean_,,$@)_DIR)/  clean BENCHMARK=$(subst clean_,,$@)


clean: $(CLEAN_TARGETS)


distclean: clean
	@echo "CLEANING BENCH RESULTS"
	rm -rf $(HPC_BENCH_RESULTDIR)

.NOTPARALLEL:

