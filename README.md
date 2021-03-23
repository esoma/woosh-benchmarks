This repo is for generating, storing and comparing benchmarks for woosh.

This isn't ready yet, just a quick example:

# DESKTOP-P6UEFV2: 25fa8e34d7860a06888534d96086a4e39dfaff73
|    Benchmark    | Source |pgo-woosh|          woosh          |        tokenize         |          cython          |      pgo-cpytoken       |
|-----------------|--------|---------|-------------------------|-------------------------|--------------------------|-------------------------|
|TOTAL            |bytes   |99μs     |154μs (1.56x slower)     |                         |6ms (69.68x slower)       |163μs (1.65x slower)     |
|TOTAL            |bytes-io|126μs    |182μs (1.44x slower)     |2ms (23.32x slower)      |                          |                         |
|stdlib/abc.py    |bytes   |36μs ±1μs|59μs ±2μs (1.64x slower) |                         |2ms ±306μs (80.78x slower)|59μs ±2μs (1.64x slower) |
|stdlib/abc.py    |bytes-io|47μs ±1μs|69μs ±0μs (1.47x slower) |1ms ±7μs (22.04x slower) |                          |                         |
|stdlib/getpass.py|bytes   |63μs ±1μs|95μs ±1μs (1.51x slower) |                         |3ms ±103μs (63.33x slower)|104μs ±1μs (1.65x slower)|
|stdlib/getpass.py|bytes-io|79μs ±2μs|113μs ±5μs (1.43x slower)|1ms ±20μs (24.08x slower)|                          |                         |
