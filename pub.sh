#!/usr/bin/env bash
###################################
# docker发布脚本
# example1: sh pub.sh
# example2: sh pub.sh v1.0.0
# Created by cjking on 2020/06/23.
###################################

ENV=$1

#项目名称
JOB_NAME=project-name

# 镜像版本
VERSION=$2

# 导入日志脚本
source ./.log.sh

# 导入工具类脚本
source ./utils.sh

# 导入tag脚本
source ./docker-tags "${JOB_NAME}"

# 导入服务器选址脚本
source ./server.sh

if [ -z "$VERSION" ]; then
	log "请选择版本？"
	VERSION=$(openSelect)
	log "你选择的版本号是: ${VERSION}"
fi

log "请选择服务器？"
SERVER=$(getServer)
log "服务器地址: ${SERVER}"

#空判断
#ENV default test
if [ -z "$1" ]; then
	log "ENV is empty, default test"
	ENV='test'
fi

log "编译环境: $ENV"

if [ ! -d "../dist/" ]; then
	log "dist目录不存在，开始编译..."
	#编译源码
	sh docker-build.sh "${JOB_NAME}" "$VERSION"
fi

function openSSH() {
	local lastStr
	lastStr=$(getLastStr "${SERVER}")
	log "连接到${lastStr}服务器"

	# shell远程执行
	# shellcheck disable=SC2029
	ssh root@"${SERVER} cd /www/oral/frontend/; sh docker-run ${JOB_NAME} ${VERSION}"
}

openSSH
