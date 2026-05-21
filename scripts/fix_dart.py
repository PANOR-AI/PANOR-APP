import re
import pathlib

root = pathlib.Path(r'd:\PANOR\PANOR-APP\flutter_app\lib')
total = 0

def replacer(m):
    val = float(m.group(1))
    return f'.withOpacity({val})'

for fp in root.rglob('*.dart'):
    try:
        with open(fp, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
        if '.withValues(alpha:' in content:
            n = len(re.findall(r'\.withValues\(alpha:\s*[\d.]+\)', content))
            total += n
            fixed = re.sub(r'\.withValues\(alpha:\s*([\d.]+)\)', replacer, content)
            with open(fp, 'w', encoding='utf-8') as f:
                f.write(fixed)
            print(f'Fixed {n} in {fp.name}')
    except Exception as e:
        print(f'Error in {fp.name}: {e}')

print(f'\nTotal: {total} withValues fixed across all dart files')
