#!/bin/bash

PACKAGE=kvm-hostcreator
BUILD=/tmp/${PACKAGE}
BUILD_NUMBER=${BUILD_NUMBER:=0}

mkdir -p ${BUILD}
rm -f *.deb
umask 022

set -e

mkdir -p ${BUILD}/DEBIAN
sed -e "s/%BUILD%/${BUILD_NUMBER}/g" DEBIAN/control > ${BUILD}/DEBIAN/control
cp -a DEBIAN/postinst ${BUILD}/DEBIAN
cp -a DEBIAN/conffiles ${BUILD}/DEBIAN
rsync -a root  ${BUILD}
find ${BUILD} -type d -name .svn | xargs rm -rf

VERSION=`grep Version ${BUILD}/DEBIAN/control | cut -d" " -f2`
fakeroot dpkg -b ${BUILD} ${PACKAGE}_${VERSION}.deb

rm -rf ${BUILD}
