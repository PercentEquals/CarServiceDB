import io

def to_str(arr):
    return ' '.join(arr)

with io.open('./Places.txt', mode='r', encoding='utf-8') as fp:
    id = 1
    for line in fp:
        words = line.strip().split(' ')

        # Skip comments
        if words[0] == '#':
            continue

        street = []
        city = []
        zip_code = []

        for i, word in enumerate(words):
            if '-' in word and word.replace('-', '0').isdecimal():
                zip_code.append(word)
                city = words[i+1:]
                break

            if ',' in word:
                street.append(word[:-1])
            else:
                street.append(word)

        print(f"({id}, '{to_str(street)}', '{to_str(city)}', '{to_str(zip_code)}'),")
        id += 1