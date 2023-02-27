#!/bin/bash

trap 'onCtrlC' INT
function onCtrlC() {
  printf '\nCtrl+C is captured'
  # \033[?25h 显示光标
  echo -ne '.\033[?25h'
  exit 0
}

# 定时检测 logs/clientLogInfo.log 文件内容是否包含 "xxx"，不用crontab实现
PROJECT_TYPE=$1
if [ -z "$PROJECT_TYPE" ]; then
  echo "项目类型丢失!"
  exit 1
fi
LOGS_DIR="logs/${PROJECT_TYPE}"
LOG_FILE="$LOGS_DIR/clientLogInfo.log"
if [ ! -f "$LOG_FILE" ]; then
  echo "$LOG_FILE No Found!"
  # mkdir -p "$LOGS_DIR"
  # touch "$LOG_FILE"
  exit 1
fi
STRING="Application LCA is running! Access URLs"

function check() {
  if [ -f "$LOG_FILE" ]; then
    if grep -q "$STRING" "$LOG_FILE"; then
      echo "true"
    else
      echo "false"
    fi
  else
    echo "false"
  fi
}

function openLoading() {
  ## echo -ne 指令在 Linux shell 中用于输出字符串，但是不会添加换行符。
  ## -n 表示不换行，-e 表示原样输出字符串，而不是将其中的特殊字符进行转义，例如换行符。
  echo -ne 'Loading '
  i=1
  while [ $i -le 6 ]; do
    # \033[?25l 隐藏光标
    # \033[?25h 显示光标
    echo -ne '.\033[?25l'
    res=$(check)
    if [ "$res" == "true" ]; then
      i=100
      # \033[?25h 显示光标
      echo -ne '.\033[?25h'
      break
    fi
    sleep 0.5
    i=$((i + 1))
    if [ $i -ge 7 ]; then
      i=1
      # echo -e "\033[30m 黑色字 \033[0m"
      # \33[y;xH设置光标位置，其中 Y 和 X 分别是行号和列号, 比如：echo -ne "\033[0;0H"
      # echo -ne "\033[$((LINENO - 1));0H"
      # 清空当前行
      echo -ne "\r\033[K"
      echo -ne 'Loading '
    fi
  done
}

while true; do
  # -s 选项检查指定的文件是否为非空（nonzero），
  # 即文件大小是否大于 0（byte）。如果是，则返回 true
  if [ -s "$LOG_FILE" ]; then
    if grep -q "$STRING" "$LOG_FILE"; then
      # echo "$STRING Found in LOG_FILE"
      # -n为最后n行
      tail -n 10 "$LOG_FILE"
      exit
    else
      openLoading
      sleep 1
    fi
  else
    # echo "文件内容为空"
    # exit 1
    sleep 1
  fi
done
