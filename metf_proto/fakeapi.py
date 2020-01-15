import json
import xml.etree.ElementTree as ET
import xmltodict


_DBs = ['hmdb', 'kegg', 'chebi', 'chemspider', 'pubchem', 'metlin']


def _read_xml(db_tag, met_db_id):
    filename = 'data/{}/{}.xml'.format(db_tag, met_db_id)

    with open(filename) as fh:
        content = fh.read()
    v = xmltodict.parse(content)

    return dict(v)
    # tree = ET.iterparse()
    #
    # # strip annoying HTTP://... prefixes
    # for _, el in tree:
    #     prefix, has_namespace, postfix = el.tag.partition('}')
    #     if has_namespace:
    #         el.tag = postfix  # strip all namespaces
    #
    # root = tree.root
    # v = XmlDictConfig(root)


def call_HMDB(met_db_id):
    cont = _read_xml('hmdb', met_db_id)
    v = cont['metabolite']

    names = [v.pop('name')]
    names.extend(v.pop('synonyms')['synonym'])

    dataHMDB = {"refs": {
        "hmdb_id": v.pop('accession'),
        "kegg_id": v.pop('kegg_id'),
        "chebi_id": v.pop('chebi_id'),
        "chemspider_id": v.pop('chemspider_id'),
        "pubchem_id": v.pop('pubchem_compound_id'),
        "metlin_id": v.pop('metlin_id'),
        # todo: no lipidmaps?
    }, "refs_etc": {
        # todo: What to do with these:
        "drugbank_id": v.pop('drugbank_id'),
        "wikipedia_id": v.pop('wikipedia_id'),
        "phenol_explorer_compound_id": v.pop('phenol_explorer_compound_id'),
        "foodb_id": v.pop('foodb_id'),
        "knapsack_id": v.pop('knapsack_id'),
        "biocyc_id": v.pop('biocyc_id'),
        "bigg_id": v.pop('bigg_id'),
        "pdb_id": v.pop('pdb_id'),
    }, 'data': v, 'names': names}

    return dataHMDB


def call_ChEBI(db_id):
    cont = _read_xml('chebi', db_id)
    x = cont['S:Envelope']['S:Body']['getCompleteEntityResponse']['return']

    names = [x.pop('chebiAsciiName')]
    names.extend([synx['data'] for synx in x.pop('Synonyms')])

    dataCHEBI = {"refs": {}, "refs_etc": {}, "data": {}, 'names': names}

    # add DatabaseLinks as refs
    dblinks = x.pop('DatabaseLinks')
    for oof in dblinks:
        db_tag = oof['type']
        db_id = oof['data']

        if 'KEGG' in db_tag:
            dataCHEBI['refs']['kegg_id'] = db_id
            # todo: discover other Chebi xrefs
        else:
            dataCHEBI['refs_etc'][db_tag] = db_id

    dataCHEBI['data'] = dict(x)

    return dataCHEBI


def call_KEGG(db_id):
    dataKEGG = {"refs": {}, "refs_etc": {}, "data": {}, 'names': []}

    with open('data/kegg/{}.txt'.format(db_id)) as fh:
        state = None

        # smart guess whitespace from 1st line
        line = next(fh)
        FL = line.index(db_id.upper())

        for line in fh:

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

                if db_tag in _DBs:
                    dataKEGG['refs'][db_tag] = db_id
                else:
                    dataKEGG['refs_etc'][db_tag] = db_id
            elif 'NAME' == state:
                dataKEGG['names'].append(line)
            else:
                # todo: parse rest of file
                pass

    return dataKEGG


def call_PubChem(db_id):
    with open('data/pubchem/{}.json'.format(db_id)) as fh:
        content = json.load(fh)
    with open('data/pubchem/{}_refs.json'.format(db_id)) as fh:
        cont_refs = json.load(fh)

    dataPUBCHEM = {"refs": {}, "refs_etc": {}, "data": {}, 'names': []}


    # parse xrefs:
    INF = cont_refs['InformationList']['Information'][0]
    for db_tag, db_id in zip(INF['SourceName'], INF['RegistryID']):
        if db_tag in _DBs:
            dataPUBCHEM['refs'][db_tag] = db_id
        else:
            dataPUBCHEM['refs_etc'][db_tag] = db_id


    # parse name:
    INF = content['PC_Compounds'][0]['props']

    for q in INF:
        # discover names in this weird json
        if 'name' in q['urn']['label'].lower():
            name = q['value']['sval']
            dataPUBCHEM['names'].append(name)

    dataPUBCHEM['data'] = content

    return dataPUBCHEM

def call_Lipidmaps(db_id):
    pass

def call_ChemSpider(db_id):
    pass

def call_Metlin(db_id):
    pass


proxy_db = {
    'hmdb': call_HMDB,
    'chebi': call_ChEBI,
    'kegg': call_KEGG,
    'pubchem': call_PubChem,
    'lipidmaps': call_Lipidmaps,
    'chemspider': call_ChemSpider,
    'metlin': call_Metlin,
}