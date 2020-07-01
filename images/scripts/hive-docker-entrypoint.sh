#!/usr/bin/env bash

set -e

# shellcheck disable=SC1090
source "${INSTALL_ROOT}/common.sh"
# shellcheck disable=SC1090
source "${HIVE_HOME}/.bashrc"

function initialize_hive() {
  if ! "${HIVE_HOME}/bin/schematool" -dbType postgres -info; then
    echo 'Initializing Hive'
    "${HIVE_HOME}/bin/schematool" -dbType postgres -initSchema
  fi
}


case "${HIVE_ROLE}" in
  metastore)
    # wait for PostgreSQL to become ready
    wait_for db 5432
    initialize_hive
    blue 'Starting Hive metastore'
    exec "${HIVE_HOME}/bin/hive" --service metastore
    ;;
  server)
    blue 'Starting hiveserver2'
    exec "${HIVE_HOME}/bin/hive" --service hiveserver2 --hiveconf hive.root.logger=INFO,console
    ;;
  *)
    abort "Unsupported role ${HIVE_ROLE}"
    ;;
esac
