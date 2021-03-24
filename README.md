This repo is for generating, storing and comparing benchmarks for woosh.

This isn't ready yet, just a quick example:

# monster (Linux)-cpython 3.9.2 (64-bit): 59e42ec7178c50c58e82d3eac59490bd5858758d
|    Benchmark    | Source |pgo-woosh |          woosh          |        tokenize         |         cython          |      pgo-cpytoken       |
|-----------------|--------|----------|-------------------------|-------------------------|-------------------------|-------------------------|
|TOTAL            |bytes   |191μs     |418μs (2.19x slower)     |                         |2ms (15.56x slower)      |241μs (1.26x slower)     |
|TOTAL            |bytes-io|239μs     |459μs (1.92x slower)     |6ms (27.24x slower)      |                         |                         |
|stdlib/abc.py    |bytes   |69μs ±2μs |162μs ±3μs (2.35x slower)|                         |1ms ±27μs (18.29x slower)|84μs ±1μs (1.22x slower) |
|stdlib/abc.py    |bytes-io|88μs ±2μs |178μs ±2μs (2.02x slower)|2ms ±30μs (25.64x slower)|                         |                         |
|stdlib/getpass.py|bytes   |122μs ±3μs|256μs ±6μs (2.10x slower)|                         |1ms ±69μs (14.02x slower)|157μs ±3μs (1.29x slower)|
|stdlib/getpass.py|bytes-io|151μs ±4μs|281μs ±5μs (1.86x slower)|4ms ±48μs (28.17x slower)|                         |                         |

# Fenestra (Linux)-cpython 3.9.2 (64-bit): 59e42ec7178c50c58e82d3eac59490bd5858758d
|    Benchmark    | Source |pgo-woosh|          woosh          |         tokenize          |          cython           |      pgo-cpytoken      |
|-----------------|--------|---------|-------------------------|---------------------------|---------------------------|------------------------|
|TOTAL            |bytes   |92μs     |156μs (1.70x slower)     |                           |1ms (17.11x slower)        |129μs (1.40x slower)    |
|TOTAL            |bytes-io|114μs    |178μs (1.56x slower)     |2ms (24.05x slower)        |                           |                        |
|stdlib/abc.py    |bytes   |33μs ±0μs|59μs ±1μs (1.79x slower) |                           |674μs ±12μs (20.42x slower)|44μs ±1μs (1.33x slower)|
|stdlib/abc.py    |bytes-io|42μs ±0μs|68μs ±1μs (1.62x slower) |951μs ±11μs (22.64x slower)|                           |                        |
|stdlib/getpass.py|bytes   |59μs ±2μs|97μs ±1μs (1.64x slower) |                           |900μs ±19μs (15.25x slower)|85μs ±1μs (1.44x slower)|
|stdlib/getpass.py|bytes-io|72μs ±2μs|110μs ±1μs (1.53x slower)|1ms ±41μs (24.88x slower)  |                           |                        |

# DESKTOP-P6UEFV2 (Windows)-cpython 3.9.2 (64-bit) revision 1a79785: 59e42ec7178c50c58e82d3eac59490bd5858758d
|    Benchmark    | Source |pgo-woosh|          woosh          |        tokenize         |          cython          |      pgo-cpytoken      |
|-----------------|--------|---------|-------------------------|-------------------------|--------------------------|------------------------|
|TOTAL            |bytes   |101μs    |155μs (1.53x slower)     |                         |6ms (66.28x slower)       |149μs (1.48x slower)    |
|TOTAL            |bytes-io|127μs    |180μs (1.42x slower)     |2ms (22.89x slower)      |                          |                        |
|stdlib/abc.py    |bytes   |37μs ±1μs|59μs ±1μs (1.59x slower) |                         |2ms ±113μs (75.73x slower)|53μs ±0μs (1.43x slower)|
|stdlib/abc.py    |bytes-io|47μs ±0μs|69μs ±1μs (1.47x slower) |1ms ±13μs (21.91x slower)|                          |                        |
|stdlib/getpass.py|bytes   |64μs ±2μs|96μs ±1μs (1.50x slower) |                         |3ms ±82μs (60.81x slower) |96μs ±1μs (1.50x slower)|
|stdlib/getpass.py|bytes-io|80μs ±1μs|111μs ±1μs (1.39x slower)|1ms ±29μs (23.46x slower)|                          |                        |
