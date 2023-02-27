#!/bin/bash

#项目名称
JOB_NAME=$1

# 镜像版本
VERSION=""

# 导入工具类
source ./utils.sh

# 导入日志脚本
source ./.log.sh

if [ -z "${JOB_NAME}" ]; then
	JOB_NAME="project-name"
fi

# 导入tag脚本
source ./docker-tags "${JOB_NAME}"

log "请选择版本？"
VERSION=$(openSelect)
log "你选择的版本号是: ${VERSION}"

tagDigest=$(getTagDigest "${JOB_NAME}" "${VERSION}")
log "tagDigest: ${tagDigest}"

if [ "${tagDigest}" != "404 Not Found" ]; then
	delStatus=$(delTagByDigest "${JOB_NAME}" "${tagDigest}")
	log "delStatus: ${delStatus}"

	tagList=$(getTagList "${JOB_NAME}")
	log "tagList: ${tagList}"
fi
