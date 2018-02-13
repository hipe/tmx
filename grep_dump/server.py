# NOTE - #todo - nowhere is it reflected that we did this:
#     pip install flask
#     pip install requests

from flask import (
        Flask,
        jsonify,
        request,
)

app = Flask('grep_json')

@app.route('/', methods=['GET'])
def hello_world():
    return 'ohai mamma mia'

if __name__ == '__main__':
    app.run(debug=True)


# #born.
