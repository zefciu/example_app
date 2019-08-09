from flask import Flask
from flask_graphql import GraphQLView
from flask_cors import CORS

from example_app.graph import schema
from example_app.config import config


app = Flask(__name__)
app.debug = True

cors = CORS(app, resources={'/graphql': {'origins': config['frontend_app']}})

app.add_url_rule(
    '/graphql',
    view_func=GraphQLView.as_view(
        'graphql',
        schema=schema,
        graphiql=True,
    )
)
