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
# script to output the binary_c git revision
# (outputs nothing on failure)
#
######################
git status 2>/dev/null >/dev/null
GIT=$?
if [ $GIT == 0 ]; then
    # revision count
    c=$(git rev-list --full-history --all --abbrev-commit 2>/dev/null | /usr/bin/wc -l | sed -e 's/^ *//')
    # date
    d=$(date +%Y%m%d 2>/dev/null)
    # short revision hash
    # this is HEAD
    #h=$(git rev-parse --short HEAD)
    # this is the latest commit on this checkout
    h=$(git rev-list -n 1 --abbrev-commit HEAD 2>/dev/null)
    # this is the latest *on the repository* but may not affect this build
    # so we don't use it
    #h=$(git rev-list -n 1 --abbrev-commit HEAD 2>/dev/null)
    if [[  ! -z "$d" && ! -z "$c" && ! -z "$h" ]]; then
        echo "${c}:${d}:${h}"
    fi
fi
