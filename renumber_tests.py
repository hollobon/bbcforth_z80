#!/usr/bin/env python3

"""
Renumber tests and generate expected test outcome file.
"""


from argparse import ArgumentParser
import os
import re
import sys


def main():
    counter = 0
    state = 'find_label'
    tests = []

    parser = ArgumentParser()
    parser.add_argument('in_file')
    parser.add_argument('out_file')
    parser.add_argument('--only')
    args = parser.parse_args()

    only_tests = args.only.strip() and args.only.strip().split(",")

    with open(args.in_file, 'r') as in_file, \
         open(args.out_file, 'w') as out_file:
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
                    line = '{}test ${:x} ; expect {}'.format(indent, counter, expect)
                    tests.append((label, counter, expect))
                    counter += 1
                    state = 'find_label'
            out_file.write(line + '\n')

    with open('expect.txt', 'w') as expect_file, \
         open('runtests.asm', 'w') as runtests_file:
        print('Only tests {}'.format(only_tests))
        for label, counter, expect in tests:
            if not only_tests or label.lstrip("_test_") in only_tests:
                print('Will run {}'.format(label))
                runtests_file.write('\tdw {}\n\tdw CHECK_STACK\n'.format(label))
                expect_file.write('{}:{} {}\n'.format(label, counter, expect))


if __name__ == '__main__':
    main()
