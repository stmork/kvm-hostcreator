#!/bin/bash
#
# SPDX-FileCopyrightText: © 2022 Steffen A. Mork
# SPDX-License-Identifier: MIT
#

PACKAGE=kvm-hostcreator
BUILD=$PWD/target
BUILD_NUMBER=${BUILD_NUMBER:=0}
COPYRIGHT=${BUILD}/usr/share/doc/${PACKAGE}/copyright

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

echo "Format: https://www.debian.org/doc/packaging-manuals/copyright-format/1.0/" > $COPYRIGHT
echo "Upstream-Name: $PACKAGE" >> ${COPYRIGHT}
echo "Source: https://github.com/stmork/kvm-hostcreator" >> ${COPYRIGHT}
echo "" >> ${COPYRIGHT}
echo "Files: *" >> ${COPYRIGHT}
echo "Copyright: 2005-`date +'%Y'` (C) Steffen A. Mork" >> ${COPYRIGHT}
echo "License: MIT" >> ${COPYRIGHT}
sed -e 's/^$/\./g' -e 's/^/ /g' LICENSE.md >> ${COPYRIGHT}

VERSION=`grep Version ${BUILD}/DEBIAN/control | cut -d" " -f2`
fakeroot dpkg -b ${BUILD} ${PACKAGE}_${VERSION}_all.deb

rm -rf ${BUILD}
