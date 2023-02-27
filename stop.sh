#!/bin/sh

PROJECT_NAME=$1

echo "开始停止【${PROJECT_NAME}】服务..."

if [ -z "${PROJECT_NAME}" ]; then
  echo "请输入项目名称！"
fi

# shellcheck disable=SC2009
pid=$(ps -ef | grep "${PROJECT_NAME}.jar" | grep -v grep | awk '{print $2}')

if [ -n "${pid}" ]; then
  kill -9 "${pid}"
fi

echo "停止【${PROJECT_NAME}】服务完成。"
