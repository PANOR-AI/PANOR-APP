import os

def fix_file(file_path):
    with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()

    idx = 0
    result = []
    n = len(content)
    replaced = 0
    while idx < n:
        # Find next occurrence of .withValues(
        match_idx = content.find('.withValues(', idx)
        if match_idx == -1:
            result.append(content[idx:])
            break
        
        # Append up to the match
        result.append(content[idx:match_idx])
        
        # The .withValues( starts at match_idx. The opening '(' is at match_idx + 11.
        start_paren = match_idx + 11
        paren_count = 1
        curr = start_paren + 1
        while curr < n and paren_count > 0:
            if content[curr] == '(':
                paren_count += 1
            elif content[curr] == ')':
                paren_count -= 1
            curr += 1
        
        if paren_count == 0:
            # We found the matching closing parenthesis at curr - 1
            inner = content[start_paren + 1 : curr - 1].strip()
            # The inner content should be "alpha: <expr>"
            if inner.startswith('alpha:'):
                expr = inner[6:].strip()
                result.append(f'.withOpacity({expr})')
                replaced += 1
            else:
                # If it's not "alpha:", just keep it unchanged
                result.append(content[match_idx:curr])
            idx = curr
        else:
            # Mismatched parenthesis, keep unchanged
            result.append(content[match_idx:start_paren + 1])
            idx = start_paren + 1

    if replaced > 0:
        new_content = "".join(result)
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Fixed {file_path}: replaced {replaced} occurrences")

def main():
    lib_dir = r"d:\PANOR\PANOR-APP\flutter_app\lib"
    for root, dirs, files in os.walk(lib_dir):
        for file in files:
            if file.endswith('.dart'):
                fix_file(os.path.join(root, file))

if __name__ == "__main__":
    main()
