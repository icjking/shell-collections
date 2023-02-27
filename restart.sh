#!/bin/sh

PROJECT_NAME=$1
PROJECT_TYPE=$2
LOGS_DIR="logs/${PROJECT_TYPE}"

echo "开始启动【${PROJECT_NAME}】服务..."

if [ -z "${PROJECT_NAME}" ]; then
  echo "请输入项目名称！"
fi

mkdir -p "${LOGS_DIR}"

rm -rf "${LOGS_DIR}/*.log"

# shellcheck disable=SC2009
pid=$(ps -ef | grep "${PROJECT_NAME}.jar" | grep -v grep | awk '{print $2}')

if [ -n "${pid}" ]; then
  kill -9 "${pid}"
fi

chmod 777 "${PROJECT_NAME}.jar"

nohup java -jar "${PROJECT_NAME}".jar >>"${LOGS_DIR}"/clientLogInfo.log 2>>"${LOGS_DIR}"/clientError.log &

#sleep 35
#
## -n为最后n行
#tail -n 10 "${LOGS_DIR}/clientLogInfo.log"

check_file=./check.sh
if [ -f ${check_file} ]; then
  bash ${check_file} "${PROJECT_TYPE}"
fi

echo "启动【${PROJECT_NAME}】服务完成。"
