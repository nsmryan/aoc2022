
f = open("input.txt", 'r')
#f = open("example.txt", 'r')

lines = f.read().split()

def parse(line):
    tree = []
    while len(line) > 0 and line[0] != "]":
        if line[0] == ",":
            line = line[1:]
        elif line[0] == "[":
            (line, subtree) = parse(line[1:])
            tree.append(subtree)
        else:
            endIndex = line.find(",")
            if endIndex < 0:
                endIndex = line.find("]")
            else:
                endIndex = min(endIndex, line.find("]"))

            if endIndex < 0:
                endIndex = len(line) - 1

            num = int(line[0:endIndex])
            tree.append(num)
            line = line[endIndex+1:]

    if len(line) > 0:
        line = line[1:]

    return (line, tree)

def ooo(first, second):
    if type(first) == int and type(second) == int:
        if first < second: return -1
        elif first == second: return 0
        else: return 1
    if type(first) == list and type(second) == list:
        if len(first) == 0 and len(second) == 0:
            return 0
        elif len(first) == 0 and len(second) > 0:
            return -1
        elif len(first) > 0 and len(second) == 0:
            return 1
        else:
            firstItem = ooo(first[0], second[0]) 
            if firstItem == 0:
                return ooo(first[1:], second[1:])
            else:
                return firstItem
    
    if type(first) == int:
        first = [first]
    elif type(second) == int:
        second = [second]
    return ooo(first, second)

total = 0
index = 1
msgs = []
for (first, second) in zip(lines[0::2], lines[1::2]):
    _, t0 = parse(first[1:])
    _, t1 = parse(second[1:])
    msgs.append(t0)
    msgs.append(t1)
    if ooo(t0, t1) < 0:
        total += index

    index += 1

print("Part 1: " + str(total))

div0 = "[[2]]"
div1 = "[[6]]"
_, d0 = parse(div0)
_, d1 = parse(div1)
msgs.append(d0)
msgs.append(d1)

from functools import cmp_to_key
msgs = sorted(msgs, key=cmp_to_key(ooo))
total2 = 1
for index in range(len(msgs)):
    print("\t" + unparse(msgs[index]))
    if msgs[index] == d0:
        total2 *= index + 1
    if msgs[index] == d1:
        total2 *= index + 1
print("Part 2: " + str(total2))
