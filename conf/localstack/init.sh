#!/usr/bin/env bash

set -e
awslocal s3api create-bucket --bucket data --acl public-read-write
