################################################
# MACHINE       TEMPLATE
# LOCATION      RRZE Erlangen
# COMPILER      Intel Compiler 11
# MODULES       intel64/11.1.064
#               intelmpi/3.2.2.006-intel
#               mkl/10.1
#               fftw2
#
################################################

################################################
# CXX environment
################################################
CXX=icpc
MPICXX=mpiicpc
CXXFLAGS= -O3 -xT  -vec-report0 -fno-pic 

################################################
# C environment
################################################
CC=icc
MPICC=mpiicc
CFLAGS= -O3 -xT -fno-pic  -vec-report0 

################################################
# Fortran environment
################################################
FC=ifort
MPIFC=mpiifort
FFLAGS= -O3  -xT -fno-pic  -vec-report0 -module ./$(SYSTEM)
FORCEPP=-cpp
FORCE_F77=

################################################
# Preprocessor Flags
################################################
CPPFLAGS := -I. -I./$(SYSTEM)


################################################
# Linker Flags
################################################
LDFLAGS :=

################################################
# Libraries
################################################

# BLAS/LAPACK
RZ_LIB_BLAS = $(MKL_LIB)
RZ_LIB_BLASLAPACK = $(MKL_LIB)
RZ_INCLUDE_BLASLAPACK = $(MKL_INC) -DUSEMKL

# FFTW2
RZ_LIB_FFTW2 = $(FFTW_LIB)
RZ_INCLUDE_FFTW2 =  $(FFTW_INC)

# FFTW3
RZ_LIB_FFTW3 = $(FFTW_LIB)
RZ_INCLUDE_FFTW3 =  $(FFTW_INC)

# MPI
RZ_LIB_MPI = -L$(MPILIB) -lmpi
RZ_INCLUDE_MPI = -I$(MPIINC)

################################################
# Specific Flags
################################################
RZ_OMP_C = -openmp
RZ_OMP_F = -openmp
RZ_NOALIAS =  -fno-fnalias
CC_VERSION = $(CC) --version
FC_VERSION = $(FC) --version
CXX_VERSION = $(CXX) --version
RZ_FDEFINE = -D
RZ_DEFINE = -D

################################################
# Benchmark specific Flags
################################################

STREAM_CPPFLAGS=
STREAM_FFLAGS=
STREAM_LDFLAGS=

LAMMPS_CPPFLAGS=  
LAMMPS_CXXFLAGS= -unroll0 $(RZ_NOALIAS)
LAMMPS_LDFLAGS=  


