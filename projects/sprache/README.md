# Sprache

Sprache is a simple, lightweight library for constructing parsers directly in C# code.

## Build Docker

    $ sudo docker build -t oss-sydr-fuzz-sprache .

## Run Fuzzing

Unzip Sydr (`sydr.zip`) in `projects/sprache` directory:

    $ unzip sydr.zip

Run docker:

    $ sudo docker run --privileged --network host -v /etc/localtime:/etc/localtime:ro --rm -it -v $PWD:/fuzz oss-sydr-fuzz-sprache /bin/bash

Change directory to `/fuzz`:

    # cd /fuzz

Run fuzzing with afl++:

    # sydr-fuzz -c parse_xml.toml run

Minimize corpus:

    # sydr-fuzz -c parse_xml.toml cmin

Collect coverage:

    # sydr-fuzz -c parse_xml.toml cov-html

Alternative targets:

    # parse_csv.toml
