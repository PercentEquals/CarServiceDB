from datetime import datetime, timedelta
from random import randrange
import random
import string

firstnames = [
    'Bartosz',
    'Bartłomiej',
    'Patryk',
    'Paweł',
    'Maciek',
    'Tomek',
    'Mateusz',
    'Adam',
    'Michał',
    'Krzysztof',
    'Jan',
    'Łukasz',
    'Kacper',
    'Piotr',
    'Alicja',
    'Ania',
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
    'Kowal',
    'Kamiński',
    'Lewandowski',
    'Wójcik',
    'Kowalczyk',
    'Kozłowski',
    'Kwiatkowski',
    'Grabowski',
    'Szymczak',
    'Wojciechowski',
    'Zając',
    'Szymański',
]

def random_date(start, end):
    delta = end - start
    int_delta = (delta.days * 24 * 60 * 60) + delta.seconds
    random_second = randrange(int_delta)
    return start + timedelta(seconds=random_second)

def gen_pesel(gender):
    r = random.randint(70, 99)
    m = random.randint(1, 12)
    if m < 10:
        m = '0' + str(m)

    d = random.randint(1, 28)
    if d < 10:
        d = '0' + str(d)

    return str(r) + str(m) + str(d) + str(random.randint(100, 999)) + gender + str(random.randint(1, 9))

for i in range(1, 51):
    firstname = random.choice(firstnames)
    lastname = random.choice(lastnames)
    gender = str(random.randrange(1, 9+1, 2))

    # Special case for girls
    if firstname[-1] == 'a' and lastname[-3:] == 'ski':
            lastname = lastname[:-1] + 'a'
            gender = str(random.randrange(2, 8+1, 2))


    pesel = gen_pesel(gender)
    phone = '+48' + ''.join(random.choices(string.digits, k = 9))   
    salary = (int(random.randint(2000, 5000) / 100) * 100)
    address = random.randint(1, 40)

    d1 = datetime.strptime('1/1/1970 1:30 PM', '%m/%d/%Y %I:%M %p')
    d2 = datetime.strptime('1/1/1995 4:50 AM', '%m/%d/%Y %I:%M %p')

    print(f"('{pesel}', '{firstname}', '{lastname}', '{random_date(d1, d2).strftime('%Y%m%d 01:00:00 PM')}', '{phone}', {salary}, {address}),")