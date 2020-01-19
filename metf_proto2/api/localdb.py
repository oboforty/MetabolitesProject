
class Metabolite():
    # todo: extend declarative Base

    def __init__(self, **kwargs):
        self.mid = kwargs.get('mid')
        self.names = kwargs.get('names', [])

        # Xrefs
        self.hmdb_id = kwargs.get('hmdb_id')
        self.chebi_id = kwargs.get('chebi_id')
        self.kegg_id = kwargs.get('kegg_id')
        self.pubchem_id = kwargs.get('pubchem_id')
        self.chemspider_id = kwargs.get('chemspider_id')
        self.lipidmaps_id = kwargs.get('lipidmaps_id')
        self.metlin_id = kwargs.get('metlin_id')

        # Other, unused data
        self.refs_etc = kwargs.get('refs_etc')
        self.data = kwargs.get('data')

    @property
    def refs(self):
        return {
            "hmdb": self.hmdb_id,
            "chebi": self.chebi_id,
            "kegg": self.kegg_id,
            "pubchem": self.pubchem_id,
            "chemspider": self.chemspider_id,
            "lipidmaps": self.lipidmaps_id,
            "metlin": self.metlin_id,
        }
