file = '../../tmp/tests/cov_old/resolve_dump.csv'
file2 = '../../tmp/tests/resolve_dump2.csv'


with open(file, encoding='utf-8') as fh:
    content = fh.read()
    content2 = [content[0]]

    for i in range(1, len(content)-1):
        if content[i-1] == '"' and content[i+1] == '"' and content[i] == ' ':
            c = "|"
        else:
            c = content[i]
        content2.append(c)

    with open(file2, 'w', encoding='utf-8') as fh2:
        fh2.write(''.join(content2))




sys.exit()
