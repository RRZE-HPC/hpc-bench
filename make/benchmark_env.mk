#########################################################################################
#   HPCBench
#
#   File: benchmark_env.mk
#   Description:  Central make include with targets for build environment dump and header
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

.PHONY: print_env entry


ifneq ($(MAKECMDGOALS)),clean)
print_env:
	@echo "*****************************" >>  $(HPC_BENCH_RESULTDIR)/build_env.txt
	@echo "ENV: $(BENCHMARK)-$(SYSTEM)" >>  $(HPC_BENCH_RESULTDIR)/build_env.txt
	@echo "CC = `$(CC_VERSION)`" >>  $(HPC_BENCH_RESULTDIR)/build_env.txt
	@echo "CFLAGS = $(CFLAGS)" >>  $(HPC_BENCH_RESULTDIR)/build_env.txt
	@echo "CXX = `$(CXX_VERSION)`" >>  $(HPC_BENCH_RESULTDIR)/build_env.txt
	@echo "CXXFLAGS = $(CXXFLAGS)" >>  $(HPC_BENCH_RESULTDIR)/build_env.txt
	@echo "FC = `$(FC_VERSION)`" >>  $(HPC_BENCH_RESULTDIR)/build_env.txt
	@echo "FFLAGS = $(FFLAGS)" >>  $(HPC_BENCH_RESULTDIR)/build_env.txt
	@echo "CPPFLAGS = $(CPPFLAGS)" >>  $(HPC_BENCH_RESULTDIR)/build_env.txt
	@echo "LD= $(LD)" >>  $(HPC_BENCH_RESULTDIR)/build_env.txt
	@echo "LDFLAGS = $(LDFLAGS)" >>  $(HPC_BENCH_RESULTDIR)/build_env.txt
	@echo "*****************************" >>  $(HPC_BENCH_RESULTDIR)/build_env.txt

entry:
	@echo ""
	@echo "*****************************"
	@echo " BENCHMARK $(BENCHMARK)"
	@echo "*****************************"
	@echo "BUILD OBJECTS $(BENCHMARK)"


endif



