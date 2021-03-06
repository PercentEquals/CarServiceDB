import random


plates = ['ESI', 'ELA', 'EL', 'WW', 'SK', 'EPD', 'EZD', 'EBD', 'PO', 'EWI']
vehicle_types = ['Car', 'Special', 'Motor', 'Van', 'Taxi']


with open("vehicles.txt", 'w', encoding="utf-8") as f:
    for i in range(50):
        client_id = random.randint(1, 50)
        plate = random.choice(plates) + ' ' + str(random.randint(10000, 99999))
        vehicle_type = random.choice(vehicle_types)
        mileage = random.randint(20000, 500000)
        f.write(f"({client_id}, '{vehicle_type}', '{plate}', {mileage}),\n")


