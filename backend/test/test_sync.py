import unittest

from nose.tools import assert_equal
import sqlalchemy as sa
from sqlalchemy import orm

from example_app.models import Base, Person
from example_app.sync import process_data


class TestSync(unittest.TestCase):

    def setUp(self):
        self.engine = sa.create_engine('sqlite:///:memory:')
        self.session = orm.scoped_session(
            orm.sessionmaker(
                autocommit=False,
                autoflush=False,
                bind=self.engine
            )
        )
        Base.query = self.session.query_property()
        Base.metadata.create_all(bind=self.engine)
        p1 = Person(
            email='john@example.com',
            first_name='John',
            last_name='Smith',
            avatar='http://example.com/pic1.jpeg',
        )
        self.session.add(p1)
        p2 = Person(
            email='juliette@example.com',
            first_name='Juliet',
            last_name='Smith',
            avatar='http://example.com/pic2.jpeg',
        )
        self.session.add(p2)
        self.session.commit()

    def test_sync_new(self):
        """New person should be added"""
        process_data([{
            'email': 'jane@example.com',
            'first_name': 'Jane',
            'last_name': 'Doe',
            'avatar': 'http://example.com/pic3.jpeg',
        }], self.session)
        self.session.commit()
        assert_equal(self.session.query(Person).count(), 3)
        assert_equal(
            self.session.query(Person).filter(
                Person.email == 'jane@example.com'
            ).first().first_name,
            'Jane'
        )

    def test_sync_existing(self):
        """Existing person should be updated"""
        process_data([{
            'email': 'juliette@example.com',
            'first_name': 'Juliet',
            'last_name': 'Brown',
            'avatar': 'http://example.com/pic4.jpeg',
        }], self.session)
        self.session.commit()
        assert_equal(self.session.query(Person).count(), 2)
        assert_equal(
            self.session.query(Person).filter(
                Person.email == 'juliette@example.com'
            ).first().last_name,
            'Brown'
        )

    def tearDown(self):
        Base.metadata.drop_all(bind=self.engine)
