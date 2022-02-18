ifndef JULIAHOME
$(error JULIAHOME not defined. Set value to the root of the Julia source tree.)
endif
include $(JULIAHOME)/Make.inc
include $(JULIAHOME)/deps/Versions.make

NODEJSBIN = node8

#Use python2 for Python 2.x
PYTHON = python3

OCTAVE = octave-cli

ifeq ($(OS), WINNT)
MATHEMATICABIN = MathKernel
else ifeq ($(OS), Darwin)
MATHEMATICABIN = MathKernel
else
MATHEMATICABIN = math
endif

#Which BLAS library am I using?
ifeq ($(USE_SYSTEM_BLAS), 0)
BLASMANIFEST=$(shell cat $(JULIAHOME)/usr/manifest/openblas)
BLASDIR=$(JULIAHOME)/deps/scratch/$(BLASMANIFEST)/
LIBBLAS=$(BLASDIR)$(LIBBLASNAME).a
endif

FFLAGS=-fexternal-blas
#gfortran cannot multiply matrices using 64-bit external BLAS.
ifeq ($(findstring gfortran, $(FC)), gfortran)
ifeq ($(USE_BLAS64), 1)
FFLAGS=
endif
FFLAGS+= -static-libgfortran
endif

#Which libm library am I using?
LIBMDIR = $(JULIAHOME)/usr/lib/
ifeq ($(USE_SYSTEM_LIBM), 0)
ifeq ($(USE_SYSTEM_OPENLIBM), 0)
LIBM = $(LIBMDIR)libopenlibm.a
endif
endif

DSFMTDIR = $(JULIAHOME)/deps/scratch/dsfmt-$(DSFMT_VER)
RMATHDIR = $(JULIAHOME)/deps/scratch/Rmath-julia-$(RMATH_JULIA_VER)

default: benchmarks.html

export OMP_NUM_THREADS=1
export GOTO_NUM_THREADS=1
export OPENBLAS_NUM_THREADS=1

perf.h: $(JULIAHOME)/deps/Versions.make
	echo '#include "$(BLASDIR)cblas.h"' > $@
	echo '#include "$(DSFMTDIR)/dSFMT.c"' >> $@

bin/perf%: perf.c perf.h
	$(CC) -std=c99 -O$* $< -o $@  -I$(DSFMTDIR) $(LIBBLAS) -L$(LIBMDIR) $(LIBM) $(CFLAGS) -lpthread

bin/fperf%: perf.f90
	mkdir -p mods/$@ #Modules for each binary go in separate directories
#	$(FC) $(FFLAGS) -Jmods/$@ -O$* $< -o $@ $(LIBBLAS) -L$(LIBMDIR) $(LIBM) -lpthread
	$(FC) $(FFLAGS) -Jmods/$@ -O$* $< -o $@ -lopenblas -L$(LIBMDIR) $(LIBM) -lpthread

benchmarks/c.csv: \
	benchmarks/c0.csv \
	benchmarks/c1.csv \
	benchmarks/c2.csv \
	benchmarks/c3.csv
	cat $^ > $@

benchmarks/fortran.csv: \
	benchmarks/fortran0.csv \
	benchmarks/fortran1.csv \
	benchmarks/fortran2.csv \
	benchmarks/fortran3.csv
	cat $^ > $@


benchmarks/c%.csv: bin/perf%
	for t in 1 2 3 4 5; do $<; done >$@

benchmarks/fortran%.csv: bin/fperf%
	for t in 1 2 3 4 5; do $<; done >$@

benchmarks/go.csv: export GOPATH=$(abspath gopath)
benchmarks/go.csv: perf.go
	#CGO_LDFLAGS="$(LIBBLAS) $(LIBM)" go get github.com/gonum/blas/cgo
	go get github.com/gonum/blas/blas64
	go get github.com/gonum/blas/cgo
	go get github.com/gonum/matrix/mat64
	go get github.com/gonum/stat
	for t in 1 2 3 4 5; do go run $<; done >$@

benchmarks/julia.csv: perf.jl
	for t in 1 2 3 4 5; do $(JULIAHOME)/usr/bin/julia $<; done >$@

benchmarks/python.csv: perf.py
	for t in 1 2 3 4 5; do $(PYTHON) $<; done >$@

benchmarks/matlab.csv: perf.m
	for t in 1 2 3 4 5; do matlab -nojvm -singleCompThread -r 'perf; perf; exit' | grep ^matlab | tail -8; done >$@

benchmarks/octave.csv: perf.m
	for t in 1 2 3 4 5; do $(OCTAVE) -q --eval perf 2>/dev/null; done >$@

benchmarks/r.csv: perf.R
	for t in 1 2 3 4 5; do cat $< | R --vanilla --slave 2>/dev/null; done >$@

benchmarks/javascript.csv: perf.js
	for t in 1 2 3 4 5; do $(NODEJSBIN) $<; done >$@

benchmarks/mathematica.csv: perf.nb
	for t in 1 2 3 4 5; do $(MATHEMATICABIN) -noprompt -run "<<$<; Exit[]"; done >$@

benchmarks/stata.csv: perf.do
	for t in 1 2 3 4 5; do stata -b do $^ $@; done

benchmarks/lua.csv: perf.lua
	for t in 1 2 3 4 5; do scilua $<; done >$@

benchmarks/java.csv: java/src/main/java/PerfBLAS.java
	cd java; sh setup.sh; for t in 1 2 3 4 5; do mvn -q exec:java; done >../$@

benchmarks/scala.csv: scala/src/main/scala/perf.scala scala/build.sbt
	cd scala; for t in 1 2 3 4 5; do sbt run; done >../$@

benchmarks/rust.csv: rust/src/main.rs rust/src/util.rs rust/Cargo.lock
	cd rust; for t in 1 2 3 4 5; do cargo run --release -q; done >../$@

LANGUAGES = c fortran go java javascript julia lua mathematica matlab octave python r rust
GH_ACTION_LANGUAGES = c fortran julia python rust

# These were formerly listed in LANGUAGES, but I can't get them to run
# 2017-09-27 johnfgibson
#	scala, stata

BENCHMARKS = $(foreach lang,$(LANGUAGES),benchmarks/$(lang).csv)
GH_ACTION_BENCHMARKS = $(foreach lang,$(GH_ACTION_LANGUAGES),benchmarks/$(lang).csv)

versions.csv: bin/versions.sh
	$^ >$@

gh_action_versions.csv: bin/versions.sh
	bin/versions.sh ",c,fortran,julia,python,rust," >$@

benchmarks.csv: bin/collect.jl $(BENCHMARKS)
	@$(call PRINT_JULIA, $^ >$@)

gh_action_benchmarks.csv: bin/collect.jl $(GH_ACTION_BENCHMARKS)
	@$(call PRINT_JULIA, $^ >$@)

benchmarks.html: bin/table.jl versions.csv benchmarks.csv
	@$(call PRINT_JULIA, $^ >$@)

gh_action_benchmarks.html: bin/table.jl gh_action_versions.csv gh_action_benchmarks.csv
	@$(call PRINT_JULIA, $^ >$@)

clean:
	@rm -rf perf.h bin/perf* bin/fperf* benchmarks/*.csv benchmarks.csv mods *~ octave-core perf.log gopath/*

.PHONY: all perf clean

.PRECIOUS: bin/perf0 bin/perf1 bin/perf2 bin/perf3
