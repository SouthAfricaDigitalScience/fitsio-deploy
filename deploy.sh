#!/bin/bash -e
# Copyright 2016 C.S.I.R. Meraka Institute
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

. /etc/profile.d/modules.sh
# We provide the base module which all jobs need to get their environment on the build slaves
module add deploy
module add bzip2

# We will be running configure and make in this directory
cd $WORKSPACE/$NAME
make distclean

# Note that $SOFT_DIR is used as the target installation directory.
./configure \
--enable-sse2 \
--enable-ssse3 \
--with-bzip2=${BZLIB_DIR} \
--enable-reentrant \
--prefix=${SOFT_DIR} \

make install
make shared
make install
make testprog
mkdir -p modules
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
    puts stderr "       This module does nothing but alert the user"
    puts stderr "       that the [module-info name] module is not available"
}

module add bzip2
module-whatis   "$NAME $VERSION."
setenv       CFITSIO_VERSION       $VERSION
setenv       CFITSIO_DIR       $::env(CVMFS_DIR)/$::env(SITE)/$::env(OS)/$::env(ARCH)/${NAME}/${VERSION}
prepend-path LD_LIBRARY_PATH   $::env(CFITSIO_DIR)/lib
prepend-path PATH              $::env(CFITSIO_DIR)/bin
prepend-path CFITSIO_INCLUDE_DIR   $::env(CFITSIO_DIR)/include
prepend-path CPATH             $::env(CFITSIO_DIR)/include
MODULE_FILE
) > modules/${VERSION}

mkdir -p ${ASTRONOMY}/${NAME}
cp modules/${VERSION} ${ASTRONOMY}/${NAME}

module avail ${NAME}

module add ${NAME}/${VERSION}
echo "checking testprog"
which testprog
echo "running testprog"
testprog
