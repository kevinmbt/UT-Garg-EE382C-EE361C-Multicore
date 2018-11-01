with open('inp.txt') as f:
    s = [int(x) for x in f.read().split(',')]

    print(min(s))