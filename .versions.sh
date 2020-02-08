#!/bin/sh

export XBR_PROTOCOL_VERSION=$(grep '"version":' ./package.json -m1 | cut -d\" -f4)
export XBR_PROTOCOL_VCS_REF=`git --git-dir="./.git" rev-list -n 1 v${XBR_PROTOCOL_VERSION} --abbrev-commit`
export BUILD_DATE=`date -u +"%Y-%m-%d"`

echo ""
echo "The XBR Protocol build environment:"
echo ""
echo "  XBR_PROTOCOL_VERSION = ${XBR_PROTOCOL_VERSION}"
echo "  XBR_PROTOCOL_VCS_REF = ${XBR_PROTOCOL_VCS_REF}"
echo "  BUILD_DATE           = ${BUILD_DATE}"
echo ""
