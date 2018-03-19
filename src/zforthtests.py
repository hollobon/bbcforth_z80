#!/usr/bin/env python3

"""
Test runner.
"""

import re
import socketserver
import sys


class ZForthTestHandler(socketserver.BaseRequestHandler):
    def setup(self):
        self.buffer = b''
        self.expected = {}
        labels = {}
        with open('forthz.ROM.LABEL') as label_file:
            for line in label_file:
                match = re.match(r'^([^:]+):\s+equ\s+\$([\da-f]+)', line)
                if match:
                    labels['label_' + match.groups()[0]] = match.groups()[1].upper()
        with open('expect.txt') as expect_file:
            for line in expect_file:
                test_number, expected_value = line.strip().split(' ', 1)
                label, test_number = test_number.split(':')
                self.expected[int(test_number)] = (label, expected_value.format(**labels))

    def lines(self):
        while True:
            data = self.request.recv(1024)
            if not len(data):
                return
            self.buffer += data
            if b'\r' in self.buffer:
                data, self.buffer = self.buffer.split(b'\r', 1)
                yield data

    def handle(self):
        l = self.lines()
        line = next(l)

        if line.startswith(b'Z80FORTH'):
            self.request.sendall(b'C\r')
        else:
            print('Unexpected response: {}'.format(line.decode('unicode_escape')))
            sys.exit(1)

        fail = count = 0
        for line in l:
            line = line.strip()
            match = re.match(r'^TEST ([A-F\d]{4,4}):(.*)$', line.decode('unicode_escape'))
            if match:
                test_number, result = match.groups()
                label, expect = self.expected[int(test_number, 16)]
                if result != expect:
                    print('Test {}({}) failed: expected {}, got {}'.format(test_number, label, expect, result))
                    fail += 1
                else:
                    print('Test {}({}) ok'.format(test_number, label))
                count += 1
            else:
                if line.startswith(b'DONE'):
                    break
        print('{} tests, {} passed, {} failures'.format(count, count - fail, fail))
        if fail:
            sys.exit(1)


if __name__ == "__main__":
    HOST, PORT = "localhost", 25232
    server = socketserver.TCPServer((HOST, PORT), ZForthTestHandler)
    server.handle_request()
