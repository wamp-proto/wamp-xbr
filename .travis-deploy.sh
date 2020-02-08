#!/bin/bash

# build docs/website and upload to "xbr.network" S3 bucket

export AWS_DEFAULT_REGION=eu-central-1
export AWS_S3_BUCKET_NAME=xbr.network
# AWS_ACCESS_KEY_ID         : must be set in Travis CI build context
# AWS_SECRET_ACCESS_KEY     : must be set in Travis CI build context

set -ev

# TRAVIS_BRANCH, TRAVIS_PULL_REQUEST, TRAVIS_TAG

# PR => don't deploy and exit
if [ "$TRAVIS_PULL_REQUEST" = "true" ]; then
    echo '[1] deploy script called for PR - exiting ..';
    exit 0;

# direct push to master => deploy
elif [ "$TRAVIS_BRANCH" = "master" -a "$TRAVIS_PULL_REQUEST" = "false" ]; then
    echo '[2] deploy script called for direct push to master: continuing to deploy!';

# tagged release => deploy
elif [ -n "$TRAVIS_TAG" ]; then
    echo '[3] deploy script called for tagged release: continuing to deploy!';

# outside travis? => deploy
else
    echo '[?] deploy script called outside Travis? continuing to deploy!';

fi

# only show number of env vars .. should be 4 on master branch!
# https://docs.travis-ci.com/user/pull-requests/#Pull-Requests-and-Security-Restrictions
# Travis CI makes encrypted variables and data available only to pull requests coming from the same repository.
echo 'aws env vars (should be 4 - but only on master branch!):'
env | grep AWS | wc -l

# set up awscli package
echo 'installing aws tools ..'
pip install awscli
which aws
aws --version
aws s3 ls ${AWS_S3_BUCKET_NAME}

# deploy latest XBR Lib ABIs:
#   => https://s3.eu-central-1.amazonaws.com/xbr.network/lib/abi/
#   => https://xbr.network/lib/abi/
tox -c tox.ini -e truffle-build
aws s3 cp --recursive --acl public-read --include "*.json" ./build/contracts s3://${AWS_S3_BUCKET_NAME}/lib/abi/

# deploy latest XBR Lib for JS:
#   => https://s3.eu-central-1.amazonaws.com/xbr.network/lib/js/
#   => https://xbr.network/lib/js/
tox -c tox.ini -e xbr-js
aws s3 cp --acl public-read ./build/xbr.js      s3://${AWS_S3_BUCKET_NAME}/lib/js/
aws s3 cp --acl public-read ./build/xbr.min.js  s3://${AWS_S3_BUCKET_NAME}/lib/js/
aws s3 cp --acl public-read ./build/xbr.min.jgz s3://${AWS_S3_BUCKET_NAME}/lib/js/

# deploy latest XBR Lib for Python:
# https://www.python.org/dev/peps/pep-0503/
# https://packaging.python.org/guides/hosting-your-own-index/
# tox -c tox.ini -e xbr-python

#   => https://s3.eu-central-1.amazonaws.com/xbr.network/lib/python/xbr/
#   => https://xbr.network/lib/python/xbr/
# aws s3 cp --recursive --acl public-read ./dist s3://${AWS_S3_BUCKET_NAME}/lib/python/xbr/

#   => https://s3.eu-central-1.amazonaws.com/crossbarbuilder/wheels/
# aws s3 cp --recursive ./dist s3://crossbarbuilder/wheels

# deploy latest docs:
#   => https://s3.eu-central-1.amazonaws.com/xbr.network/docs/index.html
#   => https://xbr.network/docs/index.html
tox -c tox.ini -e sphinx
aws s3 cp --recursive --acl public-read ./docs/_build s3://${AWS_S3_BUCKET_NAME}/docs

# invalidate cloudfront distribution:
#   => https://xbr.network/index.html
aws cloudfront create-invalidation --distribution-id EVZPVW5R6WNNF --paths "/*"
