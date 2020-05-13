#!/sbin/sh
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Treble-lizer script for a3y17lte
# Written by @Astrako


DISK=/dev/block/mmcblk0
VENDOR=/dev/block/bootdevice/by-name/VENDOR
SGDISK=./tmp/sgdisk
SIZE=312

if [ ! -h $VENDOR ];then
    SYSPARTNUM=`${SGDISK} --pretend --print ${DISK} | grep SYSTEM | awk '{printf $1}'`
    SYSSTART=`${SGDISK} --pretend --print ${DISK} | grep SYSTEM | awk '{printf $2}'`
    SYSEND=`${SGDISK} --pretend --print ${DISK} | grep SYSTEM | awk '{printf $3}'`
    CACHEPARTNUM=`${SGDISK} --pretend --print ${DISK} | grep CACHE | awk '{printf $1}'`
    CACHESTART=`${SGDISK} --pretend --print ${DISK} | grep CACHE | awk '{printf $2}'`
    CACHEEND=`${SGDISK} --pretend --print ${DISK} | grep CACHE | awk '{printf $3}'`
    HIDDENPARTNUM=`${SGDISK} --pretend --print ${DISK} | grep HIDDEN | awk '{printf $1}'`
    HIDDENSTART=`${SGDISK} --pretend --print ${DISK} | grep HIDDEN | awk '{printf $2}'`
    HIDDENEND=`${SGDISK} --pretend --print ${DISK} | grep HIDDEN | awk '{printf $3}'`
    SECSIZE=`${SGDISK} --pretend --print ${DISK} | grep 'sector size' | awk '{printf $4}'`
    SYSCODE=`${SGDISK} --pretend --print ${DISK} | grep SYSTEM | awk '{printf $6}'`
    VENDORSIZE=`echo "${SIZE} 1024 * 1024 * ${SECSIZE} / p" | dc`
    NEWEND=`echo "${SYSEND} ${VENDORSIZE} - p" | dc`
    VENDORSTART=`echo "${NEWEND} 1 + p" | dc`

    ${SGDISK} --delete=${SYSPARTNUM} --new=${SYSPARTNUM}:${SYSSTART}:${NEWEND} --typecode=${SYSPARTNUM}:${SYSCODE} --change-name=${SYSPARTNUM}:SYSTEM ${DISK}
    ${SGDISK} --delete=${CACHEPARTNUM} --new=${CACHEPARTNUM}:${VENDORSTART}:${CACHEEND} --typecode=${CACHEPARTNUM}:${SYSCODE} --change-name=${CACHEPARTNUM}:VENDOR ${DISK}
    ${SGDISK} --delete=${HIDDENPARTNUM} --new=${HIDDENPARTNUM}:${HIDDENSTART}:${HIDDENEND} --typecode=${HIDDENPARTNUM}:${SYSCODE} --change-name=${HIDDENPARTNUM}:CACHE ${DISK}

fi
