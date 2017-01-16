#!/bin/bash -e
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
--enable-reentrant \
--prefix=${SOFT_DIR} \
--with-bzip2=${BZLIB_DIR}/include


make install
make shared
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
setenv       CFITSIO_DIR       $::env(CVMFS_DIR)/$::env(SITE)/$::env(OS)/$::env(ARCH)/${NAME}/${VERSION}
prepend-path LD_LIBRARY_PATH   $::env(CFITSIO_DIR)/lib
prepend-path PATH              $::env(CFITSIO_DIR)/bin
prepend-path CFITSIO_INCLUDE_DIR   $::env(CFITSIO_DIR)/include
prepend-path CPATH             $::env(CFITSIO_DIR)/include
MODULE_FILE
) > modules/${VERSION}

mkdir -p ${ASTRO_MODULES}/${NAME}
cp modules/${VERSION} ${ASTRO_MODULES}/${NAME}
