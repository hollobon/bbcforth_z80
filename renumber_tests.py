#!/usr/bin/env python3

import re


def main():
    counter = 0
    with open('tests.asm') as tests_in, \
         open('tests.asm.new', 'w') as tests_out, \
         open('expect.txt', 'w') as expect_file:
        for line in tests_in:
            line = line.rstrip()
            match = re.match(r'^(\s+)test\s+(\d+) ; expect (.*)$', line)
            if match:
                indent, number, expect = match.groups()
                print('Renumbering test {} to {}'.format(number, counter))
                line = '{}test {} ; expect {}'.format(indent, counter, expect)
                expect_file.write('{} {}\n'.format(counter, expect))
                counter += 1
            tests_out.write(line + '\n')

main()
