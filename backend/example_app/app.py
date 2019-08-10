from flask import Flask, render_template
from flask_graphql import GraphQLView
from flask_cors import CORS

from example_app.graph import schema
from example_app.config import config


app = Flask(__name__)
app.debug = True

cors = CORS(app, resources={'/graphql': {'origins': config['frontend_app']}})


def index(path=None):
    return render_template('index.html', js_location=config['js_location'])


app.add_url_rule(
    '/graphql',
    view_func=GraphQLView.as_view(
        'graphql',
        schema=schema,
        graphiql=True,
    )
)

app.add_url_rule(
    '/',
    view_func=index
)

app.add_url_rule(
    '/<path:path>',
    view_func=index
)
