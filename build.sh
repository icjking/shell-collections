#!/bin/sh

echo "JOB_NAME: ${JOB_NAME}"
echo "branch: ${branch}"
echo "build_type: ${build_type}"
echo "publish_type: ${publish_type}"

VERSION="3.4.4"
PROJECT_DIR="/data/project/backend"
PROJECT_CLIENT_NAME="pera-client-start-${VERSION}"
PROJECT_SYSTEM_NAME="pera-system-start-${VERSION}"
TARGET_PATH="pera-module-${publish_type}/pera-${publish_type}-start/target"

server=""
# 将 == 改成 = ，因为在 dash 中默认的判断语句是 =
# shellcheck disable=SC2236
if [ "$build_type" = "dev" ]; then
  server="192.168.87.47"
elif [ "$build_type" = "test" ]; then
  server="192.168.87.50"
elif [ "$build_type" = "lenovo" ]; then
  server="192.168.87.51"
  PROJECT_CLIENT_NAME="lenovo-client-${VERSION}"
  PROJECT_SYSTEM_NAME="lenovo-system-${VERSION}"
elif [ "$build_type" = "prod" ]; then
  server="192.168.87.51"
fi

echo "server: $server"

# build
#mvn clean && mvn package -P "$build_type" -Dmaven.test.skip=true
mvn package -P "$build_type" -Dmaven.test.skip=true

# shellcheck disable=SC2029
ssh root@${server} "rm -rf ${PROJECT_DIR}/${JOB_NAME} && mkdir -p ${PROJECT_DIR}/${JOB_NAME}"

scp restart.sh stop.sh check.sh root@${server}:"${PROJECT_DIR}/${JOB_NAME}/"

JAR_NAME=""
# shellcheck disable=SC2236
if [ "${publish_type}" = "client" ]; then
  JAR_NAME="${TARGET_PATH}/${PROJECT_CLIENT_NAME}.jar"
  scp "${JAR_NAME}" root@${server}:"${PROJECT_DIR}/${JOB_NAME}/"
elif [ "${publish_type}" = "system" ]; then
  JAR_NAME="${TARGET_PATH}/${PROJECT_SYSTEM_NAME}.jar"
  scp "${JAR_NAME}" root@${server}:"${PROJECT_DIR}/${JOB_NAME}/"
elif [ "${publish_type}" = "all" ]; then
  CLIENT_TARGET_PATH="pera-module-client/pera-client-start/target"
  SYSTEM_TARGET_PATH="pera-module-system/pera-system-start/target"
  CLIENT_JAR_NAME="${CLIENT_TARGET_PATH}/${PROJECT_CLIENT_NAME}.jar"
  SYSTEM_JAR_NAME="${SYSTEM_TARGET_PATH}/${PROJECT_SYSTEM_NAME}.jar"
  scp "${CLIENT_JAR_NAME}" root@${server}:"${PROJECT_DIR}/${JOB_NAME}/"
  scp "${SYSTEM_JAR_NAME}" root@${server}:"${PROJECT_DIR}/${JOB_NAME}/"
fi

# shellcheck disable=SC2029
ssh root@${server} "cd ${PROJECT_DIR}/${JOB_NAME} && ls -al"

# shellcheck disable=SC2236
if [ "${publish_type}" = "client" ]; then
  # shellcheck disable=SC2029
  ssh root@${server} "cd ${PROJECT_DIR}/${JOB_NAME} && sh stop.sh ${PROJECT_CLIENT_NAME} client && sh restart.sh ${PROJECT_CLIENT_NAME} client"
elif [ "${publish_type}" = "system" ]; then
  # shellcheck disable=SC2029
  ssh root@${server} "cd ${PROJECT_DIR}/${JOB_NAME} && sh stop.sh ${PROJECT_SYSTEM_NAME} system && sh restart.sh ${PROJECT_SYSTEM_NAME} system"
elif [ "${publish_type}" = "all" ]; then
  # shellcheck disable=SC2029
  ssh root@${server} "cd ${PROJECT_DIR}/${JOB_NAME} && sh stop.sh ${PROJECT_CLIENT_NAME} client && sh restart.sh ${PROJECT_CLIENT_NAME} client"
  # shellcheck disable=SC2029
  ssh root@${server} "cd ${PROJECT_DIR}/${JOB_NAME} && sh stop.sh ${PROJECT_SYSTEM_NAME} system && sh restart.sh ${PROJECT_SYSTEM_NAME} system"
fi
