To use hpc-bench you must first install a benchmark package.

Benchmark packages can be downloaded at:

http://code.google.com/p/hpc-bench/downloads/list

To install a benchmark package:

1. cd to hpc-bench root directory
2. Execute:
   ./installBench <PACKAGE>.tar.bz2  <PATH TO BENCHMARK SOURCE>

   The path to the benchmark sources are optional for those benchmark codes
   which do not allow a redistribution of source code. installBench will import
   the source code from the original tree into the hpc-bench tree. Unpack the
   original source tree and provide the full path to installBench. Please alsways provide
   full path names here.

3. Once a benchmark is installed it also included in the build. To disable a benchmark
   from the build configuration comment out the appropriate line in benchset.mk.

4. You can uninstall a benchmark from your hpc-bench tree with
   ./uninstallBench <BENCHMARK>


