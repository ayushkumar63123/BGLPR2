#!/usr/bin/env bash
#
# Copyright (c) 2018-2020 The Bitcoin Core developers
# Distributed under the MIT software license, see the accompanying
# file COPYING or http://www.opensource.org/licenses/mit-license.php.

export LC_ALL=C.UTF-8

# Make sure default datadir does not exist and is never read by creating a dummy file
if [[ $HOST == *-apple-* ]]; then
  echo > $HOME/Library/Application\ Support/BGL
else
  DOCKER_EXEC echo \> \$HOME/.BGL
fi

DOCKER_EXEC mkdir -p ${DEPENDS_DIR}/SDKs ${DEPENDS_DIR}/sdk-sources

#if [[ ${USE_MEMORY_SANITIZER} == "true" ]]; then
#  # Use BDB compiled using install_db4.sh script to work around linking issue when using BDB
#  # from depends. See https://github.com/bitcoin/bitcoin/pull/18288#discussion_r433189350 for
#  # details.
#  DOCKER_EXEC "contrib/install_db4.sh \$(pwd) --enable-umrw CC=clang CXX=clang++ CFLAGS='${MSAN_FLAGS}' CXXFLAGS='${MSAN_AND_LIBCXX_FLAGS}'"
#fi

if [[ $HOST == *-mingw32 ]]; then
  DOCKER_EXEC update-alternatives --set $HOST-g++ \$\(which $HOST-g++-posix\)
fi
if [ -z "$NO_DEPENDS" ]; then
  if [[ $DOCKER_NAME_TAG == centos* ]]; then
    # CentOS has problems building the depends if the config shell is not explicitly set
    # (i.e. for libevent a Makefile with an empty SHELL variable is generated, leading to
    #  an error as the first command is executed)
    SHELL_OPTS="LC_ALL=en_US.UTF-8 CONFIG_SHELL=/bin/bash"
  else
    SHELL_OPTS="CONFIG_SHELL="
  fi
  DOCKER_EXEC $SHELL_OPTS make $MAKEJOBS -C depends HOST=$HOST $DEP_OPTS
fi
