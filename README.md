# Spark local development environment

## Overview

A simple setup for a local development envrironment using Spark and S3. The repository provides
a set of container images with all the required libraries and configuration, as well as a a `docker-compose` file
to deploy the environment.

The scripts create a Spark standalone cluster with a Hive metastore and [localstack](https://github.com/localstack/localstack) as a mock S3 service.
Furthermore, the Spark Master UI is exposed and configured as proxy to access running applications.

## Get started

```bash
# start up environment
docker-compose up --build -d
# run a test script
docker-compose exec spark-edge bash
spark-submit src/test-spark.py
# clean up environment (including volumes)
docker-compose down -v
```
