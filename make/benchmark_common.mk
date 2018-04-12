#########################################################################################
#   HPCBench
#
#   File: benchmark_common.mk
#   Description:  Central make include with common build setup
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

$(BENCHMARK)_BASEDIR=$(BENCH_BASEDIR)/$($(BENCHMARK)_DIR)
BENCH_BASEDIR=$(HPC_BENCH_BASEDIR)/bench

# Include machine specific settings
include $(HPC_BENCH_BASEDIR)/system/include-$(SYSTEM).mk

# Include benchmark specific settings
include $($(BENCHMARK)_BASEDIR)/config.mk

ifeq ($(PARALLEL),MPI)
    CXX = $(MPICXX)
    CC  = $(MPICC)
    FC  = $(MPIFC)
endif

ifeq ($(PARALLEL),OMP)
    CXXFLAGS := $(CXXFLAGS) $(RZ_OMP_C)
    CFLAGS   := $(CFLAGS) $(RZ_OMP_C)
    FFLAGS   := $(FFLAGS) $(RZ_OMP_F)
    TARGETDIR = $(SYSTEM)/OMP
else
    TARGETDIR = $(SYSTEM)
endif


ifeq ($(LINKER),F90)
    LD:=$(FC)
    RZ_FLAGS:=$(FFLAGS)
endif

ifeq ($(LINKER),CXX)
    LD:=$(CXX)
    RZ_FLAGS:=$(CXXFLAGS)
endif

ifeq ($(LINKER),C)
    LD:=$(CC)
    RZ_FLAGS:=$(CFLAGS)
endif


# Where to search for prerequisites
VPATH :=  src $(VPATH)
# Generate list of objects to build
OBJECTS:=$(OBJECTS) $(patsubst src/%.c, %.o, $(wildcard src/*.c))
OBJECTS:=$(OBJECTS) $(patsubst src/%.cc, %.o, $(wildcard src/*.cc))
OBJECTS:=$(OBJECTS) $(patsubst src/%.cpp, %.o, $(wildcard src/*.cpp))
OBJECTS:=$(OBJECTS) $(patsubst src/%.f90, %.o, $(wildcard src/*.f90))
OBJECTS:=$(OBJECTS) $(patsubst src/%.F90, %.o, $(wildcard src/*.F90))
OBJECTS:=$(OBJECTS) $(patsubst src/%.f, %.o, $(wildcard src/*.f))
OBJECTS:=$(OBJECTS) $(patsubst src/%.F, %.o, $(wildcard src/*.F))

OBJECTS := $(addprefix $(TARGETDIR)/,$(OBJECTS))

# Definition of pattern rules
$(TARGETDIR)/%.o:  %.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $(addprefix $(RZ_DEFINE),$(DEFINES)) $< -o $@

$(TARGETDIR)/%.o:  %.cc
	$(CXX) -c $(CXXFLAGS) $(CPPFLAGS) $(addprefix $(RZ_DEFINE),$(DEFINES)) $< -o $@

$(TARGETDIR)/%.o:  %.cpp
	$(CXX) -c $(CXXFLAGS) $(CPPFLAGS) $(addprefix $(RZ_DEFINE),$(DEFINES)) $< -o $@

$(TARGETDIR)/%.o:  %.f90
	$(FC) -c $(FFLAGS) $(CPPFLAGS) $(addprefix $(RZ_FDEFINE),$(DEFINES)) $< -o $@

$(TARGETDIR)/%.o:  %.F90
	$(FC) -c $(FFLAGS) $(CPPFLAGS) $(addprefix $(RZ_FDEFINE),$(DEFINES)) $< -o $@

$(TARGETDIR)/%.o:  %.F
	$(FC) -c $(FFLAGS) $(FORCE_F77) $(CPPFLAGS) $(addprefix $(RZ_FDEFINE),$(DEFINES)) $< -o $@

$(TARGETDIR)/%.o:  %.f
	$(FC) -c $(FFLAGS) $(FORCE_F77) $(CPPFLAGS) $(addprefix $(RZ_FDEFINE),$(DEFINES)) $< -o $@

$(SYSTEM)/%.mod:  %.f90
	$(FC) -c $(FFLAGS) $(CPPFLAGS) $(addprefix $(RZ_FDEFINE),$(DEFINES)) $< -o $(patsubst $(SYSTEM)/%.mod,$(SYSTEM)/%.o,$@)

$(SYSTEM)/%.mod:  %.F90
	$(FC) -c $(FFLAGS) $(CPPFLAGS) $(addprefix $(RZ_FDEFINE),$(DEFINES)) $< -o $(patsubst $(SYSTEM)/%.mod,$(SYSTEM)/%.o,$@)

$(SYSTEM)/%.mod:  %.f
	$(FC) -c $(FFLAGS) $(FORCE_F77) $(CPPFLAGS) $(addprefix $(RZ_FDEFINE),$(DEFINES)) $< -o $(patsubst $(SYSTEM)/%.mod,$(SYSTEM)/%.o,$@)

$(SYSTEM)/%.mod:  %.F
	$(FC) -c $(FFLAGS) $(FORCE_F77) $(CPPFLAGS) $(addprefix $(RZ_FDEFINE),$(DEFINES)) $< -o $(patsubst $(SYSTEM)/%.mod,$(SYSTEM)/%.o,$@)
