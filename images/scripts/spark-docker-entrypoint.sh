#!/usr/bin/env bash

# shellcheck disable=SC1090
source "${INSTALL_ROOT}/common.sh"
# shellcheck disable=SC1090
source "${SPARK_HOME}/.bashrc"

function finish() {
    blue "Shutting down spark container"
}
trap finish EXIT

case "${SPARK_ROLE}" in
  master)
    blue 'Starting Spark master'
    exec "${SPARK_HOME}/bin/spark-class" org.apache.spark.deploy.master.Master
    ;;
  worker)
    blue 'Starting Spark worker'
    exec "${SPARK_HOME}/bin/spark-class" org.apache.spark.deploy.worker.Worker "${SPARK_MASTER_HOST:-spark-master}:${SPARK_MASTER_PORT:-7077}"
    ;;
  edge)
    blue 'Starting edge spark node'
    sleep infinity
    ;;
  *)
    abort "Unsupported role ${SPARK_ROLE}"
    ;;
esac


