# Microbenchmarks

This is a collection of micro-benchmarks used to compare Julia's performance against
that of other languages.
It was formerly part of the Julia source tree.
The results of these benchmarks are used to generate the performance graph on the
[Julia benchmarks page](https://julialang.org/benchmarks).

## Running benchmarks

This repository assumes that Julia has been built from source and that there exists
an environment variable `JULIAHOME` that points to the root of the Julia source tree.
This can also be set when invoking `make`, e.g. `make JULIAHOME=path/to/julia`.

To build binaries and run the benchmarks, simply run `make`.
Note that this refers to GNU Make, so BSD users will need to run `gmake`.

## Included languages:

* C
* Fortran
* Go
* Java
* JavaScript
* Julia
* LuaJIT
* Mathematica
* Matlab
* Python
* R
* Rust
* Scala

## Results:

<svg xmlns="http://www.w3.org/2000/svg" xmlns:gadfly="https://www.gadflyjl.org/ns" xmlns:xlink="https://www.w3.org/1999/xlink" width="864" height="533.972" fill="#000" stroke="none" stroke-width=".3" font-size="3.88" version="1.2" viewBox="0 0 228.6 141.28"><g id="img-403ad6d6-1" class="plotroot yscalable"><g id="img-403ad6d6-2" fill="#6C606B" class="guide xlabels" font-family="Georgia" font-size="2.82"><g><g class="primitive"><text dy=".6em" text-anchor="middle" transform="translate(18.57,132.65)">C</text></g></g><g><g class="primitive"><text dy=".6em" text-anchor="middle" transform="translate(32.3,132.65)">Julia</text></g></g><g><g class="primitive"><text dy=".6em" text-anchor="middle" transform="translate(46.03,132.65)">LuaJIT</text></g></g><g><g class="primitive"><text dy=".6em" text-anchor="middle" transform="translate(59.76,132.65)">Rust</text></g></g><g><g class="primitive"><text dy=".6em" text-anchor="middle" transform="translate(73.49,132.65)">Go</text></g></g><g><g class="primitive"><text dy=".6em" text-anchor="middle" transform="translate(87.22,132.65)">Fortran</text></g></g><g><g class="primitive"><text dy=".6em" text-anchor="middle" transform="translate(100.95,132.65)">Java</text></g></g><g><g class="primitive"><text dy=".6em" text-anchor="middle" transform="translate(114.68,132.65)">JavaScript</text></g></g><g><g class="primitive"><text dy=".6em" text-anchor="middle" transform="translate(128.42,132.65)">Matlab</text></g></g><g><g class="primitive"><text dy=".6em" text-anchor="middle" transform="translate(142.15,132.65)">Mathematica</text></g></g><g><g class="primitive"><text dy=".6em" text-anchor="middle" transform="translate(155.88,132.65)">Python</text></g></g><g><g class="primitive"><text dy=".6em" text-anchor="middle" transform="translate(169.61,132.65)">R</text></g></g><g><g class="primitive"><text dy=".6em" text-anchor="middle" transform="translate(183.34,132.65)">Octave</text></g></g></g><g id="img-403ad6d6-3" class="guide colorkey"><g id="img-403ad6d6-4" fill="#4C404B" font-family="'PT Sans','Helvetica Neue','Helvetica',sans-serif" font-size="2.82"><g id="img-403ad6d6-5" class="color_iteration_pi_sum"><g class="primitive"><text dy=".35em" transform="translate(198.14,57.44)">iteration_pi_sum</text></g></g><g id="img-403ad6d6-6" class="color_matrix_multiply"><g class="primitive"><text dy=".35em" transform="translate(198.14,61.07)">matrix_multiply</text></g></g><g id="img-403ad6d6-7" class="color_matrix_statistics"><g class="primitive"><text dy=".35em" transform="translate(198.14,64.7)">matrix_statistics</text></g></g><g id="img-403ad6d6-8" class="color_parse_integers"><g class="primitive"><text dy=".35em" transform="translate(198.14,68.32)">parse_integers</text></g></g><g id="img-403ad6d6-9" class="color_print_to_file"><g class="primitive"><text dy=".35em" transform="translate(198.14,71.95)">print_to_file</text></g></g><g id="img-403ad6d6-10" class="color_recursion_fibonacci"><g class="primitive"><text dy=".35em" transform="translate(198.14,75.58)">recursion_fibonacci</text></g></g><g id="img-403ad6d6-11" class="color_recursion_quicksort"><g class="primitive"><text dy=".35em" transform="translate(198.14,79.2)">recursion_quicksort</text></g></g><g id="img-403ad6d6-12" class="color_userfunc_mandelbrot"><g class="primitive"><text dy=".35em" transform="translate(198.14,82.83)">userfunc_mandelbrot</text></g></g></g><g id="img-403ad6d6-13" stroke="#000" stroke-opacity="0"><g id="img-403ad6d6-14" fill="#00BFFF" class="color_iteration_pi_sum" transform="translate(196.14,57.44)"><circle cx="0" cy="0" r=".91" class="primitive"/></g><g id="img-403ad6d6-15" fill="#D4CA3A" class="color_matrix_multiply" transform="translate(196.14,61.07)"><circle cx="0" cy="0" r=".91" class="primitive"/></g><g id="img-403ad6d6-16" fill="#FF6DAE" class="color_matrix_statistics" transform="translate(196.14,64.7)"><circle cx="0" cy="0" r=".91" class="primitive"/></g><g id="img-403ad6d6-17" fill="#00B78D" class="color_parse_integers" transform="translate(196.14,68.32)"><circle cx="0" cy="0" r=".91" class="primitive"/></g><g id="img-403ad6d6-18" fill="#BEA9FF" class="color_print_to_file" transform="translate(196.14,71.95)"><circle cx="0" cy="0" r=".91" class="primitive"/></g><g id="img-403ad6d6-19" fill="#FF6765" class="color_recursion_fibonacci" transform="translate(196.14,75.58)"><circle cx="0" cy="0" r=".91" class="primitive"/></g><g id="img-403ad6d6-20" fill="#C6C6C6" class="color_recursion_quicksort" transform="translate(196.14,79.2)"><circle cx="0" cy="0" r=".91" class="primitive"/></g><g id="img-403ad6d6-21" fill="#63DF75" class="color_userfunc_mandelbrot" transform="translate(196.14,82.83)"><circle cx="0" cy="0" r=".91" class="primitive"/></g></g><g id="img-403ad6d6-22" fill="#362A35" stroke="#000" stroke-opacity="0" font-family="'PT Sans','Helvetica Neue','Helvetica',sans-serif" font-size="3.88"><g id="img-403ad6d6-23"><g class="primitive"><text transform="translate(195.33,53.62)">benchmark</text></g></g></g></g><g clip-path="url(#img-403ad6d6-24)"><g id="img-403ad6d6-25"><g id="img-403ad6d6-26" fill="#000" fill-opacity="0" stroke="#000" stroke-opacity="0" class="guide background" opacity="1" pointer-events="visible"><g id="img-403ad6d6-27"><path d="M-91.31,-63.32 L 91.31 -63.32 91.31 63.32 -91.31 63.32 z" class="primitive" transform="translate(103.01,68.32)"/></g></g><g id="img-403ad6d6-28" stroke="#D0D0E0" stroke-dasharray=".5 .5" stroke-width=".2" class="guide ygridlines xfixed"><g id="img-403ad6d6-29"><path fill="none" d="M-91.31,0 L 91.31 0" class="primitive" transform="translate(103.01,116.6)"/></g><g id="img-403ad6d6-30"><path fill="none" d="M-91.31,0 L 91.31 0" class="primitive" transform="translate(103.01,90.51)"/></g><g id="img-403ad6d6-31"><path fill="none" d="M-91.31,0 L 91.31 0" class="primitive" transform="translate(103.01,64.41)"/></g><g id="img-403ad6d6-32"><path fill="none" d="M-91.31,0 L 91.31 0" class="primitive" transform="translate(103.01,38.31)"/></g><g id="img-403ad6d6-33"><path fill="none" d="M-91.31,0 L 91.31 0" class="primitive" transform="translate(103.01,12.22)"/></g></g><g id="img-403ad6d6-34" stroke="#D0D0E0" stroke-dasharray=".5 .5" stroke-width=".2" class="guide xgridlines yfixed"><g id="img-403ad6d6-35"><path fill="none" d="M0,-63.32 L 0 63.32" class="primitive" transform="translate(25.43,68.32)"/></g><g id="img-403ad6d6-36"><path fill="none" d="M0,-63.32 L 0 63.32" class="primitive" transform="translate(39.16,68.32)"/></g><g id="img-403ad6d6-37"><path fill="none" d="M0,-63.32 L 0 63.32" class="primitive" transform="translate(52.89,68.32)"/></g><g id="img-403ad6d6-38"><path fill="none" d="M0,-63.32 L 0 63.32" class="primitive" transform="translate(66.63,68.32)"/></g><g id="img-403ad6d6-39"><path fill="none" d="M0,-63.32 L 0 63.32" class="primitive" transform="translate(80.36,68.32)"/></g><g id="img-403ad6d6-40"><path fill="none" d="M0,-63.32 L 0 63.32" class="primitive" transform="translate(94.09,68.32)"/></g><g id="img-403ad6d6-41"><path fill="none" d="M0,-63.32 L 0 63.32" class="primitive" transform="translate(107.82,68.32)"/></g><g id="img-403ad6d6-42"><path fill="none" d="M0,-63.32 L 0 63.32" class="primitive" transform="translate(121.55,68.32)"/></g><g id="img-403ad6d6-43"><path fill="none" d="M0,-63.32 L 0 63.32" class="primitive" transform="translate(135.28,68.32)"/></g><g id="img-403ad6d6-44"><path fill="none" d="M0,-63.32 L 0 63.32" class="primitive" transform="translate(149.01,68.32)"/></g><g id="img-403ad6d6-45"><path fill="none" d="M0,-63.32 L 0 63.32" class="primitive" transform="translate(162.74,68.32)"/></g><g id="img-403ad6d6-46"><path fill="none" d="M0,-63.32 L 0 63.32" class="primitive" transform="translate(176.48,68.32)"/></g></g><g id="img-403ad6d6-47" class="plotpanel"><metadata><boundingbox value="11.699999999999989mm 5.0mm 182.62666666666667mm 126.64923649489262mm"/><unitbox value="0.5 4.27664132503908 13.3 -4.8532826500781585"/></metadata><g id="img-403ad6d6-48" class="geometry"><g id="img-403ad6d6-49" stroke-width=".3"><g id="img-403ad6d6-50" fill="#63DF75" stroke="#FFF" class="color_userfunc_mandelbrot"><g id="img-403ad6d6-51" class="marker"><g id="img-403ad6d6-52" transform="translate(183.34,18.37)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-53" fill="#C6C6C6" stroke="#FFF" class="color_recursion_quicksort"><g id="img-403ad6d6-54" class="marker"><g id="img-403ad6d6-55" transform="translate(183.34,29.27)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-56" fill="#FF6765" stroke="#FFF" class="color_recursion_fibonacci"><g id="img-403ad6d6-57" class="marker"><g id="img-403ad6d6-58" transform="translate(183.34,12.17)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-59" fill="#BEA9FF" stroke="#FFF" class="color_print_to_file"><g id="img-403ad6d6-60" class="marker"><g id="img-403ad6d6-61" transform="translate(183.34,61.42)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-62" fill="#00B78D" stroke="#FFF" class="color_parse_integers"><g id="img-403ad6d6-63" class="marker"><g id="img-403ad6d6-64" transform="translate(183.34,44.6)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-65" fill="#FF6DAE" stroke="#FFF" class="color_matrix_statistics"><g id="img-403ad6d6-66" class="marker"><g id="img-403ad6d6-67" transform="translate(183.34,73.15)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-68" fill="#D4CA3A" stroke="#FFF" class="color_matrix_multiply"><g id="img-403ad6d6-69" class="marker"><g id="img-403ad6d6-70" transform="translate(183.34,114.39)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-71" fill="#00BFFF" stroke="#FFF" class="color_iteration_pi_sum"><g id="img-403ad6d6-72" class="marker"><g id="img-403ad6d6-73" transform="translate(183.34,51.31)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-74" fill="#63DF75" stroke="#FFF" class="color_userfunc_mandelbrot"><g id="img-403ad6d6-75" class="marker"><g id="img-403ad6d6-76" transform="translate(169.61,56.81)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-77" fill="#C6C6C6" stroke="#FFF" class="color_recursion_quicksort"><g id="img-403ad6d6-78" class="marker"><g id="img-403ad6d6-79" transform="translate(169.61,70.6)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-80" fill="#FF6765" stroke="#FFF" class="color_recursion_fibonacci"><g id="img-403ad6d6-81" class="marker"><g id="img-403ad6d6-82" transform="translate(169.61,53.41)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-83" fill="#BEA9FF" stroke="#FFF" class="color_print_to_file"><g id="img-403ad6d6-84" class="marker"><g id="img-403ad6d6-85" transform="translate(169.61,64.23)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-86" fill="#00B78D" stroke="#FFF" class="color_parse_integers"><g id="img-403ad6d6-87" class="marker"><g id="img-403ad6d6-88" transform="translate(169.61,72.18)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-89" fill="#FF6DAE" stroke="#FFF" class="color_matrix_statistics"><g id="img-403ad6d6-90" class="marker"><g id="img-403ad6d6-91" transform="translate(169.61,82.11)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-92" fill="#D4CA3A" stroke="#FFF" class="color_matrix_multiply"><g id="img-403ad6d6-93" class="marker"><g id="img-403ad6d6-94" transform="translate(169.61,92.67)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-95" fill="#00BFFF" stroke="#FFF" class="color_iteration_pi_sum"><g id="img-403ad6d6-96" class="marker"><g id="img-403ad6d6-97" transform="translate(169.61,88.73)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-98" fill="#63DF75" stroke="#FFF" class="color_userfunc_mandelbrot"><g id="img-403ad6d6-99" class="marker"><g id="img-403ad6d6-100" transform="translate(155.88,69.18)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-101" fill="#C6C6C6" stroke="#FFF" class="color_recursion_quicksort"><g id="img-403ad6d6-102" class="marker"><g id="img-403ad6d6-103" transform="translate(155.88,75.5)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-104" fill="#FF6765" stroke="#FFF" class="color_recursion_fibonacci"><g id="img-403ad6d6-105" class="marker"><g id="img-403ad6d6-106" transform="translate(155.88,65.08)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-107" fill="#BEA9FF" stroke="#FFF" class="color_print_to_file"><g id="img-403ad6d6-108" class="marker"><g id="img-403ad6d6-109" transform="translate(155.88,98.97)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-110" fill="#00B78D" stroke="#FFF" class="color_parse_integers"><g id="img-403ad6d6-111" class="marker"><g id="img-403ad6d6-112" transform="translate(155.88,82.78)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-113" fill="#FF6DAE" stroke="#FFF" class="color_matrix_statistics"><g id="img-403ad6d6-114" class="marker"><g id="img-403ad6d6-115" transform="translate(155.88,84.01)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-116" fill="#D4CA3A" stroke="#FFF" class="color_matrix_multiply"><g id="img-403ad6d6-117" class="marker"><g id="img-403ad6d6-118" transform="translate(155.88,114.72)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-119" fill="#00BFFF" stroke="#FFF" class="color_iteration_pi_sum"><g id="img-403ad6d6-120" class="marker"><g id="img-403ad6d6-121" transform="translate(155.88,86.08)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-122" fill="#63DF75" stroke="#FFF" class="color_userfunc_mandelbrot"><g id="img-403ad6d6-123" class="marker"><g id="img-403ad6d6-124" transform="translate(142.15,83.66)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-125" fill="#C6C6C6" stroke="#FFF" class="color_recursion_quicksort"><g id="img-403ad6d6-126" class="marker"><g id="img-403ad6d6-127" transform="translate(142.15,73.59)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-128" fill="#FF6765" stroke="#FFF" class="color_recursion_fibonacci"><g id="img-403ad6d6-129" class="marker"><g id="img-403ad6d6-130" transform="translate(142.15,61.26)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-131" fill="#BEA9FF" stroke="#FFF" class="color_print_to_file"><g id="img-403ad6d6-132" class="marker"><g id="img-403ad6d6-133" transform="translate(142.15,68.97)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-134" fill="#00B78D" stroke="#FFF" class="color_parse_integers"><g id="img-403ad6d6-135" class="marker"><g id="img-403ad6d6-136" transform="translate(142.15,81.24)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-137" fill="#FF6DAE" stroke="#FFF" class="color_matrix_statistics"><g id="img-403ad6d6-138" class="marker"><g id="img-403ad6d6-139" transform="translate(142.15,93.78)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-140" fill="#D4CA3A" stroke="#FFF" class="color_matrix_multiply"><g id="img-403ad6d6-141" class="marker"><g id="img-403ad6d6-142" transform="translate(142.15,114.67)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-143" fill="#00BFFF" stroke="#FFF" class="color_iteration_pi_sum"><g id="img-403ad6d6-144" class="marker"><g id="img-403ad6d6-145" transform="translate(142.15,112.34)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-146" fill="#63DF75" stroke="#FFF" class="color_userfunc_mandelbrot"><g id="img-403ad6d6-147" class="marker"><g id="img-403ad6d6-148" transform="translate(128.42,90.68)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-149" fill="#C6C6C6" stroke="#FFF" class="color_recursion_quicksort"><g id="img-403ad6d6-150" class="marker"><g id="img-403ad6d6-151" transform="translate(128.42,106.85)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-152" fill="#FF6765" stroke="#FFF" class="color_recursion_fibonacci"><g id="img-403ad6d6-153" class="marker"><g id="img-403ad6d6-154" transform="translate(128.42,84.1)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-155" fill="#BEA9FF" stroke="#FFF" class="color_print_to_file"><g id="img-403ad6d6-156" class="marker"><g id="img-403ad6d6-157" transform="translate(128.42,64.22)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-158" fill="#00B78D" stroke="#FFF" class="color_parse_integers"><g id="img-403ad6d6-159" class="marker"><g id="img-403ad6d6-160" transform="translate(128.42,57.86)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-161" fill="#FF6DAE" stroke="#FFF" class="color_matrix_statistics"><g id="img-403ad6d6-162" class="marker"><g id="img-403ad6d6-163" transform="translate(128.42,92.9)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-164" fill="#D4CA3A" stroke="#FFF" class="color_matrix_multiply"><g id="img-403ad6d6-165" class="marker"><g id="img-403ad6d6-166" transform="translate(128.42,114.87)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-167" fill="#00BFFF" stroke="#FFF" class="color_iteration_pi_sum"><g id="img-403ad6d6-168" class="marker"><g id="img-403ad6d6-169" transform="translate(128.42,116.52)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-170" fill="#63DF75" stroke="#FFF" class="color_userfunc_mandelbrot"><g id="img-403ad6d6-171" class="marker"><g id="img-403ad6d6-172" transform="translate(114.68,115.17)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-173" fill="#C6C6C6" stroke="#FFF" class="color_recursion_quicksort"><g id="img-403ad6d6-174" class="marker"><g id="img-403ad6d6-175" transform="translate(114.68,100.11)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-176" fill="#FF6765" stroke="#FFF" class="color_recursion_fibonacci"><g id="img-403ad6d6-177" class="marker"><g id="img-403ad6d6-178" transform="translate(114.68,102.34)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-179" fill="#BEA9FF" stroke="#FFF" class="color_print_to_file"><g id="img-403ad6d6-180" class="marker"><g id="img-403ad6d6-181" transform="translate(114.68,94.15)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-182" fill="#00B78D" stroke="#FFF" class="color_parse_integers"><g id="img-403ad6d6-183" class="marker"><g id="img-403ad6d6-184" transform="translate(114.68,98.28)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-185" fill="#FF6DAE" stroke="#FFF" class="color_matrix_statistics"><g id="img-403ad6d6-186" class="marker"><g id="img-403ad6d6-187" transform="translate(114.68,86.71)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-188" fill="#D4CA3A" stroke="#FFF" class="color_matrix_multiply"><g id="img-403ad6d6-189" class="marker"><g id="img-403ad6d6-190" transform="translate(114.68,77.4)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-191" fill="#00BFFF" stroke="#FFF" class="color_iteration_pi_sum"><g id="img-403ad6d6-192" class="marker"><g id="img-403ad6d6-193" transform="translate(114.68,116.51)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-194" fill="#63DF75" stroke="#FFF" class="color_userfunc_mandelbrot"><g id="img-403ad6d6-195" class="marker"><g id="img-403ad6d6-196" transform="translate(100.95,112.57)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-197" fill="#C6C6C6" stroke="#FFF" class="color_recursion_quicksort"><g id="img-403ad6d6-198" class="marker"><g id="img-403ad6d6-199" transform="translate(100.95,104.22)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-200" fill="#FF6765" stroke="#FFF" class="color_recursion_fibonacci"><g id="img-403ad6d6-201" class="marker"><g id="img-403ad6d6-202" transform="translate(100.95,101.96)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-203" fill="#BEA9FF" stroke="#FFF" class="color_print_to_file"><g id="img-403ad6d6-204" class="marker"><g id="img-403ad6d6-205" transform="translate(100.95,90.91)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-206" fill="#00B78D" stroke="#FFF" class="color_parse_integers"><g id="img-403ad6d6-207" class="marker"><g id="img-403ad6d6-208" transform="translate(100.95,103.52)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-209" fill="#FF6DAE" stroke="#FFF" class="color_matrix_statistics"><g id="img-403ad6d6-210" class="marker"><g id="img-403ad6d6-211" transform="translate(100.95,98.3)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-212" fill="#D4CA3A" stroke="#FFF" class="color_matrix_multiply"><g id="img-403ad6d6-213" class="marker"><g id="img-403ad6d6-214" transform="translate(100.95,92.93)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-215" fill="#00BFFF" stroke="#FFF" class="color_iteration_pi_sum"><g id="img-403ad6d6-216" class="marker"><g id="img-403ad6d6-217" transform="translate(100.95,115.67)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-218" fill="#63DF75" stroke="#FFF" class="color_userfunc_mandelbrot"><g id="img-403ad6d6-219" class="marker"><g id="img-403ad6d6-220" transform="translate(87.22,120.61)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-221" fill="#C6C6C6" stroke="#FFF" class="color_recursion_quicksort"><g id="img-403ad6d6-222" class="marker"><g id="img-403ad6d6-223" transform="translate(87.22,114.63)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-224" fill="#FF6765" stroke="#FFF" class="color_recursion_fibonacci"><g id="img-403ad6d6-225" class="marker"><g id="img-403ad6d6-226" transform="translate(87.22,116.73)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-227" fill="#BEA9FF" stroke="#FFF" class="color_print_to_file"><g id="img-403ad6d6-228" class="marker"><g id="img-403ad6d6-229" transform="translate(87.22,96.35)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-230" fill="#00B78D" stroke="#FFF" class="color_parse_integers"><g id="img-403ad6d6-231" class="marker"><g id="img-403ad6d6-232" transform="translate(87.22,94.75)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-233" fill="#FF6DAE" stroke="#FFF" class="color_matrix_statistics"><g id="img-403ad6d6-234" class="marker"><g id="img-403ad6d6-235" transform="translate(87.22,111.69)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-236" fill="#D4CA3A" stroke="#FFF" class="color_matrix_multiply"><g id="img-403ad6d6-237" class="marker"><g id="img-403ad6d6-238" transform="translate(87.22,114.94)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-239" fill="#00BFFF" stroke="#FFF" class="color_iteration_pi_sum"><g id="img-403ad6d6-240" class="marker"><g id="img-403ad6d6-241" transform="translate(87.22,116.6)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-242" fill="#63DF75" stroke="#FFF" class="color_userfunc_mandelbrot"><g id="img-403ad6d6-243" class="marker"><g id="img-403ad6d6-244" transform="translate(73.49,119.44)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-245" fill="#C6C6C6" stroke="#FFF" class="color_recursion_quicksort"><g id="img-403ad6d6-246" class="marker"><g id="img-403ad6d6-247" transform="translate(73.49,114.14)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-248" fill="#FF6765" stroke="#FFF" class="color_recursion_fibonacci"><g id="img-403ad6d6-249" class="marker"><g id="img-403ad6d6-250" transform="translate(73.49,109.91)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-251" fill="#BEA9FF" stroke="#FFF" class="color_print_to_file"><g id="img-403ad6d6-252" class="marker"><g id="img-403ad6d6-253" transform="translate(73.49,110.26)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-254" fill="#00B78D" stroke="#FFF" class="color_parse_integers"><g id="img-403ad6d6-255" class="marker"><g id="img-403ad6d6-256" transform="translate(73.49,117.06)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-257" fill="#FF6DAE" stroke="#FFF" class="color_matrix_statistics"><g id="img-403ad6d6-258" class="marker"><g id="img-403ad6d6-259" transform="translate(73.49,96.13)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-260" fill="#D4CA3A" stroke="#FFF" class="color_matrix_multiply"><g id="img-403ad6d6-261" class="marker"><g id="img-403ad6d6-262" transform="translate(73.49,112.55)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-263" fill="#00BFFF" stroke="#FFF" class="color_iteration_pi_sum"><g id="img-403ad6d6-264" class="marker"><g id="img-403ad6d6-265" transform="translate(73.49,116.6)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-266" fill="#63DF75" stroke="#FFF" class="color_userfunc_mandelbrot"><g id="img-403ad6d6-267" class="marker"><g id="img-403ad6d6-268" transform="translate(59.76,119.84)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-269" fill="#C6C6C6" stroke="#FFF" class="color_recursion_quicksort"><g id="img-403ad6d6-270" class="marker"><g id="img-403ad6d6-271" transform="translate(59.76,116.85)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-272" fill="#FF6765" stroke="#FFF" class="color_recursion_fibonacci"><g id="img-403ad6d6-273" class="marker"><g id="img-403ad6d6-274" transform="translate(59.76,110.42)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-275" fill="#BEA9FF" stroke="#FFF" class="color_print_to_file"><g id="img-403ad6d6-276" class="marker"><g id="img-403ad6d6-277" transform="translate(59.76,117.95)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-278" fill="#00B78D" stroke="#FFF" class="color_parse_integers"><g id="img-403ad6d6-279" class="marker"><g id="img-403ad6d6-280" transform="translate(59.76,114.26)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-281" fill="#FF6DAE" stroke="#FFF" class="color_matrix_statistics"><g id="img-403ad6d6-282" class="marker"><g id="img-403ad6d6-283" transform="translate(59.76,112.51)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-284" fill="#D4CA3A" stroke="#FFF" class="color_matrix_multiply"><g id="img-403ad6d6-285" class="marker"><g id="img-403ad6d6-286" transform="translate(59.76,115.75)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-287" fill="#00BFFF" stroke="#FFF" class="color_iteration_pi_sum"><g id="img-403ad6d6-288" class="marker"><g id="img-403ad6d6-289" transform="translate(59.76,116.6)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-290" fill="#63DF75" stroke="#FFF" class="color_userfunc_mandelbrot"><g id="img-403ad6d6-291" class="marker"><g id="img-403ad6d6-292" transform="translate(46.03,116.56)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-293" fill="#C6C6C6" stroke="#FFF" class="color_recursion_quicksort"><g id="img-403ad6d6-294" class="marker"><g id="img-403ad6d6-295" transform="translate(46.03,111.56)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-296" fill="#FF6765" stroke="#FFF" class="color_recursion_fibonacci"><g id="img-403ad6d6-297" class="marker"><g id="img-403ad6d6-298" transform="translate(46.03,114.65)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-299" fill="#BEA9FF" stroke="#FFF" class="color_print_to_file"><g id="img-403ad6d6-300" class="marker"><g id="img-403ad6d6-301" transform="translate(46.03,122.32)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-302" fill="#00B78D" stroke="#FFF" class="color_parse_integers"><g id="img-403ad6d6-303" class="marker"><g id="img-403ad6d6-304" transform="translate(46.03,116.86)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-305" fill="#FF6DAE" stroke="#FFF" class="color_matrix_statistics"><g id="img-403ad6d6-306" class="marker"><g id="img-403ad6d6-307" transform="translate(46.03,110.54)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-308" fill="#D4CA3A" stroke="#FFF" class="color_matrix_multiply"><g id="img-403ad6d6-309" class="marker"><g id="img-403ad6d6-310" transform="translate(46.03,115.72)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-311" fill="#00BFFF" stroke="#FFF" class="color_iteration_pi_sum"><g id="img-403ad6d6-312" class="marker"><g id="img-403ad6d6-313" transform="translate(46.03,116.6)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-314" fill="#63DF75" stroke="#FFF" class="color_userfunc_mandelbrot"><g id="img-403ad6d6-315" class="marker"><g id="img-403ad6d6-316" transform="translate(32.3,120.85)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-317" fill="#C6C6C6" stroke="#FFF" class="color_recursion_quicksort"><g id="img-403ad6d6-318" class="marker"><g id="img-403ad6d6-319" transform="translate(32.3,116.64)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-320" fill="#FF6765" stroke="#FFF" class="color_recursion_fibonacci"><g id="img-403ad6d6-321" class="marker"><g id="img-403ad6d6-322" transform="translate(32.3,113.4)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-323" fill="#BEA9FF" stroke="#FFF" class="color_print_to_file"><g id="img-403ad6d6-324" class="marker"><g id="img-403ad6d6-325" transform="translate(32.3,115.58)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-326" fill="#00B78D" stroke="#FFF" class="color_parse_integers"><g id="img-403ad6d6-327" class="marker"><g id="img-403ad6d6-328" transform="translate(32.3,107.7)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-329" fill="#FF6DAE" stroke="#FFF" class="color_matrix_statistics"><g id="img-403ad6d6-330" class="marker"><g id="img-403ad6d6-331" transform="translate(32.3,111.04)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-332" fill="#D4CA3A" stroke="#FFF" class="color_matrix_multiply"><g id="img-403ad6d6-333" class="marker"><g id="img-403ad6d6-334" transform="translate(32.3,116.88)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-335" fill="#00BFFF" stroke="#FFF" class="color_iteration_pi_sum"><g id="img-403ad6d6-336" class="marker"><g id="img-403ad6d6-337" transform="translate(32.3,116.48)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-338" fill="#63DF75" stroke="#FFF" class="color_userfunc_mandelbrot"><g id="img-403ad6d6-339" class="marker"><g id="img-403ad6d6-340" transform="translate(18.57,116.6)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-341" fill="#C6C6C6" stroke="#FFF" class="color_recursion_quicksort"><g id="img-403ad6d6-342" class="marker"><g id="img-403ad6d6-343" transform="translate(18.57,116.6)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-344" fill="#FF6765" stroke="#FFF" class="color_recursion_fibonacci"><g id="img-403ad6d6-345" class="marker"><g id="img-403ad6d6-346" transform="translate(18.57,116.6)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-347" fill="#BEA9FF" stroke="#FFF" class="color_print_to_file"><g id="img-403ad6d6-348" class="marker"><g id="img-403ad6d6-349" transform="translate(18.57,116.6)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-350" fill="#00B78D" stroke="#FFF" class="color_parse_integers"><g id="img-403ad6d6-351" class="marker"><g id="img-403ad6d6-352" transform="translate(18.57,116.6)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-353" fill="#FF6DAE" stroke="#FFF" class="color_matrix_statistics"><g id="img-403ad6d6-354" class="marker"><g id="img-403ad6d6-355" transform="translate(18.57,116.6)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-356" fill="#D4CA3A" stroke="#FFF" class="color_matrix_multiply"><g id="img-403ad6d6-357" class="marker"><g id="img-403ad6d6-358" transform="translate(18.57,116.6)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g><g id="img-403ad6d6-359" fill="#00BFFF" stroke="#FFF" class="color_iteration_pi_sum"><g id="img-403ad6d6-360" class="marker"><g id="img-403ad6d6-361" transform="translate(18.57,116.6)"><circle cx="0" cy="0" r=".9" class="primitive"/></g></g></g></g></g></g></g></g><g id="img-403ad6d6-362" fill="#6C606B" class="guide ylabels" font-family="Georgia" font-size="2.82"><g id="img-403ad6d6-363"><g class="primitive"><text dy=".35em" text-anchor="end" transform="translate(10.7,116.6)">10<tspan dominant-baseline="inherit" dy="-.6em" font-size="83%">0</tspan></text></g></g><g id="img-403ad6d6-364"><g class="primitive"><text dy=".35em" text-anchor="end" transform="translate(10.7,90.51)">10<tspan dominant-baseline="inherit" dy="-.6em" font-size="83%">1</tspan></text></g></g><g id="img-403ad6d6-365"><g class="primitive"><text dy=".35em" text-anchor="end" transform="translate(10.7,64.41)">10<tspan dominant-baseline="inherit" dy="-.6em" font-size="83%">2</tspan></text></g></g><g id="img-403ad6d6-366"><g class="primitive"><text dy=".35em" text-anchor="end" transform="translate(10.7,38.31)">10<tspan dominant-baseline="inherit" dy="-.6em" font-size="83%">3</tspan></text></g></g><g id="img-403ad6d6-367"><g class="primitive"><text dy=".35em" text-anchor="end" transform="translate(10.7,12.22)">10<tspan dominant-baseline="inherit" dy="-.6em" font-size="83%">4</tspan></text></g></g></g></g><defs><clipPath id="img-403ad6d6-24"><path d="M11.7,5 L 194.33 5 194.33 131.65 11.7 131.65"/></clipPath></defs></svg>