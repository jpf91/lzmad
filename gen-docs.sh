#!/bin/sh
cd src
dmd ../doc/lzma.ddoc -c -o- -wi -D -Dd../doc/generated/ -Dflzma.html lzma.d
dmd ../doc/lzma.ddoc -c -o- -wi -D -Dd../doc/generated/ -Dflzma_base.html lzma_/base.d
dmd ../doc/lzma.ddoc -c -o- -wi -D -Dd../doc/generated/ -Dflzma_bcj.html lzma_/bcj.d
dmd ../doc/lzma.ddoc -c -o- -wi -D -Dd../doc/generated/ -Dflzma_block.html lzma_/block.d
dmd ../doc/lzma.ddoc -c -o- -wi -D -Dd../doc/generated/ -Dflzma_check.html lzma_/check.d
dmd ../doc/lzma.ddoc -c -o- -wi -D -Dd../doc/generated/ -Dflzma_container.html lzma_/container.d
dmd ../doc/lzma.ddoc -c -o- -wi -D -Dd../doc/generated/ -Dflzma_delta.html lzma_/delta.d
dmd ../doc/lzma.ddoc -c -o- -wi -D -Dd../doc/generated/ -Dflzma_filter.html lzma_/filter.d
dmd ../doc/lzma.ddoc -c -o- -wi -D -Dd../doc/generated/ -Dflzma_hardware.html lzma_/hardware.d
dmd ../doc/lzma.ddoc -c -o- -wi -D -Dd../doc/generated/ -Dflzma_index.html lzma_/index.d
dmd ../doc/lzma.ddoc -c -o- -wi -D -Dd../doc/generated/ -Dflzma_index_hash.html lzma_/index_hash.d
dmd ../doc/lzma.ddoc -c -o- -wi -D -Dd../doc/generated/ -Dflzma_lzma.html lzma_/lzma.d
dmd ../doc/lzma.ddoc -c -o- -wi -D -Dd../doc/generated/ -Dflzma_stream_flags.html lzma_/stream_flags.d
dmd ../doc/lzma.ddoc -c -o- -wi -D -Dd../doc/generated/ -Dflzma_version_.html lzma_/version_.d
dmd ../doc/lzma.ddoc -c -o- -wi -D -Dd../doc/generated/ -Dflzma_vli.html lzma_/vli.d
cd ../
