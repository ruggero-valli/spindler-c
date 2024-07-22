#!/bin/bash

cd ${MESON_SOURCE_ROOT}

#
# The binary_c stellar population nucleosynthesis framework.
#
# Copyright Robert Izzard 2000-2022
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
# after meson has built build.ninja, send the linker
# to our custom osx_ar.sh script which filters
# spurious warnings
#
#
# Note: the first gsed replcaes the ar command
#       (which could be, e.g., 'ar', 'gcc-ar'
#       or 'llvm-ar' or similar) with root/osx_ar.sh which takes
#       the replaced ar command as its first argument.
#
#       the second gsed converts the C compiler to use osx_cc.sh
#
#       These commands filter out spurious warnings during compilation.
######################

cat ${MESON_BUILD_ROOT}/build.ninja \
    | gsed -r 's/([^\s\\]*ar) LINK_ARGS/root\/osx_ar.sh \1 LINK_ARGS/' \
    | gsed ':a;N;$!ba;s|c_LINKER\n command = cc|c_LINKER\n command = '${MESON_SOURCE_ROOT}'/meson/osx_cc.sh|' \
      > ${MESON_BUILD_ROOT}/build.ninja2 && \
    mv ${MESON_BUILD_ROOT}/build.ninja2 ${MESON_BUILD_ROOT}/build.ninja || exit 1

exit 0
