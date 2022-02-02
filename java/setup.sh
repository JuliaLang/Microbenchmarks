#!/bin/sh
# This file was formerly a part of Julia. License is MIT: https://julialang.org/license

# this enables java assertions
export MAVEN_OPTS="-ea"
mvn compile exec:java
# requires maven and java 7
