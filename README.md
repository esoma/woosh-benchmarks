This repo is for generating, storing and comparing benchmarks for woosh.

This isn't ready yet, just a quick example:

# monster (Linux)-cpython 3.9.2 (64-bit): 59e42ec7178c50c58e82d3eac59490bd5858758d
|    Benchmark    | Source |pgo-woosh |          woosh          |        tokenize         |         cython          |      pgo-cpytoken       |
|-----------------|--------|----------|-------------------------|-------------------------|-------------------------|-------------------------|
|TOTAL            |bytes   |333μs     |427μs (1.28x slower)     |                         |3ms (9.86x slower)       |293μs (1.14x faster)     |
|TOTAL            |bytes-io|382μs     |477μs (1.25x slower)     |7ms (19.59x slower)      |                         |                         |
|stdlib/abc.py    |bytes   |125μs ±3μs|165μs ±3μs (1.32x slower)|                         |1ms ±18μs (11.20x slower)|101μs ±3μs (1.24x faster)|
|stdlib/abc.py    |bytes-io|146μs ±3μs|184μs ±4μs (1.26x slower)|2ms ±28μs (17.51x slower)|                         |                         |
|stdlib/getpass.py|bytes   |208μs ±6μs|262μs ±6μs (1.26x slower)|                         |1ms ±51μs (9.06x slower) |192μs ±4μs (1.08x faster)|
|stdlib/getpass.py|bytes-io|236μs ±3μs|293μs ±5μs (1.24x slower)|4ms ±79μs (20.88x slower)|                         |                         |

# DESKTOP-P6UEFV2 (Windows)-cpython 3.9.2 (64-bit) revision 1a79785: 59e42ec7178c50c58e82d3eac59490bd5858758d
|    Benchmark    | Source |pgo-woosh|          woosh          |        tokenize         |          cython          |      pgo-cpytoken      |
|-----------------|--------|---------|-------------------------|-------------------------|--------------------------|------------------------|
|TOTAL            |bytes   |101μs    |155μs (1.53x slower)     |                         |6ms (66.28x slower)       |149μs (1.48x slower)    |
|TOTAL            |bytes-io|127μs    |180μs (1.42x slower)     |2ms (22.89x slower)      |                          |                        |
|stdlib/abc.py    |bytes   |37μs ±1μs|59μs ±1μs (1.59x slower) |                         |2ms ±113μs (75.73x slower)|53μs ±0μs (1.43x slower)|
|stdlib/abc.py    |bytes-io|47μs ±0μs|69μs ±1μs (1.47x slower) |1ms ±13μs (21.91x slower)|                          |                        |
|stdlib/getpass.py|bytes   |64μs ±2μs|96μs ±1μs (1.50x slower) |                         |3ms ±82μs (60.81x slower) |96μs ±1μs (1.50x slower)|
|stdlib/getpass.py|bytes-io|80μs ±1μs|111μs ±1μs (1.39x slower)|1ms ±29μs (23.46x slower)|                          |                        |
