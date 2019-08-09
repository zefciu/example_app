import graphene
import graphene_sqlalchemy as gsa
from example_app import models


class Person(gsa.SQLAlchemyObjectType):
    class Meta:
        model = models.Person
        interfaces = (graphene.relay.Node,)


class PersonsConnection(graphene.relay.Connection):
    class Meta:
        node = Person


class Query(graphene.ObjectType):
    node = graphene.relay.Node.Field()
    person = graphene.relay.Node.Field(Person)
    persons = gsa.SQLAlchemyConnectionField(PersonsConnection)


schema = graphene.Schema(query=Query)
