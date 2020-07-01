#!/bin/bash

set -e

# shellcheck disable=SC1090
source "${INSTALL_ROOT}/common.sh"

install_hadoop() {
  local archive_path
  archive_path="${INSTALL_ROOT}/hadoop-${HADOOP_VERSION}.tar.gz"
  local signature_path
  signature_path="${archive_path}.mds"
  if [ ! -f "$archive_path" ]; then
    # download files from Apache
    download_file "https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz" "${archive_path}"
    download_file "https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz.mds" "${signature_path}"

    # verify downloaded binary
    expected=$(sed -ne '/SHA512/,$ {s/.*SHA512 = //I; p; }' "${signature_path}")
    actual=$(get_digest_from_file sha512 "${archive_path}")
    assert_signature "${expected}" "${actual}"
  else
    yellow "Custom-built artifact found, skipping download.."
  fi

  # deploy Hadoop
  blue "Installing Hadoop ${HADOOP_VERSION}"
  sudo -u "${HADOOP_USER}" tar -xzf "$archive_path" -C "${INSTALL_ROOT}" --no-same-owner --exclude="hadoop-${HADOOP_VERSION}/share/doc"
  sudo -u "${HADOOP_USER}" ln -sf "${INSTALL_ROOT}/hadoop-${HADOOP_VERSION}" "${HADOOP_HOME}"
  echo "export JAVA_HOME=${JAVA_HOME}" >> "${HADOOP_CONF_DIR}/hadoop-env.sh"
  # shellcheck disable=SC2016
  echo 'PATH=$PATH:${HADOOP_HOME}/bin' >> "${INSTALL_ROOT}/.bashrc"

  # libraries for using s3a connector
  download_file "https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/${HADOOP_VERSION}/hadoop-aws-${HADOOP_VERSION}.jar" "${HADOOP_HOME}/share/hadoop/common/hadoop-aws.jar"
  download_file "https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/${AWS_JAVA_SDK_VERSION}/aws-java-sdk-bundle-${AWS_JAVA_SDK_VERSION}.jar" "${HADOOP_HOME}/share/hadoop/common/aws-java-sdk-bundle.jar"

  # Clean up
  blue "Cleaning up Hadoop artifacts"
  rm -f "$archive_path"
  if [ -f "${signature_path}" ]; then rm -f "${signature_path}"; fi
}

sudo -u hadoop touch "${INSTALL_ROOT}/.bashrc"
install_hadoop


