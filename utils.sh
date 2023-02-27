#!/bin/bash
###################################
# shell工具类
# 命令: sh docker-build.sh project-name
# Created by cjking on 2020/06/20.
###################################

# resolve "jq" command for parse json
# shellcheck disable=SC2230
if [[ ! $(which jq) ]]; then
  echo "jq is not installed on target system, please install it first! "
  # adaptive for CentOS or Ubuntu or Mac
  apt-get -qq -y install jq || yum -y install jq || brew install jq
  # shellcheck disable=SC2181
  [ $? -ne 0 ] && echo "Trying install jq failed! "
  echo "Trying install jq successfully! "
  echo "$(which jq) is found!"
  echo 1
fi

readonly API=https://docker-registry.fmock.cn

function isEmpty() {
  local var="$1"

  # Return true if:
  # 1. var is a null string ("" as empty string)
  # 2. a non set variable is passed
  # 3. a declared variable or array but without a value is passed
  # 4. an empty array is passed
  if test -z "$var"; then
    [[ $(printf "1") ]]
    return

  # Return true if var is zero (0 as an integer or "0" as a string)
  elif [ "$var" == 0 ] 2>/dev/null; then
    [[ $(printf "1") ]]
    return

  # Return true if var is 0.0 (0 as a float)
  elif [ "$var" == 0.0 ] 2>/dev/null; then
    [[ $(printf "1") ]]
    return
  fi

  [[ $(printf "") ]]
}

function split() {
  local str=$1
  local separator=$2 # 分隔符
  local lastStr
  if (isEmpty "${separator}"); then
    separator="."
  fi
  OLD_IFS="${IFS}" # 保存旧的分隔符
  IFS="${separator}"
  # shellcheck disable=SC2206
  array=(${str})
  IFS="$OLD_IFS"     # 将IFS恢复成原来的
  echo "${array[*]}" # 相当于return
}

function getLastStr() {
  local array
  local lastStr
  # shellcheck disable=SC2207
  array=($(split "${1}" "${2}")) # 用()重新定义一下数组!
  lastStr=${array[${#array[@]} - 1]}
  echo "${lastStr}" # 相当于return
}

function includes() {
  if [[ $1 =~ $2 ]]; then
    [[ $(printf "1") ]]
  else
    [[ $(printf "") ]]
  fi
}

function trim() {
  echo "$1" | sed -e 's/^[ ]*//g' | sed -e 's/[ ]*$//g'
}

function getJsonValue() {
  local data=$1
  local fieldName=$2
  local value
  value=$(echo "${data}" | jq ".${fieldName}")
  echo "${value}"
}

# 查询镜像
function getRepositories() {
  local toList=$1
  local errMsg
  local ret
  local repositories
  ret=$(curl -X GET -s --netrc-file ~/.netrc "${API}"/v2/_catalog)
  if (includes "${ret}" "repositories"); then
    repositories=$(getJsonValue "${ret}" "repositories")
    if [ "${toList}" == true ]; then
      repositories=$(echo "${repositories}" | sed -e 's/"//g' | sed -e 's/\[//g' | sed -e 's/\]//g')
      repositories=$(split "${repositories}" ",")
      echo "${repositories[*]}"
    else
      echo "${repositories}"
    fi
  else
    errMsg="${ret}"
    echo "${errMsg}"
  fi
}

# 查询镜像tag
function getTagList() {
  local IMAGE=$1
  local toList=$2
  local errMsg
  local ret
  local tagList
  ret=$(curl -X GET -s --netrc-file ~/.netrc "${API}"/v2/"${IMAGE}"/tags/list)
  if (includes "${ret}" "tags"); then
    tagList=$(getJsonValue "${ret}" "tags")
    if [ "${toList}" == true ]; then
      tagList=$(echo "${tagList}" | sed -e 's/"//g' | sed -e 's/\[//g' | sed -e 's/\]//g')
      tagList=$(split "${tagList}" ",")
      echo "${tagList[*]}"
    else
      echo "${tagList}"
    fi
  else
    errMsg=$(echo "${ret}" | grep -o '"message":.*",' | sed -e 's/"message":"//g' | sed -e 's/",//g')
    echo "${errMsg}"
  fi
}

# 查询镜像digest_hash
function getTagDigest() {
  local IMAGE=$1
  local TAG=$2
  local tagDigest
  ret=$(curl --header Accept:application/vnd.docker.distribution.manifest.v2+json -I -X GET -s --netrc-file ~/.netrc "${API}"/v2/"${IMAGE}"/manifests/"${TAG}")
  if (includes "${ret}" "404 Not Found"); then
    echo "404 Not Found"
  else
    tagDigest=$(echo "${ret}" | grep -o 'Docker-Content-Digest:.*' | sed -e 's/Docker-Content-Digest: //g')
    tagDigest=$(trim "${tagDigest}")
    echo "${tagDigest}"
  fi
}

# 删除私有库镜像
function delTagByDigest() {
  local IMAGE=$1
  local tagDigest=$2
  # shellcheck disable=SC2046
  url="https://docker-registry.fmock.cn/v2/${IMAGE}/manifests/${tagDigest}"
  ret=$(curl --netrc-file ~/.netrc -s -I -X "DELETE" "${url}")
  if (includes "${ret}" "Accepted"); then
    echo true
  else
    echo false
  fi
}

# example:
#value="Loading "
#padStart "${value}" 10 "." #value为变量，10为定长(字符总长度)
function padStart() {
  text=${1}
  space_length=${2}
  pad_string=${3}
  if [ -z "$pad_string" ]; then
    pad_string=" "
  fi
  text_length=$(echo "${text}" | awk '{print length($0)}')
  fill_length=$((space_length - text_length))
  point_space=$(seq -s "$pad_string" $((fill_length + 1)) | sed 's/[0-9]//g')
  echo -e "${point_space}${text}"
}

# example:
#value="Loading "
#padEnd "${value}" 10 "." #value为变量，10为定长(字符总长度)
function padEnd() {
  text=${1}
  space_length=${2}
  pad_string=${3}
  nowrap=${4}
  if [ -z "$pad_string" ]; then
    pad_string=" "
  fi
  text_length=$(echo "${text}" | awk '{print length($0)}')
  fill_length=$((space_length - text_length))
  point_space=$(seq -s "$pad_string" $((fill_length + 1)) | sed 's/[0-9]//g')
  if [ "$nowrap" = true ]; then
    echo -ne "${text}${point_space}"
  else
    echo -e "${text}${point_space}"
  fi
}
