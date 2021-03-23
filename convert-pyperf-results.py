
# python
import argparse
import json
import os.path
import statistics
import sys

parser = argparse.ArgumentParser(
    description='convert pyperf results to our own'
)
parser.add_argument('results', nargs='+', help='pyperf result file names')
args = parser.parse_args()

output = {
    "metadata": {},
    "benchmarks": [],
}

sys.stderr.write('processing...\n')
for result_name in args.results:
    sys.stderr.write(f'    {result_name}...\n')
    # figure out what benchmark we're dealing with from the name
    name = os.path.splitext(os.path.basename(result_name))[0]
    is_pgo = False
    if name.startswith('pgo-'):
        is_pgo = True
        name = name[len('pgo-'):]
    if not name.startswith('bench-'):
        sys.stderr.write(f'{result_name} does not start with [pgo-]bench-*')
        sys.exit(1)
    name = name[len('bench-'):]
    tokenizer, source = name.split('-', 1)
    if is_pgo:
        tokenizer = f'pgo-{tokenizer}'
    del name

    # load the results from the file
    with open(result_name, 'rb') as result_file:
        result = json.load(result_file)
        
    # get our metadata
    hostname = result["metadata"]["hostname"]
    platform = result["metadata"]["platform"]
    python_implementation = result["metadata"]["python_implementation"]
    python_version = result["metadata"]["python_version"]
    if 'Windows' in platform:
        platform = 'Windows'
    elif 'Linux' in platform:
        platform = 'Linux'
    else:
        sys.stderr.write(f'unknown platform: {platform}')
        sys.exit(1)
        
    # set the metadata and make sure all the files agree on platform/hostname
    if not output["metadata"]:
        output["metadata"]["hostname"] = hostname
        output["metadata"]["platform"] = platform
        output["metadata"]["python_implementation"] = python_implementation
        output["metadata"]["python_version"] = python_version
    else:
        if (output["metadata"]["hostname"] != hostname or
            output["metadata"]["platform"] != platform or 
            output["metadata"]["python_implementation"] != python_implementation or
            output["metadata"]["python_version"] != python_version):
            sys.stderr.write(f'mismatched metadata between files')
            sys.exit(1)
    
    # store the relevant benchmark info
    for benchmark in result["benchmarks"]:
        name = benchmark["metadata"]["name"].replace('\\', '/')
        sys.stderr.write(f'        {name}...\n')
        values = []
        for run in benchmark["runs"]:
            if "values" in run:
                values += run["values"]
        mean = statistics.mean(values)
        stdev = statistics.stdev(values)
        
        output["benchmarks"].append({
            "tokenizer": tokenizer,
            "source": source,
            "name": name,
            "mean": mean,
            "stdev": stdev,
        })

sys.stderr.write('dumping...\n')
print(json.dumps(output))
