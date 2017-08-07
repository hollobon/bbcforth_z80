#!/usr/bin/env python3

import re
import sys


def set_links():
    with open(sys.argv[1]) as in_file, \
         open(sys.argv[2], "w") as out_file:
        prev_name = '0'
        for line in in_file:
            if line.lstrip().startswith(';'):
                continue
            out_file.write(re.sub('0$', prev_name, line))
            match = re.match('^_LF_(.*): equ 0', line)
            if not match:
                raise Exception('invalid line: {}'.format(line))
            prev_name = '_NF_' + match.groups()[0]


if __name__ == '__main__':
    set_links()
