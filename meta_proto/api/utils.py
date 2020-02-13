import requests
import shutil
from collections import defaultdict
from ftplib import FTP



DBs = ['hmdb', 'kegg', 'chebi', 'chemspider', 'pubchem', 'metlin']

LOG = ''
OFFLINE = True


def http_log(r, _id=None):
    global LOG
    LOG += "  {} GET {}\n    {}\n\n".format(r.status_code, r.url, r.content)


def get_http_log():
    global LOG

    f = str(LOG)
    LOG = ''

    return f


def download_file(url, local_filename):
    # NOTE the stream=True parameter below
    # with requests.get(url, stream=True) as r:
    #     r.raise_for_status()
    #     with open(local_filename, 'wb') as f:
    #         for chunk in r.iter_content(chunk_size=8192):
    #             if chunk: # filter out keep-alive new chunks
    #                 f.write(chunk)
    #                 # f.flush()

    with requests.get(url, stream=True) as r:
        with open(local_filename, 'wb') as f:
            shutil.copyfileobj(r.raw, f)

    return local_filename


def download_file_ftp(url, local_filename, username, password):
    ftp = FTP(url)
    ftp.login(username, password)

    # Get All Files
    files = ftp.nlst()

    # Print out the files
    for file in files:
        ftp.retrbinary("RETR " + file, open("download/to/your/directory/" + file, 'wb').write)

    ftp.close()

    print('All files downloaded for ' + str(diff.seconds) + 's')


def _nil(var):
    if not bool(var):
        return True
    # accounts for xml newlines, whitespace & etc
    s = var.strip().replace('\r', '').replace('\n', '')
    return not bool(s)


def parse_xml_recursive(context, cur_elem=None):
    items = defaultdict(list)

    if cur_elem:
        items.update(cur_elem.attrib)

    text = ""

    for action, elem in context:
        # print("{0:>6} : {1:20} {2:20} '{3}'".format(action, elem.tag, elem.attrib, str(elem.text).strip()))

        if action == "start":
            tag = elem.tag.split('}', 1)[1]
            items[tag].append(parse_xml_recursive(context, elem))
        elif action == "end":
            text = elem.text.strip() if elem.text else ""

            elem.clear()
            break

    if len(items) == 0:
        return text

    return { k: v[0] if len(v) == 1 else v for k, v in items.items() }


def parse_iter_sdf(fn):

    with open(fn, 'r', encoding='utf8') as fh:
        buffer = {}
        state = None

        for line in fh:
            line = line.rstrip('\n')

            if line.startswith('$$$$'):
                # New entry
                yield buffer
                state = None
                buffer = {}
                continue
            elif not line:
                continue
            elif line.startswith('>'):
                state = line[3:-1]
            else:
                if state in buffer:
                    # there are multiple entries in buffer, create a list
                    val = buffer[state]

                    if isinstance(val, list):
                        buffer[state].append(line)
                    else:
                        buffer[state] = [val, line]
                else:
                    buffer[state] = line

def los(v, f=None):
    if isinstance(v, list):
        if f is not None:
            return [f(e) for e in v]
        return v
    elif v is None:
        return None
    else:
        if f is not None:
            return f(v)
        return [v]


def rlen(v):
    if isinstance(v, list):
        return len(v)
    elif v is None:
        return 0
    else:
        return 1
