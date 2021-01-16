#!/bin/sh

export XBR_PROTOCOL_VERSION=`grep '"version":' ./package.json -m1 | cut -d\" -f4`
export XBR_PROTOCOL_BUILD_DATE=`date --utc "+%Y%m%d"`
export XBR_PROTOCOL_VCS_REF=`git --git-dir="./.git" rev-list -n 1 v${XBR_PROTOCOL_VERSION} --abbrev-commit`
export XBR_PROTOCOL_BUILD_ID="${XBR_PROTOCOL_VERSION}-${XBR_PROTOCOL_BUILD_DATE}-${XBR_PROTOCOL_VCS_REF}"

echo "The XBR Protocol build environment:"
echo ""
echo "  XBR_PROTOCOL_VERSION    = ${XBR_PROTOCOL_VERSION}"
echo "  XBR_PROTOCOL_BUILD_DATE = ${XBR_PROTOCOL_BUILD_DATE}"
echo "  XBR_PROTOCOL_VCS_REF    = ${XBR_PROTOCOL_VCS_REF}"
echo "  XBR_PROTOCOL_BUILD_ID   = ${XBR_PROTOCOL_BUILD_ID}"
echo ""
