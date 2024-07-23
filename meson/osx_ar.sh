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
# wrapper for ar on OSX to prevent spurious warnings
# from ar, e.g. 'has no symbols' and 'the table of contents is empty'
#
# Note: the arguments passed in should be
# 1) the ar command (e.g. "ar", "gcc-ar" or "llvm-ar")
# 2) the rest of the command
#
######################
$@ 2> >(ggrep -v 'has no symbols'| ggrep -v 'the table of contents is empty' >&2)
