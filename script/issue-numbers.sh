#!/usr/bin/env bash

git log | ruby -ne '$_ =~ /(\[#\d+\])/ and puts $1' | sort -r | uniq

