#!/bin/bash

set +o verbose -o errexit

# The following env vars must be set in the enclosing CI:
#
# XBR_PROTOCOL_BUILD_DATE
# XBR_PROTOCOL_VCS_REF
# XBR_PROTOCOL_BUILD_ID
# XBR_PROTOCOL_VERSION
#
# AWS_DEFAULT_REGION
# AWS_S3_BUCKET_NAME
# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY
#
# WAMP_PRIVATE_KEY

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
cd ./build/contracts/ && zip ../../xbr-protocol-${XBR_PROTOCOL_BUILD_ID}.zip *.json && cd ../..
ls -la ./*.zip

# upload to S3 bucket
echo 'uploading contracts ABI bundle ..'

# "aws s3 ls" will return -1 when no files are found! but we don't want our script to exit
aws s3 ls $AWS_S3_BUCKET_NAME/lib/abi/ || true

aws s3 rm s3://$AWS_S3_BUCKET_NAME/lib/abi/xbr-protocol-${XBR_PROTOCOL_BUILD_ID}.zip || true
aws s3 rm s3://$AWS_S3_BUCKET_NAME/lib/abi/xbr-protocol-${XBR_PROTOCOL_VERSION}.zip || true
aws s3 rm s3://$AWS_S3_BUCKET_NAME/lib/abi/xbr-protocol-latest.zip || true

aws s3 cp --acl public-read ./xbr-protocol-${XBR_PROTOCOL_BUILD_ID}.zip s3://$AWS_S3_BUCKET_NAME/lib/abi/xbr-protocol-${XBR_PROTOCOL_BUILD_ID}.zip
aws s3 cp --acl public-read ./xbr-protocol-${XBR_PROTOCOL_BUILD_ID}.zip s3://$AWS_S3_BUCKET_NAME/lib/abi/xbr-protocol-${XBR_PROTOCOL_VERSION}.zip
aws s3 cp --acl public-read ./xbr-protocol-${XBR_PROTOCOL_BUILD_ID}.zip s3://$AWS_S3_BUCKET_NAME/lib/abi/xbr-protocol-latest.zip

aws s3 ls $AWS_S3_BUCKET_NAME/lib/abi/

# build python source dist and wheels
echo 'building contracts Python package ..'
make compile
python setup.py sdist bdist_wheel --universal
ls -la ./dist

# upload to S3: https://s3.eu-central-1.amazonaws.com/crossbarbuilder/wheels/
echo 'uploading contracts Python package ..'
# "aws s3 ls" will return -1 when no files are found! but we don't want our script to exit
aws s3 ls ${AWS_S3_BUCKET_NAME}/wheels/xbr- || true

# aws s3 cp --recursive ./dist s3://${AWS_S3_BUCKET_NAME}/wheels
aws s3 rm s3://${AWS_S3_BUCKET_NAME}/wheels/xbr-${XBR_PROTOCOL_VERSION}-py2.py3-none-any.whl
aws s3 rm s3://${AWS_S3_BUCKET_NAME}/wheels/xbr-latest-py2.py3-none-any.whl

aws s3 cp --acl public-read ./dist/xbr-${XBR_PROTOCOL_VERSION}-py2.py3-none-any.whl s3://${AWS_S3_BUCKET_NAME}/wheels/xbr-${XBR_PROTOCOL_VERSION}-py2.py3-none-any.whl
aws s3 cp --acl public-read ./dist/xbr-${XBR_PROTOCOL_VERSION}-py2.py3-none-any.whl s3://${AWS_S3_BUCKET_NAME}/wheels/xbr-latest-py2.py3-none-any.whl

aws s3 ls ${AWS_S3_BUCKET_NAME}/wheels/xbr-

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
aws s3 cp --recursive --acl public-read ./docs/_build s3://$AWS_S3_BUCKET_NAME/docs
aws cloudfront create-invalidation --distribution-id EVZPVW5R6WNNF --paths "/*"

echo ''
echo 'SUMMARY:'
echo '========'
echo ''
echo 'ABI bundle uploaded to:'
echo ''
echo '      https://s3.$AWS_DEFAULT_REGION.amazonaws.com/$AWS_S3_BUCKET_NAME/lib/abi/xbr-protocol-latest.zip'
echo '      https://s3.$AWS_DEFAULT_REGION.amazonaws.com/$AWS_S3_BUCKET_NAME/lib/abi/xbr-protocol-'${XBR_PROTOCOL_VERSION}'.zip'
echo '      https://s3.$AWS_DEFAULT_REGION.amazonaws.com/$AWS_S3_BUCKET_NAME/lib/abi/xbr-protocol-'${XBR_PROTOCOL_BUILD_ID}'.zip'
echo ''
echo '      https://xbr.network/lib/abi/xbr-protocol-latest.zip'
echo '      https://xbr.network/lib/abi/xbr-protocol-'${XBR_PROTOCOL_VERSION}'.zip'
echo '      https://xbr.network/lib/abi/xbr-protocol-'${XBR_PROTOCOL_BUILD_ID}'.zip'
echo ''
echo 'Python package uploaded to:'
echo ''
echo '      https://crossbarbuilder.s3.eu-central-1.amazonaws.com/wheels/xbr-latest-py2.py3-none-any.whl'
echo '      https://crossbarbuilder.s3.eu-central-1.amazonaws.com/wheels/xbr-'${XBR_PROTOCOL_VERSION}'-py2.py3-none-any.whl'
echo ''
echo 'Docs uploaded to:'
echo ''
echo '      https://s3.$AWS_DEFAULT_REGION.amazonaws.com/$AWS_S3_BUCKET_NAME/docs/index.html'
echo '      https://xbr.network/docs/index.html'
echo ''
