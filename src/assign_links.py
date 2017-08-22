#!/usr/bin/env python3

import re
import sys


def set_links():
    with open(sys.argv[1], "w") as out_file:
        prev_name = '0'
        for line in sys.stdin:
            if line.lstrip().startswith(';'):
                continue
            out_file.write(re.sub('0$', prev_name, line))
            match = re.match('^_LF_(.*): equ 0', line)
            if not match:
                raise Exception('invalid line: {}'.format(line))
            prev_name = '_NF_' + match.groups()[0]
        out_file.write('__NF_FIRST: equ {}'.format(prev_name))

if __name__ == '__main__':
    set_links()
