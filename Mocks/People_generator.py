from datetime import datetime, timedelta
from random import randrange
import random
import string

firstnames = [
    'Bartosz',
    'Patryk',
    'Maciek',
    'Tomek',
    'Mateusz',
    'Adam',
    'Krzysztof',
    'Jan',
    'Kacper',
    'Piotr',
    'Alicja',
    'Grażyna',
    'Katarzyna',
    'Aneta',
    'Kamila',
    'Krystyna',
    'Klaudia',
]

lastnames = [
    'Nowak',
    'Kowalski',
    'Wiśniewski',
    'Kowalczyk',
    'Kamiński',
    'Lewandowski',
    'Wójcik',
    'Kowalewski',
    'Kozłowski',
    'Kwiatkowski',
    'Kaczmarek',
    'Mazur',
    'Krawczyk',
    'Kucharski',
    'Piotrowski',
    'Grabowski',
    'Zając',
    'Szymański',
]

def random_date(start, end):
    delta = end - start
    int_delta = (delta.days * 24 * 60 * 60) + delta.seconds
    random_second = randrange(int_delta)
    return start + timedelta(seconds=random_second)

for i in range(1, 21):
    firstname = random.choice(firstnames)
    lastname = random.choice(lastnames)

    # Special case for girls
    if firstname[-1] == 'a' and lastname[-3:] == 'ski':
            lastname = lastname[:-1] + 'a'

    phone = '+48' + ''.join(random.choices(string.digits, k = 9))   
    salary = (int(random.randint(2000, 5000) / 100) * 100)
    address = random.randint(1, 40)

    d1 = datetime.strptime('1/1/1970 1:30 PM', '%m/%d/%Y %I:%M %p')
    d2 = datetime.strptime('1/1/1995 4:50 AM', '%m/%d/%Y %I:%M %p')

    print(f"({i}, '{firstname}', '{lastname}', '{random_date(d1, d2).strftime('%Y%m%d 01:00:00 PM')}', '{phone}', {salary}, {address}),")