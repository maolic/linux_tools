#!/usr/bin/env bash
ver="0.0.1"
Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[信息]${Font_color_suffix}"
Error="${Red_font_prefix}[错误]${Font_color_suffix}"
Tip="${Green_font_prefix}[注意]${Font_color_suffix}"
clear
echo
echo "#############################################################"
echo "# System Required: CentOS 7+                                #"
echo "# Description: WGet Update                                  #"
echo "# Author: MLC <mlc@tom.com>                                 #"
echo "# Github: https://github.com/maolic                         #"
echo "#############################################################"
echo
check_root(){
	[[ $EUID != 0 ]] && echo -e "${Error} 当前非ROOT账号(或没有ROOT权限)，无法继续操作，请更换ROOT账号或使用 ${Green_background_prefix}sudo su${Font_color_suffix} 命令获取临时ROOT权限（执行后可能会提示输入当前账号的密码）。" && exit 1
}
update_shell(){
	sh_new_ver=$(wget --no-check-certificate -qO- -t1 -T3 "https://raw.githubusercontent.com/maolic/linux_tools/main/update_wget.sh"|grep 'ver="'|awk -F "=" '{print $NF}'|sed 's/\"//g'|head -1) && sh_new_type="github"
	[[ -z ${sh_new_ver} ]] && echo -e "${Error} 无法链接到 服务器 !" && exit 0
	if [[ ${sh_new_ver} = ${ver} ]]; then
		echo -e " 当前版本已是最新[ ${sh_new_ver} ]，无需更新" && exit 0
	else
		wget -N --no-check-certificate "https://raw.githubusercontent.com/maolic/linux_tools/main/update_wget.sh" && chmod +x update_wget.sh
		echo -e " 脚本已更新为最新版本[ ${sh_new_ver} ] !(注意：因为更新方式为直接覆盖当前运行的脚本，所以可能下面会提示一些报错，无视即可)" && exit 0
	fi
}
update_wget(){
	wget -N --no-check-certificate https://ftp.gnu.org/gnu/wget/wget-latest.tar.gz
	yum install gcc openssl-devel -y
	yum remove wget -y
	mkdir wget-latest
	tar -xvf wget-latest.tar.gz -C wget-latest
	child_dir=$(ls wget-latest | grep 'wget')
	cd wget-latest/${child_dir}
	./configure --with-ssl=openssl
	make && make install
	echo -e "${Info} 更新命令执行成功，请查看当前版本信息，如未生效请尝试重新连接或者重启服务器。"
}
version_wget(){
	wget -V
}
echo -e " WGet 一键升级脚本
 ${Green_font_prefix} 0.${Font_color_suffix} 脚本 检查更新
————————————
 ${Green_font_prefix} 1.${Font_color_suffix} 升级 WGet
 ${Green_font_prefix} 2.${Font_color_suffix} 查看 WGet 版本信息
————————————" && echo
echo
read -e -p " 请输入数字 [0-12]:" num
case "$num" in
	0)
	update_shell
	;;
	1)
	check_root
	update_wget
	;;
	2)
	version_wget
	;;
	*)
	echo "请输入正确数字 [0-2]"
	;;
esac
