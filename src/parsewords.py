#!/usr/bin/env python3

"""
Parse BBCFORTH assembly and pull out words.

Build list with links, attempt to build definition of words.
"""

from argparse import ArgumentParser
import itertools
import sys
import re
import subprocess


class Word(object):
    def __init__(self, filename, line_number, label, name, code_label, lfa, cfa, name_length, flags):
        self.filename = filename
        self.line_number = line_number
        self.label = label
        self.name = name
        self.code_label = code_label
        self.lfa = lfa
        self.cfa = cfa
        self.name_length = name_length
        self.flags = flags
        self._words = []

    def append(self, word):
        size, word = word
        for w in word.split(','):
            w = w.strip()
            if re.match(r'^\d+$', w):
                self._words.append(int(w))
            elif re.match(r'^\$([a-fA-F\d]+)$', w):
                value = int(w[1:], 16)
                if value > 0x8000:
                    value = -(~value & 0xFFFF) - 1
                self._words.append(value)
            else:
                self._words.append(w)

    def words(self):
        if self.cfa != 'DOCOL':
            raise Exception('{} is not a colon definition'.format(self.name))

        for w in self._words:
            if isinstance(w, int):
                yield w
            else:
                try:
                    yield words_by_label[w]
                except KeyError:
                    yield w

    def definition(self):
        return ': {} {} ;'.format(self.name, ' '.join(
            str(w) if isinstance(w, int) else w.name if hasattr(w, 'name') else '?{}?'.format(w)
            for w in self.words()))

    def z80(self):
        print(';; {}'.format(self.name))
        if self.cfa == 'DOCOL':
            print(';;    {}'.format(self.definition()))
        print('_NF_{}:'.format(self.code_label))
        print('\tdb ${:x},\'{}\',${:x}'.format(self.name_length | 0x80 | (0x40 if 'immediate' in self.flags else 0), self.name[:-1], ord(self.name[-1]) | 0x80))
        print('\tdw _LF_{}'.format(self.code_label))
        if self.cfa == 'DOCOL':
            print('{}:\tdw DOCOL'.format(self.code_label))
            for w in self.words():
                if isinstance(w, int):
                    print('\tdw {}${:x}'.format('-' if w < 0 else '', abs(w)))
                else:
                    if hasattr(w, "code_label"):
                        print('\tdw {}'.format(w.code_label))
                    else:
                        print('\tdw {} ; ???'.format(w))
        elif self.cfa == 'DOCON':
            print('{}:\tdw DOCON'.format(self.code_label))
            print('\tdw {}'.format(self._words[0]))
        elif self.cfa == 'DOUSE':
            print('{}:\tdw DOUSE'.format(self.code_label))
            print('\tdw {}'.format(self._words[0]))
        elif self.cfa == '*+2':
            print('{}:\tdw $+2'.format(self.code_label))
            print('\n\tjp NEXT')

    def __repr__(self):
        result = 'WORD name: {}, label: {}, code label: {}, lfa: {}, cfa: {}, name len: {}, flags: {}, location: {}:{}'.format(
            self.name,
            self.label,
            self.code_label,
            self.lfa,
            self.cfa,
            self.name_length,
            self.flags,
            self.filename,
            self.line_number + 1)

        if self.cfa == 'DOCOL':
            result += '\n    : {} {} ;'.format(self.name, self.definition())

        elif self.cfa == 'DOCON':
            result = '\n{} CONSTANT {}'.format(self._words[0], self.name)

        elif self.cfa == 'DOUSE':
            result = '\n{} USER {}'.format(self._words[0], self.name)

        return result


words = {}
links = {}
words_by_name = {}
words_by_label = {}


def main():
    parser = ArgumentParser()
    parser.add_argument('-f', '--input', metavar='FILENAME', type=str, help='input filename',
                        default='../aforth/BBCFORTH.ASM')
    parser.add_argument('-w', '--word', metavar='WORD', type=str, help='Look up definition of a word')
    parser.add_argument('-l', '--label', metavar='LABEL', type=str, help='Look up definition of a word')
    parser.add_argument('--edit', action="store_true")
    parser.add_argument('--check', action="store_true")
    parser.add_argument('--z80', action="store_true")
    parser.add_argument('--alloftype')
    args = parser.parse_args()

    state = 'search'
    line_number = 0
    cfas = []
    with open(args.input) as input_file:
        try:
            for n, line in enumerate(input_file):
                line = line.rstrip()
                match = re.match(r'^;\t(.*)$', line)
                if match:
                    state = 'possword'
                    comment = match.groups()[0]
                    continue
                match = re.match(r'^(\S+)\s+=\s+(\S+)-REL$', line)
                if match:
                    words_by_label[match.groups()[0]] = words_by_label[match.groups()[1]]
                    continue
                if state == 'possword':
                    match = re.match(r"^(L....)\t\.BYTE\t(\$..),(?:'([^']+)',)?(\$..)", line)
                    if match:
                        state = 'wordstart'
                        label, first, *middle, last = match.groups()
                        first_value = int(first[1:], 16)
                        length = first_value & 0x1F
                        if middle[0]:
                            name = middle[0]
                        else:
                            name = ""
                        name += chr(int(last[1:], 16) & 0x7f)
                        flags = []
                        if first_value & 0x40:
                            flags.append('immediate')
                        line_number = n
                        continue

                #state = 'search'
                if state == 'wordstart':
                    match = re.match(r'^\t.WORD\t(.*?)(?:-REL)?$', line)
                    if not match:
                        raise Exception('Failed to find LFA for {}'.format(name))
                    lfa = match.groups()[0]
                    state = 'cfa'
                    continue

                if state == 'cfa':
                    match = re.match(r'^([^\s]+)?\s+\.WORD\s+(.*)$', line)
                    if not match:
                        raise Exception('Failed to find CFA for {}'.format(name))
                    clabel, cfa = match.groups()
                    cfas.append(cfa)
                    word = Word(args.input, line_number, label, name, clabel, lfa, cfa, length, flags)
                    words[label] = word
                    links[lfa] = word
                    words_by_name[name] = word
                    words_by_label[clabel] = word
                    state = 'readword'
                    continue

                if state == 'readword':
                    match = re.match(r'^\s+(\.WORD|\.BYTE)\s+(.*?)\s*(;.*)?\s*$', line)
                    if match:
                        size, word_name, *_ = match.groups()
                        word.append((size, word_name))
                    else:
                        state = 'search'
                    continue

        except Exception as e:
            print('line', n, line)
            raise

    if args.alloftype:
        for word in words.values():
            if word.cfa == args.alloftype:
                word.z80()
                print()
    else:
        word = None
        if args.check:
            for word in words.values():
                if word.lfa not in words:
                    print('Warning: LFA not found: {} -- {}'.format(word.lfa, word))

            for word in links.values():
                if word.label not in links:
                    print('Warning: No link to label found: {} -- {}'.format(word.label, word))

        #    print({cfa: len(list(values)) for cfa, values in itertools.groupby(sorted(cfas))})
        elif args.word:
            word = words_by_name[args.word]
        elif args.label:
            word = words_by_label[args.label]
        if word is not None:
            print(word)
            if args.edit:
                subprocess.check_call(['emacsclient', '-n', '+{}'.format(word.line_number + 1), word.filename])

            if args.z80:
                word.z80()


if __name__ == "__main__":
    main()
