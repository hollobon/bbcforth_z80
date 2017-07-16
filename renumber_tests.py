#!/usr/bin/env python3

"""
Renumber tests and generate expected test outcome file.
"""

import os
import re
import sys


def main():
    counter = 0
    state = 'find_label'
    with open(sys.argv[1]) as in_file, \
         open(sys.argv[2], 'w') as out_file, \
         open('expect.txt', 'w') as expect_file, \
         open('runtests.asm', 'w') as runtests_file:
        for line in in_file:
            line = line.rstrip()
            if state == 'find_label':
                match = re.match(r'^(_test_\S+):\s*$', line)
                if match:
                    label, = match.groups()
                    state = 'find_test'
            elif state == 'find_test':
                match = re.match(r'^(\s+)test\s+(\d+)\s+;\s+expect (.*)$', line)
                if match:
                    indent, number, expect = match.groups()
                    print('Renumbering test {} to {}'.format(number, counter))
                    line = '{}test {} ; expect {}'.format(indent, counter, expect)
                    expect_file.write('{} {}\n'.format(counter, expect))
                    runtests_file.write('\tdw {}\n'.format(label))
                    counter += 1
                    state = 'find_label'
            out_file.write(line + '\n')


if __name__ == '__main__':
    main()
