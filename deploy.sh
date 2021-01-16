#!/bin/bash

set +o verbose -o errexit

# XBR_PROTOCOL_VERSION      : must be set in travis.yml!
# XBR_PROTOCOL_VCS_REF      : must be set in travis.yml!
export AWS_DEFAULT_REGION=eu-central-1
export AWS_S3_BUCKET_NAME=xbr.foundation
# AWS_ACCESS_KEY_ID         : must be set in Travis CI build context!
# AWS_SECRET_ACCESS_KEY     : must be set in Travis CI build context!
# WAMP_PRIVATE_KEY          : must be set in Travis CI build context!

echo 'AWS env vars (should be 4):'
env | grep AWS_ | wc -l

echo 'WAMP_PRIVATE_KEY env var (should be 1):'
env | grep WAMP_PRIVATE_KEY | wc -l

# set up awscli package
echo 'installing aws tools ..'
pip install awscli tox
which aws
aws --version

# compile XBR smart contracts and build ABI files
echo 'building contracts ABI bundle ..'

tox -c tox.ini -e truffle-build
cd ./build/contracts/ && zip ../../xbr-protocol-${XBR_PROTOCOL_VERSION}-${XBR_PROTOCOL_VCS_REF}.zip *.json && cd ../..

# upload to S3 bucket
echo 'uploading contracts ABI bundle ..'

# "aws s3 ls" will return -1 when no files are found! but we don't want our script to exit
aws s3 ls ${AWS_S3_BUCKET_NAME}/lib/abi/ || true

aws s3 rm s3://${AWS_S3_BUCKET_NAME}/lib/abi/xbr-protocol-${XBR_PROTOCOL_VERSION}-${XBR_PROTOCOL_VCS_REF}.zip || true
aws s3 rm s3://${AWS_S3_BUCKET_NAME}/lib/abi/xbr-protocol-${XBR_PROTOCOL_VERSION}.zip || true
aws s3 rm s3://${AWS_S3_BUCKET_NAME}/lib/abi/xbr-protocol-latest.zip || true

aws s3 cp --acl public-read ./xbr-protocol-${XBR_PROTOCOL_VERSION}.zip s3://${AWS_S3_BUCKET_NAME}/lib/abi/xbr-protocol-${XBR_PROTOCOL_VERSION}-${XBR_PROTOCOL_VCS_REF}.zip
aws s3 cp --acl public-read ./xbr-protocol-${XBR_PROTOCOL_VERSION}.zip s3://${AWS_S3_BUCKET_NAME}/lib/abi/xbr-protocol-${XBR_PROTOCOL_VERSION}.zip
aws s3 cp --acl public-read ./xbr-protocol-${XBR_PROTOCOL_VERSION}.zip s3://${AWS_S3_BUCKET_NAME}/lib/abi/xbr-protocol-latest.zip

aws s3 ls ${AWS_S3_BUCKET_NAME}/lib/abi/

echo 'package uploaded to:'
echo ''
echo '      https://s3.eu-central-1.amazonaws.com/xbr.network/lib/abi/xbr-protocol-latest.zip'
echo '      https://s3.eu-central-1.amazonaws.com/xbr.network/lib/abi/xbr-protocol-'${XBR_PROTOCOL_VERSION}'.zip'
echo '      https://s3.eu-central-1.amazonaws.com/xbr.network/lib/abi/xbr-protocol-'${XBR_PROTOCOL_VERSION}-${XBR_PROTOCOL_VCS_REF}'.zip'
echo '      https://xbr.network/lib/abi/xbr-protocol-latest.zip'
echo '      https://xbr.network/lib/abi/xbr-protocol-'${XBR_PROTOCOL_VERSION}'.zip'
echo '      https://xbr.network/lib/abi/xbr-protocol-'${XBR_PROTOCOL_VERSION}-${XBR_PROTOCOL_VCS_REF}'.zip'
echo ''

echo 'notify crossbar-builder ..'

# tell crossbar-builder about this new wheel push
# get 'wamp' command, always with latest autobahn master
pip install -q -I https://github.com/crossbario/autobahn-python/archive/master.zip#egg=autobahn[twisted,serialization,encryption]

# use 'wamp' to notify crossbar-builder
wamp --max-failures 3 \
     --authid wheel_pusher \
     --url ws://office2dmz.crossbario.com:8008/ \
     --realm webhook call builder.wheel_pushed \
     --keyword name xbr-protocol \
     --keyword publish true

echo 'building docs ..'
tox -c tox.ini -e sphinx

echo 'publishing docs ..'
aws s3 cp --recursive --acl public-read ./docs/_build s3://${AWS_S3_BUCKET_NAME}/docs
aws cloudfront create-invalidation --distribution-id EVZPVW5R6WNNF --paths "/*"

echo 'docs uploaded to:'
echo ''
echo '      https://s3.eu-central-1.amazonaws.com/xbr.network/docs/index.html'
echo '      https://xbr.network/docs/index.html'
echo ''
