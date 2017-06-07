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

# FITSIO check-build script
. /etc/profile.d/modules.sh
module add ci
module add bzip2

echo "is libbz2 in our LD_LIBRARY_PATH"
echo $LD_LIBRARY_PATH
echo ""
cd ${WORKSPACE}/${NAME}
echo "making install"
make install
echo "making testprog"
LDFLAGS=${LDFLAGS} make testprog
echo $?

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
setenv       CFITSIO_DIR      /data/ci-build/$::env(SITE)/$::env(OS)/$::env(ARCH)/${NAME}/${VERSION}

prepend-path LD_LIBRARY_PATH   $::env(CFITSIO_DIR)/lib
prepend-path CFITSIO_INCLUDE_DIR   $::env(CFITSIO_DIR)/include
prepend-path PATH              $::env(CFITSIO_DIR)/bin
prepend-path CPATH             $::env(CFITSIO_DIR)/include

MODULE_FILE
) > modules/${VERSION}

echo "astromodules environment variable is : "${ASTRONOMY}

mkdir -p ${ASTRONOMY}/${NAME}
cp modules/${VERSION} ${ASTRONOMY}/${NAME}
module avail ${NAME}
module purge
module add ci
module add bzip2
module add ${NAME}/${VERSION}
echo "LD_LIBRARY_PATH is $LD_LIBRARY_PATH"
echo "checking where testprog is"
which testprog
./testprog
