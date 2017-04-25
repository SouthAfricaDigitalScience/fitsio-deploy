#!/bin/bash -e
# FITSIO check-build script
. /etc/profile.d/modules.sh
module add ci
module add bzip2

echo ""
cd ${WORKSPACE}/${NAME}
make testprog
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

echo "astromdules environment variable is : "${ASTROMODULES}
echo $LD_LIBRARY_PATH
mkdir -p astronomy/${NAME}
cp modules/${VERSION} astronomy/${NAME}
module avail ${NAME}
module add astronomy/${NAME}/${VERSION}

echo "checking the installed version"
echo "test program should be sitting in " ${WORKSPACE}/${NAME} 
ls ${WORKSPACE}/$NAME}
which ${WORKSPACE}/{$NAME}/testprog
ldd ${WORKSPACE}/{$NAME}/testprog
${WORKSPACE}/{$NAME}/testprog
