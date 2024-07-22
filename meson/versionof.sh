#!/bin/bash

#
# The binary_c stellar population nucleosynthesis framework.
#
# Copyright Robert Izzard 2000-2021
#
# Contact rob.izzard@gmail.com
#
# Code repository:
# https://gitlab.com/binary_c
#
# Documentation is in doc/
# Code is in src/
#
# To build, run
#
# ---
#
# meson builddir
# cd builddir
# ninja binary_c_install
#
# ---
#
# Please see the files README, LICENCE and CHANGES,
# and the doc/ directory for documentation which is mirrored
# at https://binary_c.gitlab.io
#
######################
#
# Purpose:
#
# find the version number of the command in the first
# argument : requires the command and sed
#
######################

CMD=$1
VERSION_ARGS=$2
VCMD="$CMD $VERSION_ARGS"

exists()
{
    command -v "$1" >/dev/null 2>&1
}

if exists perl; then
    # perl regex: most powerful
    echo `$VCMD 2>&1` 2>&1 | perl -ne 'print (/(\d+(?:\.\d+)+)/)'
else
    # less powerful sed regex
    echo `$VCMD 2>&1` 2>&1 | sed -nre 's/^[^0-9]*(([0-9]+\.)*[0-9]+).*/\1/p'
fi
