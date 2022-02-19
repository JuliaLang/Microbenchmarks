ifndef JULIAHOME
$(error JULIAHOME not defined. Set value to the root of the Julia source tree.)
endif
ifndef DSFMTDIR
$(error DSFMTDIR not defined. Set value to the root of the dSFMT source tree.)
endif

include $(JULIAHOME)/Make.inc
include $(JULIAHOME)/deps/Versions.make

NODEJSBIN = node8

ITERATIONS=$(shell seq 1 5)

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

default: benchmarks.html

export OMP_NUM_THREADS=1
export GOTO_NUM_THREADS=1
export OPENBLAS_NUM_THREADS=1

perf.h: $(JULIAHOME)/deps/Versions.make
	echo '#include "cblas.h"' > $@
	echo '#include "$(DSFMTDIR)/dSFMT.c"' >> $@

bin/perf%: perf.c perf.h
	$(CC) -std=c99 -O$* $< -o $@  -I$(DSFMTDIR) -lopenblas -L$(LIBMDIR) $(LIBM) $(CFLAGS) -lpthread

bin/fperf%: perf.f90
	mkdir -p mods/$@ #Modules for each binary go in separate directories
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
	$(foreach t,$(ITERATIONS), $<;) >$@

benchmarks/fortran%.csv: bin/fperf%
	$(foreach t,$(ITERATIONS), $<;) >$@

benchmarks/go.csv: export GOPATH=$(abspath gopath)
benchmarks/go.csv: perf.go
	#CGO_LDFLAGS="-lopenblas $(LIBM)" go get github.com/gonum/blas/cgo
	go get github.com/gonum/blas/blas64
	go get github.com/gonum/blas/cgo
	go get github.com/gonum/matrix/mat64
	go get github.com/gonum/stat
	$(foreach t,$(ITERATIONS), go run $<;) >$@

benchmarks/julia.csv: perf.jl
	$(foreach t,$(ITERATIONS), $(JULIAHOME)/usr/bin/julia $<;) >$@

benchmarks/python.csv: perf.py
	$(foreach t,$(ITERATIONS), $(PYTHON) $<;) >$@

benchmarks/matlab.csv: perf.m
	$(foreach t,$(ITERATIONS), matlab -nojvm -singleCompThread -r 'perf; perf; exit' | grep ^matlab | tail -8;) >$@

benchmarks/octave.csv: perf.m
	$(foreach t,$(ITERATIONS), $(OCTAVE) -q --eval perf 2>/dev/null;) >$@

benchmarks/r.csv: perf.R
	$(foreach t,$(ITERATIONS), cat $< | R --vanilla --slave 2>/dev/null;) >$@

benchmarks/javascript.csv: perf.js
	$(foreach t,$(ITERATIONS), $(NODEJSBIN) $<;) >$@

benchmarks/mathematica.csv: perf.nb
	$(foreach t,$(ITERATIONS), $(MATHEMATICABIN) -noprompt -run "<<$<; Exit[]";) >$@

benchmarks/stata.csv: perf.do
	$(foreach t,$(ITERATIONS), stata -b do $^ $@;)

benchmarks/lua.csv: perf.lua
	$(foreach t,$(ITERATIONS), scilua $<;) >$@

benchmarks/java.csv: java/src/main/java/PerfBLAS.java
	cd java; sh setup.sh; $(foreach t,$(ITERATIONS), mvn -q exec:java;) >../$@

benchmarks/scala.csv: scala/src/main/scala/perf.scala scala/build.sbt
	cd scala; $(foreach t,$(ITERATIONS), sbt run;) >../$@

benchmarks/rust.csv: rust/src/main.rs rust/src/util.rs rust/Cargo.lock
	cd rust; $(foreach t,$(ITERATIONS), cargo run --release -q;) >../$@

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
	bin/versions.sh ",c,fortran,go,julia,python,rust," >$@

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
