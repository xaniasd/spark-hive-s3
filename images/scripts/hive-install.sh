#!/bin/bash

set -e

# shellcheck disable=SC1090
source "${INSTALL_ROOT}/common.sh"

install_hive() {
  local archive_path
  archive_path="${INSTALL_ROOT}/apache-hive-${HIVE_VERSION}-bin.tar.gz"
  local signature_path
  signature_path="${archive_path}.sha256"
  if [ ! -f "$archive_path" ]; then
    # download files from Apache
    download_file "https://archive.apache.org/dist/hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz" "${archive_path}"
    download_file "https://archive.apache.org/dist/hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz.sha256" "${signature_path}"

    # verify downloaded binary
    expected=$(sed -e 's/ apache-hive.*$//' "${signature_path}")
    actual=$(get_digest_from_file sha256 "${archive_path}")
    assert_signature "${expected}" "${actual}"
  else
    yellow "Custom-built artifact found, skipping download.."
  fi

  # install Hive
  blue "Installing Hive ${HIVE_VERSION}"
  sudo -u "${HIVE_USER}" tar -xzf "$archive_path" -C "${INSTALL_ROOT}" --no-same-owner
  sudo -u "${HIVE_USER}" ln -sf "${INSTALL_ROOT}/apache-hive-${HIVE_VERSION}-bin" "${HIVE_HOME}"
  {
    echo "HIVE_HOME=${HIVE_HOME}"
    echo "HIVE_CONF_DIR=${HIVE_CONF_DIR}"
    echo "HADOOP_HOME=${HADOOP_HOME}"
    echo "HADOOP_CONF_DIR=${HADOOP_CONF_DIR}"
  } >> "${HIVE_HOME}/hive-env.sh"
    # shellcheck disable=SC2016
  echo 'PATH=$PATH:${HIVE_HOME}/bin' >> "${HIVE_HOME}/.bashrc"

  # download PostgreSQL JDBC driver
  download_file "https://jdbc.postgresql.org/download/postgresql-${POSTGRESQL_JDBC_DRIVER_VERSION}.jar" "${HIVE_HOME}/lib/postgresql-jdbc.jar"

  # fix guava version issues
  rm "${HIVE_HOME}/lib/guava-19.0.jar"
  cp "${HADOOP_HOME}/share/hadoop/common/lib/guava-27.0-jre.jar" "${HIVE_HOME}/lib/"

  # Clean up
  blue "Cleaning up Hive artifacts"
  rm -f "$archive_path"
  if [ -f "${signature_path}" ]; then rm -f "${signature_path}"; fi
}

install_hive


