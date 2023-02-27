#!/bin/bash
###################################
# 新建分支脚本
# 命令: sh co.sh
# Created by cjking on 2020/05/06.
###################################

# 导入日志脚本
source ./.log.sh

log update branch.
git pull

log checkout master
git checkout master

log update master.
git pull

# shellcheck disable=SC2162
#read -p "Input Password: " -s password # -s 不回显
read -p "Input New Branch Name: " name
log branch name is: "$name".

git checkout -b "$name"

git push origin master:"$name"

git branch --set-upstream-to=origin/"$name"
