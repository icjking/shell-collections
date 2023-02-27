#!/bin/bash

function openLoading() {
  ## echo -ne 指令在 Linux shell 中用于输出字符串，但是不会添加换行符。
  ## -n 表示不换行，-e 表示原样输出字符串，而不是将其中的特殊字符进行转义，例如换行符。
  echo -ne 'Loading '
  i=1
  while [ $i -le 6 ]; do
    # \033[?25l 隐藏光标
    # \033[?25h 显示光标
    echo -ne '.\033[?25l'
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
