#!/bin/bash
###################################
# 日志输出
# Created by cjking on 2020/07/02.
###################################

SYSTEM=""

# 判断操作系统
function checkSystem() {
	a=$(uname -a)

	b="Darwin"
	c="centos"
	d="ubuntu"

	SYSTEM=""
	if [[ $a =~ $b ]]; then
		SYSTEM="mac"
	elif [[ $a =~ $c ]]; then
		SYSTEM="centos"
	elif [[ $a =~ $d ]]; then
		SYSTEM="ubuntu"
	else
		# shellcheck disable=SC2034
		SYSTEM="$a"
	fi
}
checkSystem

# 统一日志输出
function log() {
	if [ "$SYSTEM" == "mac" ]; then
		echo "\033[32m$1\033[0m"
	else
		echo -e "\033[32m$1\033[0m"
	fi
}
