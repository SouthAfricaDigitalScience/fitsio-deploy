[![Build Status](https://ci.sagrid.ac.za/job/fitsio-deploy/badge/icon)](https://ci.sagrid.ac.za/job/fitsio-deploy)

# fitsio-deploy

Build, test and deploy scripts for [fitsio](http://heasarc.gsfc.nasa.gov/fitsio/).

# Version

Versions built :

  1. 3370
  1. 3410

# Dependencies

  * bzlib

# Configuration

```
./configure \
--enable-sse2 \
--enable-ssse3 \
--prefix=${SOFT_DIR} \
--with-bzip2=${BZLIB_DIR}
```
