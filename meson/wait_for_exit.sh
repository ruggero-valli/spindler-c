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
# wait for the process with ID in the first argument to finish
# then run the rest of the arguments
#
######################

PID=$1
shift
CMD="$@"
{ while ps -p $PID >/dev/null; do sleep 0.1; done ; eval "$CMD";  }&
exit
