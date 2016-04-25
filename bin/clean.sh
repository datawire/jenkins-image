#!/usr/bin/env bash

rm -rf tmp/*
rm -f bin/packer
rm -f *-variables.json
find . -name .directory -delete
find . -name *.log -delete