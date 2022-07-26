#!/bin/bash
#
# SPDX-FileCopyrightText: © 2022 Steffen A. Mork
# SPDX-License-Identifier: MIT
#

PACKAGE=kvm-hostcreator
BUILD=$PWD/target
BUILD_NUMBER=${BUILD_NUMBER:=0}

mkdir -p ${BUILD}
rm -f *.deb
umask 022

set -e

rsync -a rootfs/  ${BUILD}/
sed -i\
   -e "s/%BUILD%/${BUILD_NUMBER}/g"\
   ${BUILD}/DEBIAN/control

mkdir -p          ${BUILD}/usr/share/doc/${PACKAGE}/
cp -a README.md   ${BUILD}/usr/share/doc/${PACKAGE}/
cp -a LICENSE.md  ${BUILD}/usr/share/doc/${PACKAGE}/copyright

VERSION=`grep Version ${BUILD}/DEBIAN/control | cut -d" " -f2`
fakeroot dpkg -b ${BUILD} ${PACKAGE}_${VERSION}_all.deb

rm -rf ${BUILD}
