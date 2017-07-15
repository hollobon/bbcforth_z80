#!/usr/bin/env python3

import os
import re


def main():
    counter = 0
    with open('tests.asm') as tests_in, \
         open('tests.asm.new', 'w') as tests_out, \
         open('expect.txt', 'w') as expect_file, \
         open('runtests.asm', 'w') as runtests_file:
        for line in tests_in:
            line = line.rstrip()
            match = re.match(r'^(_test_\S+):\s*$', line)
            if match:
                label, = match.groups()
            else:
                match = re.match(r'^(\s+)test\s+(\d+) ; expect (.*)$', line)
                if match:
                    indent, number, expect = match.groups()
                    print('Renumbering test {} to {}'.format(number, counter))
                    line = '{}test {} ; expect {}'.format(indent, counter, expect)
                    expect_file.write('{} {}\n'.format(counter, expect))
                    runtests_file.write('\tdw {}\n'.format(label))
                    counter += 1
            tests_out.write(line + '\n')

    # mtime = os.stat('tests.asm').st_mtime
    # os.utime('tests.asm.new', (mtime, mtime))

if __name__ == '__main__':
    main()
