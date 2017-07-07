#!/bin/sh

sed -i 's/\.WORD/dw/g;s/\.BYTE/db/g;s/^\([^       ;:]\+\)\([       ]\)/\1:\2/' $1
