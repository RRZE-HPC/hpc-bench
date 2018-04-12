#########################################################################################
#   HPCBench
#
#   File: benchset.mk
#   Description:  Target configuration for build system
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

# SET can be one of SERIAL, OPENMP, MPI or ALL
SET = ALL

# To enable or disable single benchmarks comment lines in and out
TARGETS_SEQ  =
#<EXPORT SEQ>

TARGETS_OMP  =
#<EXPORT OMP>

TARGETS_MPI  =
#<EXPORT MPI>

#########################################################################################
# DO NOT EDIT BELOW
ifeq ($(SET),SERIAL)
    TARGETS = $(TARGETS_SEQ)
endif

ifeq ($(SET),OPENMP)
    TARGETS = $(TARGETS_OMP)
endif

ifeq ($(SET),MPI)
    TARGETS = $(TARGETS_MPI)
endif

ifeq ($(SET),ALL)
    TARGETS = $(TARGETS_SEQ) $(TARGETS_OMP) $(TARGETS_MPI)
endif

#<EXPORT>

