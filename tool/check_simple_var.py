import re, glob

files = glob.glob('/home/zpower/Downloads/espectro/lib/**/*.dart', recursive=True)
for filepath in files:
    with open(filepath) as f:
        text = f.read()

    for match in re.finditer(r'([\'"][^\'\n]*\$([a-zA-Z0-9_]+)%[^\'\n]*[\'"])', text):
        full_str = match.group(1)
        var_name = match.group(2)
        print(f"{filepath}: {full_str} -> var: {var_name}")
