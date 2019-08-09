import requests
from example_app.models import db_session, Person


REQRES_URL = 'https://reqres.in/api/users'


def process_data(data):
    for person_data in data:
        person = db_session.query(Person).filter_by(
            email=person_data['email']
        ).first()
        if not person:
            person = Person(email=person_data['email'])
            db_session.add(person)
            print(f'Created new person: {person_data["email"]}')
        person.first_name = person_data['first_name']
        person.last_name = person_data['last_name']
        person.avatar = person_data['avatar']


def main():
    current_page = 1
    total_pages = None
    while True:
        request = requests.get(REQRES_URL, params={'page': current_page})
        json_data = request.json()
        total_pages = json_data['total_pages']
        process_data(json_data['data'])
        if current_page == total_pages:
            break
        current_page += 1
    db_session.commit()


if __name__ == '__main__':
    main()
