#!/bin/bash
###################################
# docker编译脚本(含推送至私服)
# 命令: sh docker-build.sh project-name
# 命令: sh docker-build.sh project-name v1.0.0
# Created by cjking on 2020/06/20.
###################################

# 镜像名
NAME=$1

# 镜像版本
VERSION=$2

# docker私服地址
readonly REGISTRY_URL=docker-registry.fmock.cn

# 导入工具类
source ./utils.sh

# 导入日志脚本
source ./.log.sh

# 导入tag脚本
source ./docker-tags

# 导入服务器选址脚本
source ./server.sh

cd ..

if [ -z "${NAME}" ]; then
	log "docker镜像名称不能为空!"
	log "命令格式: sh docker-build.sh project-name"
	exit 100
fi

if [ -z "${VERSION}" ]; then
	VERSION=$(getNewVersion)
	log "新的版本号: ${VERSION}"
fi

if [ ! -d "./dist/" ]; then
	log "dist目录不存在，开始编译..."
	#编译源码
	npm run build:prod
fi

# 错误拦截
# $?是上次执行的返回状态
exitStatus=$?
if [ ${exitStatus} -ne 0 ]; then
	exit ${exitStatus}
fi

SERVER=$(getServer)
log "服务器地址: ${SERVER}"

# 替换nginx API地址
cp nginx.conf nginx_temp.conf
sed -i "" "s/server localhost/server ${SERVER}/g" nginx_temp.conf

docker build -f Dockerfile -t "${NAME}":"${VERSION}" .

# 删除临时文件
rm -rf nginx_temp.conf

# 根据镜像名字或者ID为它创建一个标签，缺省为latest
log "docker tag 打包中..."
docker tag "${NAME}":"${VERSION}" "${REGISTRY_URL}"/"${NAME}":"${VERSION}"
log "docker tag 打包完成。"

# 登录认证
log "docker认证开始..."
docker login https://"${REGISTRY_URL}"
log "docker认证完成。"

log "docker开始推送..."
docker push "${REGISTRY_URL}"/"${NAME}":"${VERSION}"
log "docker推送完成。"

# shellcheck disable=SC2181
if [ $? -eq 0 ]; then
	log "push Success"
	getTagList "${NAME}"
else
	log "push Failed"
fi
