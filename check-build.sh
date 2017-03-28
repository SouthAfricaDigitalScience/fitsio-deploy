#!/bin/bash -e
# FITSIO check-build script
. /etc/profile.d/modules.sh
module add ci
module add bzip2
echo ""
cd ${WORKSPACE}/${NAME}
# disabling make check since this puts a huge load on the machines
# see http://stackoverflow.com/questions/23734729/open-mpi-virtual-timer-expired
echo $?

make install

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

mkdir -p ${ASTRO_MODULES}/${NAME}
cp modules/${VERSION} ${ASTRO_MODULES}/${NAME}

module avail
module add ${ASTRO_MODULES}/${NAME}/${VERSION}
make testprog
./testprog
