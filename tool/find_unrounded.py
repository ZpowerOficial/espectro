import re
import glob

files = glob.glob('/home/zpower/Downloads/espectro/lib/**/*.dart', recursive=True)
for f in files:
    with open(f) as fp:
        lines = fp.readlines()
    for i, line in enumerate(lines):
        line_str = line.strip()
        if '%' in line_str or 'Score' in line_str or 'score' in line_str:
            # find interpolations like ${something}%
            for m in re.finditer(r'\$\{([^}]+)\}%', line_str):
                expr = m.group(1)
                if not any(fn in expr for fn in ['round', 'toStringAsFixed', 'toInt', 'ceil', 'floor', 'int', 'Length', 'count', 'Count', 'Index']):
                    print(f"{f}:{i+1}: {line_str}")
            # Also check for .toStringAsFixed
            for m in re.finditer(r'([a-zA-Z0-9_\.]+(?:Score|Coverage|Engagement|Weight|Percent|Compatibility|Score))\b', line_str):
                pass
