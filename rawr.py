from collections import defaultdict

with open("tmp/ChEBI_complete.sdf", 'r') as fh:
    state = None
    buffer = defaultdict(list)

    i = 0

    for line in fh:
        line = line.rstrip('\n')

        if 'HMDB0005002' in line:
            print(state, line, buffer)
        if 'HMDB01942' in line:
            print(state, line, buffer)
        if 'HMDB05002' in line:
            print(state, line, buffer)



        if line.startswith('$$$$'):
            i = i + 1

            if buffer['ChEBI ID'] == ['CHEBI:36']:
                print(i, buffer)

            if i % 5000 == 0:
                print(i)

            state = None
            buffer = defaultdict(list)
            continue
        elif not line:
            continue
        elif line.startswith('>'):
            state = line[3:-1]
        else:
            buffer[state].append(line)
