from time import time

from api import ctx
from api.utils import download_file
from api.handlers.FetcherBase import FetcherBase



def parse_KEGG(db_id, content: list):
    dataKEGG = {"refs": {}, "refs_etc": {}, "data": {}, 'names': []}
    handle = iter(content)

    # smart guess whitespace from 1st line
    line = next(handle)
    FL = line.index(db_id.upper())

    state = None
    for line in handle:
        if line.startswith('///') or line == '':
            # /// skips idk
            continue

        if not line.startswith("   "):
            # interpret labels as regular lines, but save the label
            state = line.split()[0]
            line = line[FL:].rstrip('\n')
        else:
            line = line.lstrip().rstrip('\n')

        if 'ENTRY' == state:
            print(line)
        elif 'DBLINKS' == state:
            # foreign references:
            db_tag, db_id = line.split(': ')
            db_tag = db_tag.lower()

            if db_tag.endswith('_id'):
                db_tag = db_tag[:-3]

            if db_tag in DBs:
                dataKEGG['refs'][db_tag] = db_id
            else:
                dataKEGG['refs_etc'][db_tag] = db_id
        elif 'NAME' == state:
            dataKEGG['names'].append(line)
        else:
            # todo: parse rest of file
            pass

    return dataKEGG

def call_KEGG(db_id):
    url = 'http://rest.kegg.jp/get/cpd:{}'.format(db_id)
    r = requests.get(url = url)
    http_log(r)

    if not r.content:
        return None

    return r.content.decode('utf-8').split('\n')

class FetcherKEGG(FetcherBase):
    def __init__(self, fake=False):
        super().__init__(
            url_get='{}',
            url_all='',
            fake=fake
        )

    def parse(self, db_id, content):
        meta = Metabolite()
        return meta

    def download_all(self):
        path_fn = 'tmp/'
        t1 = time()

        if not self.fake:
            download_file(self.url_all_tpl, path_fn)

        session = ctx.Session()

        # save parsed entries into database
        print("Parsing HMDB finished! Took {} seconds".format(round(time() - t1, 2)))
        session.commit()
        session.close()
