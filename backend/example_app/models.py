import sqlalchemy as sa
from sqlalchemy import orm
from sqlalchemy.ext.declarative import declarative_base

from example_app.config import config


engine = sa.create_engine(config['db_connection'], convert_unicode=True)
db_session = orm.scoped_session(
    orm.sessionmaker(
        autocommit=False,
        autoflush=False,
        bind=engine
    )
)


Base = declarative_base()
Base.query = db_session.query_property()


class Person(Base):
    __tablename__ = 'persons'
    id = sa.Column(sa.Integer, primary_key=True)
    email = sa.Column(sa.String(128))
    first_name = sa.Column(sa.String(128))
    last_name = sa.Column(sa.String(128))
    avatar = sa.Column(sa.String(256))
