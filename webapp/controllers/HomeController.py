from flask import render_template, request

from meta_proto.api.discover import discover
from webapp.entities import ApiResponse


class HomeController():
    def __init__(self, server):
        self.server = server

    def welcome(self):
        return render_template('/home/index.html')

    def post_resolve(self):
        resps = []
        discoveries = []


        for req in request.json:
            resp = None
            disc = None

            for db_tag, db_id in req.items():
                if bool(db_id):
                    resp, disc = discover(db_tag, db_id)

            discoveries.append(disc)
            resps.append(resp)

        return ApiResponse({
            "resolve": resps,
            "discoveries": discoveries
        })
