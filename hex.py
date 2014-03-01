#!/usr/local/bin/python3

import sys

f = open(sys.argv[1], "r")

for line in f:
    addr = line[3:7]
    addr = int(addr, 16)*4
    addr = int(addr)
    data = line[9:17]
    print("{:0=#6x}".format(addr) + " " + data)
