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
# Makes binary_c's compile_commands.json
#
######################

cd ${MESON_SOURCE_ROOT}

JSON="compile_commands.json"

# copy the compile_commands.json file to the MESON_SOURCE_ROOT
# directory, and replace the relative file path .. with the
# absolute file path so that emacs works

# make a backslashified version of MESON_SOURCE_ROOT
TARGET=`echo ${MESON_SOURCE_ROOT} | sed -e 's/\//\\\\\//g'`

# thus replace ../ with the full path
CMD="cat ${MESON_BUILD_ROOT}/${JSON}  | sed 's/\.\./"$TARGET"/g'"
eval $CMD > ${MESON_SOURCE_ROOT}/${JSON} || exit 1
