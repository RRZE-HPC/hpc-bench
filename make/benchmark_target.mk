#########################################################################################
#   HPCBench
#
#   File:  benchmark_target.mk
#   Description:  Central make include with common targets
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
#
#########################################################################################

$(BENCHMARK)-$(SYSTEM): entry $(ADD_TARGETS) $(TARGETDIR) $(MODULES) $(OBJECTS) print_env
	@echo "LINKING $(BENCHMARK)"
	$(LD) $(RZ_FLAGS) -o $(HPC_BENCH_RESULTDIR)/bin/$(BENCHMARK)-$(SYSTEM) $(OBJECTS) $(LDFLAGS)

$(TARGETDIR):
	@mkdir -p $(TARGETDIR)

.PHONY: clean $(TARGETDIR)

clean:
	@echo "CLEANING $(BENCHMARK): $(TARGETDIR)"
	@rm -rf $(TARGETDIR)


