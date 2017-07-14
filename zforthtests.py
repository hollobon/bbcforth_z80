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
        with open('expect.txt') as expect_file:
            for line in expect_file:
                test_number, expected_value = line.strip().split()
                self.expected[int(test_number)] = expected_value
                
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
        if line.startswith(b'*'):
            self.request.sendall(b'\r')
            self.request.sendall(b'FORTH\r')
        else:
            print('Unexpected response: {}'.format(self.data.decode('utf8')))
            sys.exit(1)

        for line in l:
            if line.startswith(b'Z80FORTH'):
                self.request.sendall(b'C\r')
                break

        for line in l:
            line = line.strip()
            match = re.match(r'^TEST (\d{4,4}):(.*)$', line.decode('utf8'))
            if match:
                test_number, result = match.groups()
                expect = self.expected[int(test_number)]
                if result != expect:
                    print('Test {} failed: expected {}, got {}'.format(test_number, expect, result))
                else:
                    print('Test {} ok'.format(test_number))


if __name__ == "__main__":
    HOST, PORT = "localhost", 25232
    server = socketserver.TCPServer((HOST, PORT), ZForthTestHandler)
    server.handle_request()
