#!/bin/bash
###################################
# 选择服务器地址
# Created by cjking on 2020/07/03.
###################################

# 服务器地址
readonly SERVERS=("192.168.70.178" "192.168.70.180" "192.168.70.181")

# Usage
#######################################
# 导入服务器选址脚本
# source ./server.sh
# SERVER=$(getServer)
# log "服务器地址: ${SERVER}"
#######################################

function getServer() {
	select server in "${SERVERS[@]}"; do
		# 不能为空
		if [ -n "${server}" ]; then
			echo "${server}"
			return
		fi
	done
}
