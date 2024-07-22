#!/bin/bash
cd ${MESON_SOURCE_ROOT}

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
# list .c files in $DIR and not in subdirectories
#
######################

DIR="$1"
ls -1 "$DIR"/*.c 2>/dev/null
