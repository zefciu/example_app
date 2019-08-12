About this project
=====================

This is an example application that displays a paginated list of users
downloaded from reqres.in. It contains a Flask backend and Elm frontend
communicating by GraphQL.

Installation
==================

Download and install the project
-----------------------

Clone the project::

    $ git clone https://github.com/zefciu/example_app.git

Create the virtualenv for the project::

    $ virtualenv --python=/usr/bin/python3.6 .virtualenv
    $ . .virtualenv/bin/activate

Install the backend::
    
    $ cd backend
    $ pip install -e .

Run the test suite::
    
    $ python setup.py test


Create database
-----------------

Create a database for your project. E.g. when using PostgreSQL::
    
    # CREATE DATABASE example_app WITH OWNER your_username;

Migrate the database. Ensure that `config.yaml` points to an existing database.
Then call::

    $ alembic upgrade head

Download the data::

    $ example_app_sync

Run the backend
-------------------

::

    $ cd ..
    $ bin/runserver

You can now navigate to `http://127.0.0.1:5000/graphql` to with a browser or a
client like Graphiql to browse the API


Generate the Schema
------------------------

Without stopping the server, open another console and call::

    $ cd frontend
    $ npm install
    $ sudo npm install -g npx
    $ cd ..
    $ bin/generate_schema

This would generate a directory in `frontend/src/Schema` containing Elm types
based on your graphql.

Run the frontend
--------------------

::

    $ cd frontend
    $ sudo npm install -g elm
    $ sudo npm install -g elm-live
    $ elm-live src/Main.elm -- --output=elm.js


Navigate your browser to http://127.0.0.1:5000

Production environment
--------------------------

Note that for production environment you should:

* Serve the backend via WSGI and some production-grade server (like gunicorn)
* Compile the `elm.js` file and serve it statically
* Reconfigure `config.yaml` to reflect you configuration
