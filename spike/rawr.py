import xmltodict

message = """<?xml version="1.0"?><note><DatabaseLinks><data>C00007446</data><type>KNApSAcK accession</type></DatabaseLinks><DatabaseLinks><data>C00053</data><type>KEGG COMPOUND accession</type></DatabaseLinks><DatabaseLinks><data>PPS</data><type>PDBeChem accession</type></DatabaseLinks><OntologyParents/></note>"""



x = xmltodict.parse(message)


print(1)
