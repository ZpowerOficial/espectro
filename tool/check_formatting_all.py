import re, glob

files = glob.glob('/home/zpower/Downloads/espectro/lib/**/*.dart', recursive=True)
for filepath in files:
    with open(filepath) as f:
        text = f.read()

    for match in re.finditer(r'([\'"][^\'\n]*\$\{([^\}]+)\}[^\'\n]*[\'"])', text):
        full_str = match.group(1)
        expr = match.group(2)
        if any(k in expr.lower() for k in ['score', 'percent', 'compat', 'dist', 'mean', 'cover', 'prop', 'ratio', 'value', 'vertex', 'pct', 'se', 'tension', 'z', 'error', 'freedom']):
            if not any(k in expr for k in ['round()', 'toStringAsFixed', 'toInt()', 'floor()', 'ceil()', 'length', 'indexOf', 'Index', 'Count', 'toLowerCase', 'toUpperCase', 'label', 'Label', 'name', 'Name', 'title', 'Title', 'id', 'Id', 'kind', 'Kind', 'isEmpty', 'isNotEmpty', 'description', 'Description', 'summary', 'Summary']):
                print(f"{filepath}: {full_str} -> {expr}")
