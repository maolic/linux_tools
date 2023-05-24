#!/usr/bin/env bash
#=================================================
#	System Required: CentOS 7+, Debian 9+, Ubuntu 16+
#	Description: Java JDK 离线一键安装脚本
#	Author: MLC
#=================================================
version="1.1"
path="/usr/local/java"
Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[信息]${Font_color_suffix}"
Error="${Red_font_prefix}[错误]${Font_color_suffix}"
Tip="${Green_font_prefix}[注意]${Font_color_suffix}"
clear
echo
echo "#############################################################"
echo "# System Required: CentOS 7+, Debian 9+, Ubuntu 16+         #"
echo "# Description: Java JDK 离线一键安装脚本                    #"
echo "# Author: MLC <mlc@tom.com>                                 #"
echo "# Version: ${version}                                              #"
echo "# Github: https://github.com/maolic                         #"
echo "#############################################################"
echo
result=$(command -v java| wc -w)
if [[ ${result} == 1 ]]; then
  echo -e "${Tip} Java 环境已安装!"
  echo
  echo '—————— 版本信息 ——————'
	java -version
  echo '—————— 版本信息 ——————' && exit 1
fi
echo
[[ $EUID != 0 ]] && echo -e "${Error} 当前非ROOT账号(或没有ROOT权限)，无法继续操作，请更换ROOT账号或使用 ${Green_background_prefix}sudo su${Font_color_suffix} 命令获取临时ROOT权限（执行后可能会提示输入当前账号的密码）。" && exit 1
echo
echo -e "${Tip} 请前往Oracle官网下载对应版本tar.gz结尾压缩包后上传至服务器。\n 下载地址：https://www.oracle.com/java/technologies/downloads/"
read -e -p " 请输入完整JDK安装包路径和名称:" jdk_path
[[ ! -s "$jdk_path" ]] && echo -e "${Error} JDK 文件不存在，安装失败 !" && exit 1
echo " 即将安装的包路径：$jdk_path"
mkdir ${path}
tar -zxvf ${jdk_path} -C ${path} --strip-components 1

echo '' >> /etc/profile
echo 'export JAVA_HOME='${path} >> /etc/profile
echo 'export JRE_HOME=${JAVA_HOME}/jre' >> /etc/profile
echo 'export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib' >> /etc/profile
echo 'export PATH=${JAVA_HOME}/bin:$PATH' >> /etc/profile
sleep 3s
source /etc/profile

echo
echo '—————— 版本信息 ——————'
java -version
echo '—————— 版本信息 ——————'
echo
echo -e "${Info} 安装完成，如果出现Java版本信息不为空则安装成功，如果未生效则手动输入命令执行生效 'source /etc/profile'"
echo
