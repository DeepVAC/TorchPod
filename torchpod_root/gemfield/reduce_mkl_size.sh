#!/bin/bash
set -e
rm -rf /opt/intel/compilers_and_libraries_2020.4.304/linux/bin
rm -rf /opt/intel/conda_channel
rm -rf /opt/intel/compilers_and_libraries_2020.4.304/linux/mkl/benchmarks
rm -rf /opt/intel/compilers_and_libraries_2020.4.304/linux/mkl/examples
rm -rf /opt/intel/compilers_and_libraries_2020.4.304/linux/mkl/lib/intel64_lin/*.so
rm -rf /opt/intel/compilers_and_libraries_2020.4.304/linux/mkl/lib/intel64_lin/libmkl_blas*
rm -rf /opt/intel/compilers_and_libraries_2020.4.304/linux/mkl/lib/intel64_lin/libmkl_blacs*
rm -rf /opt/intel/compilers_and_libraries_2020.4.304/linux/mkl/lib/intel64_lin/libmkl_gf*
rm -rf /opt/intel/compilers_and_libraries_2020.4.304/linux/mkl/lib/intel64_lin/libmkl_intel_thread.a
rm -rf /opt/intel/compilers_and_libraries_2020.4.304/linux/mkl/lib/intel64_lin/libmkl_pgi_thread.a
rm -rf /opt/intel/compilers_and_libraries_2020.4.304/linux/mkl/lib/intel64_lin/libmkl_tbb_thread.a
rm -rf /opt/intel/compilers_and_libraries_2020.4.304/linux/mkl/lib/intel64_lin/libmkl_intel_ilp64.a
rm -rf /opt/intel/compilers_and_libraries_2020.4.304/linux/mkl/lib/intel64_lin/libmkl_lapack95*
rm -rf /opt/intel/compilers_and_libraries_2020.4.304/linux/mkl/lib/intel64_lin/libmkl_cdft_core.a
rm -rf /opt/intel/compilers_and_libraries_2020.4.304/linux/mkl/lib/intel64_lin/libmkl_scalapack*