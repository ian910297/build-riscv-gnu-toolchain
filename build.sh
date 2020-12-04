#!/bin/bash

# Parameter
# $1: build-dir (must)
# $2: source-dir (must)
# $3: install-dir

# How to run?
if [ $# -lt 3 ]; then
  echo "<Usage>: $0 build-dir source-dir install-dir"
  exit 1
fi

# To set build-dir, source-dir
BUILD_DIR=`readlink -f $1`
SOURCE_DIR=`readlink -f $2`
INSTALL_DIR=`readlink -f $3`

# clean build/source folder
rm -rf $BUILD_DIR

mkdir -p $BUILD_DIR/build-gcc
mkdir -p $BUILD_DIR/build-newlib-cygwin
mkdir -p $BUILD_DIR/build-binutils-gdb

# normal build
#
#$SOURCE_DIR/configure \
  #          --prefix=/NOBACKUP/atcsqa06/ianchi/gitPro/install_test \
  #          --disable-gdb

# build newlib
cd $BUILD_DIR/build-newlib-cygwin
$SOURCE_DIR/newlib-cygwin/configure \
  --target=riscv64-unknown-elf \
  --prefix=$INSTALL_DIR \
  --enable-newlib-io-long-double \
  --enable-newlib-io-long-long \
  --enable-newlib-io-c99-formats \
  --enable-newlib-register-fini \
  CFLAGS_FOR_TARGET='-O2 -D_POSIX_MODE -mcmodel=medlow' \
  CXXFLAGS_FOR_TARGET='-O2 -D_POSIX_MODE -mcmodel=medlow' \
  target_alias=riscv64-unknown-elf
make -j16
make install

# build binutils-gdb
cd $BUILD_DIR/build-binutils-gdb
$SOURCE_DIR/configure --target=riscv64-unknown-elf \
  --prefix=$INSTALL_DIR
make -j16
make install

# build gcc
# note that: you must need sysroot, which contains newlib
cd $BUILD_DIR/build-gcc
$SOURCE_DIR/gcc/configure --target=riscv64-unknown-elf \
  --prefix=/NOBACKUP/atcsqa06/ianchi/gitPro/install_test \
  --disable-shared \
  --disable-threads \
  --with-system-zlib \
  --enable-tls \
  --with-newlib \
  --with-sysroot=/NOBACKUP/atcsqa06/ianchi/gitPro/install_test/riscv64-unknown-elf \
  --with-native-system-header-dir=/include \
  --disable-libmudflap \
  --disable-libssp \
  --disable-libquadmath \
  --disable-libgomp \
  --disable-nls \
  --disable-tm-clone-registry \
  --src=$SOURCE_DIR \
  --disable-multilib \
  --with-abi=lp64d \
  --with-arch=rv64imafdc \
  --with-tune=rocket \
  CFLAGS_FOR_TARGET='-Os -mcmodel=medlow' \
  CXXFLAGS_FOR_TARGET='-Os -mcmodel=medlow' \
  target_alias=riscv64-unknown-elf \
  --enable-languages=c,c++,lto

make -j16
make install
exit

