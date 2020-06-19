import json

from flask import Flask, request, jsonify
from flask_restplus import Resource, Api, fields

app = Flask(__name__)
api = Api(app)

VERSION = "DEV"

with open("names.json") as input_file:
    names_input = input_file.read()
    NAMES = json.loads(names_input)


@api.route('/instructions')
class Users(Resource):

    def get(self):
        if VERSION == "QA":
            return {"todo": "Create a short automated test for this API. Check that the data returned by the API is "
                    "valid, and that ensure that each valid operation can be successfully called for each endpoint. "
                    "Once you've built the tests, push the answer to Github or Gitlab, and send us a link. "}
        else:
            return {"todo": "Build an API which calls this API, and returns people who are listed as either living in "
                        "London, or whose current coordinates are within 50 miles of London. Push the answer to Github,"
                        " and send us a link."}


@api.route('/users')
class Users(Resource):

    def get(self):
        output = [remove_field(user, "city") for user in NAMES]
        return output


@api.route('/user/<string:id>')
class Users(Resource):

    @api.doc(responses={404: 'Not Found', 200: 'Success'})
    def get(self, id):
        output = [user for user in NAMES if user['id'] == id or str(user['id']) == id]
        if output != []:
            return output[0]
        else:
            api.abort(404, "Id {} doesn't exist".format(id))


@api.route('/city/<string:city>/users')
class Users(Resource):

    def get(self, city):
        output = [remove_field(user, "city") for user in NAMES if user['city'] == city or str(user['city']) == city]
        return output


def remove_field(user: dict, field: str):
    output = user.copy()
    del output[field]
    return output


if __name__ == '__main__':
    app.run(host="0.0.0.0", debug=True)
