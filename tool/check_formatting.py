import re

with open('/home/zpower/Downloads/espectro/lib/ui/features/results/espectro_result_screen.dart') as f:
    text = f.read()

# find all string interpolations with variables
for match in re.finditer(r'\'([^\'\n]*\$\{([^\}]+)\}[^\'\n]*)\'', text):
    full_str = match.group(1)
    expr = match.group(2)
    # Check if expr looks like a number or double
    if any(k in expr.lower() for k in ['score', 'percent', 'compat', 'dist', 'mean', 'cover', 'prop', 'ratio', 'value', 'vertex', 'pct', 'se', 'tension', 'z', 'error', 'freedom']):
        if not any(k in expr for k in ['round()', 'toStringAsFixed', 'toInt()', 'floor()', 'ceil()', 'length', 'indexOf', 'Index', 'Count']):
            print(f"UNFORMATTED in espectro_result_screen.dart: '{full_str}' -> expr: {expr}")
