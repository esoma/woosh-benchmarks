
# humanize
from humanize import naturaldelta as _naturaldelta
# pytablewriter
from pytablewriter import MarkdownTableWriter
# python
import argparse
from datetime import timedelta
import json
import os

def naturaldelta(*args, **kwargs):
    if "minimum_unit" not in kwargs:
        kwargs["minimum_unit"] = 'microseconds'
    r = _naturaldelta(*args, **kwargs)
    return (r
        .replace(' microseconds', 'μs')
        .replace(' microsecond', 'μs')
        .replace(' milliseconds', 'ms')
        .replace(' millisecond', 'ms')
        .replace(' seconds', 's')
        .replace(' second', 's')
    )

parser = argparse.ArgumentParser(
    description='convert results to a markdown table'
)
parser.add_argument('rev', help='woosh revision hash')
parser.add_argument('hostname', help='host for the benchmark')
args = parser.parse_args()

with open(os.path.join('raw', args.rev, f'{args.hostname}.json')) as f:
    results = json.load(f)
    
tokenizers = ['pgo-woosh', 'woosh', 'tokenize', 'cython', 'pgo-cpytoken']
    
benchmarks = sorted({ b["name"] for b in results["benchmarks"] })
pgo_woosh_means = {
    (b["name"], b["source"]): timedelta(seconds=b["mean"])
    for b in results["benchmarks"]
    if b["tokenizer"] == 'pgo-woosh'
}

rows = {}
totals = {}
for benchmark in results["benchmarks"]:
    key = (benchmark["name"], benchmark["source"])
    row = rows.setdefault(
        key,
        [benchmark["name"], benchmark["source"], *([''] * len(tokenizers))]
    )
    total = totals.setdefault(
        benchmark["source"],
        [*([timedelta(seconds=0)] * len(tokenizers))]
    )
    mean = timedelta(seconds=benchmark["mean"])
    nat_mean = naturaldelta(timedelta(seconds=benchmark["mean"]))
    nat_stdev = naturaldelta(timedelta(seconds=benchmark["stdev"]))
    cell = f'{nat_mean} ±{nat_stdev}'
    
    if benchmark["tokenizer"] != 'pgo-woosh':
        pgo_woosh_mean = pgo_woosh_means[key]
        if pgo_woosh_mean <= mean:
            x = mean / pgo_woosh_mean
            cell += f' ({x:.2f}x slower)'
        elif pgo_woosh_mean > mean:
            x = pgo_woosh_mean / mean
            cell += f' ({x:.2f}x faster)'
    row[2 + tokenizers.index(benchmark["tokenizer"])] = cell
    total[tokenizers.index(benchmark["tokenizer"])] += mean
    
    
rows = [kv[1] for kv in sorted(rows.items(), key=lambda kv: kv[0])]

for source, source_totals in reversed(sorted(totals.items(), key=lambda kv: kv[0])):
    cells = []
    for i, total in enumerate(source_totals):
        if total == timedelta(seconds=0):
            cells.append('')
            continue
        cell = naturaldelta(total)
        if tokenizers[i] != 'pgo-woosh':
            pgo_woosh_total = source_totals[tokenizers.index('pgo-woosh')]
            if pgo_woosh_total <= total:
                x = total / pgo_woosh_total
                cell += f' ({x:.2f}x slower)'
            elif pgo_woosh_total > total:
                x = pgo_woosh_total / total
                cell += f' ({x:.2f}x faster)'
        cells.append(cell)
    rows.insert(0, ['TOTAL', source, *cells])
    
writer = MarkdownTableWriter(
    table_name=f'{results["metadata"]["hostname"]}: {args.rev}',
    headers=['Benchmark', 'Source', *tokenizers],
    value_matrix=rows,
)

writer.write_table()
