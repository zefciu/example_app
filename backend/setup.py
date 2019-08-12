from setuptools import setup

setup(
    name='example_app',
    version='0.0.1',
    packages=['example_app'],
    install_requires=[
        'Flask==1.1.1',
        'flask-cors==3.0.8',
        'flask-graphql==2.0.0',
        'flask-mako==0.4',
        'graphene==2.1.7',
        'graphene-sqlalchemy==2.2.1',
        'psycopg2==2.8.3',
        'PyYAML==5.1.2',
        'requests==2.22.0',
        'SQLAlchemy==1.3.6',
    ],
    tests_require=[
        'nose==1.3.7',
    ],
    entry_points={
        'console_scripts': [
            'example_app_sync=example_app.sync:main',
        ]
    }
)
