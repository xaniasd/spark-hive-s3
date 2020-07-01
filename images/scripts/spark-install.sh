#!/bin/bash

set -e

# shellcheck disable=SC1090
source "${INSTALL_ROOT}/common.sh"

install_spark() {
  local archive_path
  archive_path="${INSTALL_ROOT}/spark-${SPARK_VERSION}-bin-hadoop3.2.tgz"
  local signature_path
  signature_path="${archive_path}.sha512"
  if [ ! -f "${archive_path}" ]; then
    # download files from Apache mirrors
    download_file "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.2.tgz" "${archive_path}"
    download_file "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.2.tgz.sha512" "${signature_path}"

    # verify downloaded binary
    expected=$(sed -e 's/^.*://' "${signature_path}")
    actual=$(get_digest_from_file sha512 "${archive_path}")
    assert_signature "${expected}" "${actual}"
  else
    yellow "Custom-built artifact found, skipping download.."
  fi

  # install Spark
  blue "Deploying Spark ${SPARK_VERSION}"
  sudo -u "${SPARK_USER}" tar -xzf "${archive_path}" -C "${INSTALL_ROOT}" --no-same-owner
  sudo -u "${SPARK_USER}" ln -sf "${INSTALL_ROOT}/spark-${SPARK_VERSION}-bin-hadoop3.2" "${SPARK_HOME}"

  {
    echo "export PYSPARK_PYTHON=/usr/bin/python3"
  } >> "${SPARK_HOME}/spark-env.sh"

  {
    echo "PATH=$PATH:${SPARK_HOME}/bin"
    echo "export PYSPARK_PYTHON=/usr/bin/python3"
  } >> "${SPARK_HOME}/.bashrc"

  download_file "https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/${HADOOP_VERSION}/hadoop-aws-${HADOOP_VERSION}.jar" "${SPARK_HOME}/jars/hadoop-aws.jar"
  download_file "https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/${AWS_JAVA_SDK_VERSION}/aws-java-sdk-bundle-${AWS_JAVA_SDK_VERSION}.jar" "${SPARK_HOME}/jars/aws-java-sdk-bundle.jar"

  # download PostgreSQL JDBC driver
  download_file "https://jdbc.postgresql.org/download/postgresql-${POSTGRESQL_JDBC_DRIVER_VERSION}.jar" "${SPARK_HOME}/jars/postgresql-jdbc.jar"

    # fix guava version issues
  rm "${SPARK_HOME}/jars/guava-14.0.1.jar"
  download_file "https://repo1.maven.org/maven2/com/google/guava/guava/${GUAVA_VERSION}/guava-${GUAVA_VERSION}.jar" "${SPARK_HOME}/jars/guava.jar"

  # Clean up
  blue "Cleaning up artifacts"
  rm -rf "${archive_path}"
  if [ -f "${signature_path}" ]; then rm -f "${signature_path}"; fi

}

install_spark


