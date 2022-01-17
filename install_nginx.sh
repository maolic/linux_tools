#!/usr/bin/env bash
#=================================================
#	System Required: CentOS 7+, Debian 9+, Ubuntu 16+
#	Description: Nginx_1.21.5 一键安装脚本
#	Version: 1.0.2
#	Author: MLC
#=================================================
xc_ver="1.0.2"
nginx_ver="1.21.5"
file="/usr/local/nginx"
conf="/usr/local/nginx/conf/nginx.conf"
access_log="/usr/local/nginx/logs/access.log"
error_log="/usr/local/nginx/logs/error.log"
PID_FILE="/usr/local/nginx/logs/nginx.pid"
Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[信息]${Font_color_suffix}"
Error="${Red_font_prefix}[错误]${Font_color_suffix}"
Tip="${Green_font_prefix}[注意]${Font_color_suffix}"
#检查系统
check_sys(){
	if [[ -f /etc/redhat-release ]]; then
		release="centos"
	elif cat /etc/issue | grep -q -E -i "debian"; then
		release="debian"
	elif cat /etc/issue | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
	elif cat /proc/version | grep -q -E -i "debian"; then
		release="debian"
	elif cat /proc/version | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
    fi
	#bit=`uname -m`
}
clear
echo
echo "#############################################################"
echo "# System Required: CentOS 7+, Debian 9+, Ubuntu 16+         #"
echo "# Description: Nginx_1.21.5 一键安装脚本                    #"
echo "# Author: MLC <mlc@tom.com>                                 #"
echo "# Github: https://github.com/maolic                         #"
echo "#############################################################"
echo
check_root(){
	[[ $EUID != 0 ]] && echo -e "${Error} 当前非ROOT账号(或没有ROOT权限)，无法继续操作，请更换ROOT账号或使用 ${Green_background_prefix}sudo su${Font_color_suffix} 命令获取临时ROOT权限（执行后可能会提示输入当前账号的密码）。" && exit 1
}
check_installed_status(){
	[[ ! -e ${file} ]] && echo -e "${Error} Nginx 没有安装，请检查 !" && exit 1
}
check_pid(){
#	PID=`pgrep -o nginx`
	if [[ ! -e ${PID_FILE} ]]; then
		PID=""
	else
		PID=$(cat ${PID_FILE})
	fi
}
Update_Shell(){
	sh_new_ver=$(wget --no-check-certificate -qO- -t1 -T3 "https://raw.githubusercontent.com/maolic/linux_tools/main/install_nginx.sh"|grep 'xc_ver="'|awk -F "=" '{print $NF}'|sed 's/\"//g'|head -1) && sh_new_type="github"
	[[ -z ${sh_new_ver} ]] && echo -e "${Error} 无法链接到 服务器 !" && exit 0
	if [[ ${sh_new_ver} = ${xc_ver} ]]; then
		echo -e "当前版本已是最新[ ${sh_new_ver} ]，无需更新" && exit 0
	else
		wget -N --no-check-certificate "https://raw.githubusercontent.com/maolic/linux_tools/main/install_nginx.sh" && chmod +x install_nginx.sh
		echo -e "脚本已更新为最新版本[ ${sh_new_ver} ] !(注意：因为更新方式为直接覆盖当前运行的脚本，所以可能下面会提示一些报错，无视即可)" && exit 0
	fi
}
Download_Nginx(){
	nginx_url="http://nginx.org/download/nginx-"${nginx_ver}".tar.gz"
#	echo -e "当前nginx下载链接："${nginx_url}
	wget ${nginx_url}
	[[ ! -s "nginx-${nginx_ver}.tar.gz" ]] && echo -e "${Error} Nginx 源码文件下载失败 !" && rm -rf "nginx-${nginx_ver}.tar.gz" && exit 1
	tar -xzvf nginx-${nginx_ver}.tar.gz && cd nginx-${nginx_ver}
	./configure --with-http_stub_status_module --with-http_ssl_module
	make
	make install
	cd .. && cd ..
}
Installation_Dependency(){
	if [[ ${release} == "centos" ]]; then
		yum update -y
		yum install -y gcc pcre-devel zlib-devel openssl openssl-devel make vim
	elif [[ ${release} == "debian" || ${release} == "ubuntu" ]]; then
		sudo apt-get update -y
		sudo apt-get install -y gcc zlib* pcre* libpcre3 libpcre3-dev openssl libssl-dev libperl-dev make vim
	else
		echo -e "${Error} 本脚本不支持本系统，请在CentOS 7+上执行 !" && exit 1
	fi
}
Install_Nginx(){
	check_root
	[[ -e ${file} ]] && echo -e "${Error} Nginx 已安装，请检查 !" && exit 1
	echo -e "${Info} 开始安装/配置 依赖..."
	Installation_Dependency
	echo -e "${Info} 开始下载/安装 Nginx(init)..."
	Download_Nginx
	if [[ ${release} == "centos" ]]; then
		echo -e "${Info} 设置 防火墙80端口..."
		Add_firewall80
		echo -e "${Info} 设置 防火墙443端口..."
		Add_firewall443
		echo -e "${Info} 重启防火墙..."
		firewall-cmd --reload
	fi
	echo -e "${Info} 正在启动 ...\n（如有防火墙错误提示可忽略）"
	Start_Nginx
}
Uninstall_Nginx(){
	check_installed_status "un"
	echo "确定要卸载 Nginx ? (y/N)"
	echo
	read -e -p "(默认: n):" unyn
	[[ -z ${unyn} ]] && unyn="n"
	if [[ ${unyn} == [Yy] ]]; then
		Stop_Nginx
		rm -rf /usr/local/nginx
		if [[ ${release} == "centos" ]]; then
			echo -e "${Info} 设置 防火墙80端口..."
			Remove_firewall80
			echo -e "${Info} 设置 防火墙443端口..."
			Remove_firewall443
		fi
		echo && echo "Nginx 卸载完成 !（如有防火墙错误提示可忽略）" && echo
	else
		echo && echo "卸载已取消..." && echo
	fi
}
View_Config(){
	echo
	if [[ -e ${file} ]]; then
		check_pid
		if [[ ! -z "${PID}" ]]; then
			echo -e " 当前状态: ${Green_font_prefix}已安装${Font_color_suffix} 并 ${Green_font_prefix}已启动${Font_color_suffix}"
		else
			echo -e " 当前状态: ${Green_font_prefix}已安装${Font_color_suffix} 但 ${Red_font_prefix}未启动${Font_color_suffix}"
		fi
	else
		echo -e " 当前状态: ${Red_font_prefix}未安装${Font_color_suffix}"
	fi
	echo
}
Start_Nginx(){
	check_installed_status
	check_pid
	[[ ! -z ${PID} ]] && echo -e "${Error} Nginx 正在运行，请检查 !" && exit 1
	/usr/local/nginx/sbin/nginx
	sleep 2s
	check_pid
	[[ ! -z ${PID} ]] && View_Config
}
Stop_Nginx(){
	check_installed_status
	check_pid
	[[ -z ${PID} ]] && echo -e "${Error} Nginx 没有运行，请检查 !" && exit 1
	/usr/local/nginx/sbin/nginx -s stop
}
Restart_Nginx(){
	check_installed_status
	check_pid
	[[ -z ${PID} ]] && echo -e "${Error} Nginx 没有运行，请检查 !" && exit 1
	/usr/local/nginx/sbin/nginx -s stop
	/usr/local/nginx/sbin/nginx
	sleep 2s
	check_pid
	View_Config
}
Reload_Nginx(){
	check_installed_status
	check_pid
	[[ -z ${PID} ]] && echo -e "${Error} Nginx 没有运行，请检查 !" && exit 1
	/usr/local/nginx/sbin/nginx -s reload
	echo "重载完毕"
}
View_Access_Log(){
	[[ ! -e ${access_log} ]] && echo -e "${Error} Nginx 访问日志文件不存在 !" && exit 1
	echo && echo -e "${Tip} 按 ${Red_font_prefix}Ctrl+C${Font_color_suffix} 终止查看日志" && echo -e "如果需要查看完整日志内容，请用 ${Red_font_prefix}cat ${access_log}${Font_color_suffix} 命令。" && echo
	tail -f ${access_log}
}
View_Error_Log(){
	[[ ! -e ${error_log} ]] && echo -e "${Error} Nginx 错误日志文件不存在 !" && exit 1
	echo && echo -e "${Tip} 按 ${Red_font_prefix}Ctrl+C${Font_color_suffix} 终止查看日志" && echo -e "如果需要查看完整日志内容，请用 ${Red_font_prefix}cat ${error_log}${Font_color_suffix} 命令。" && echo
	tail -f ${error_log}
}
Add_firewall80(){
	firewall-cmd --add-port=80/tcp --permanent
}
Add_firewall443(){
	firewall-cmd --add-port=443/tcp --permanent
}
Remove_firewall80(){
	firewall-cmd --remove-port=80/tcp --permanent
}
Remove_firewall443(){
	firewall-cmd --remove-port=443/tcp --permanent
}
Set_Nginx_Config(){
	[[ ! -e ${conf} ]] && echo -e "${Error} Nginx 配置文件不存在 !" && exit 1
	cp ${conf} ${conf}.bak
	vim ${conf}
	echo "是否重启 Nginx ? (Y/n)"
	read -e -p "(默认: Y):" yn
	[[ -z ${yn} ]] && yn="y"
	if [[ ${yn} == [Yy] ]]; then
		Reload_Nginx
	fi
}
echo -e " Nginx_${nginx_ver} 一键安装脚本 ${Red_font_prefix}[v${xc_ver}]${Font_color_suffix}
  
 ${Green_font_prefix}0.${Font_color_suffix} 脚本 检查更新
————————————
 ${Green_font_prefix}1.${Font_color_suffix} 安装 Nginx
 ${Green_font_prefix}2.${Font_color_suffix} 卸载 Nginx
————————————
 ${Green_font_prefix}3.${Font_color_suffix} 启动 Nginx
 ${Green_font_prefix}4.${Font_color_suffix} 停止 Nginx
 ${Green_font_prefix}5.${Font_color_suffix} 重启 Nginx
 ${Green_font_prefix}6.${Font_color_suffix} 重载 Nginx
————————————
 ${Green_font_prefix}7.${Font_color_suffix} 修改 配置文件
 ${Green_font_prefix}8.${Font_color_suffix} 查看 访问日志
 ${Green_font_prefix}9.${Font_color_suffix} 查看 错误日志
————————————" && echo
if [[ -e ${file} ]]; then
	check_pid
	if [[ ! -z "${PID}" ]]; then
		echo -e " 当前状态: ${Green_font_prefix}已安装${Font_color_suffix} 并 ${Green_font_prefix}已启动${Font_color_suffix}"
	else
		echo -e " 当前状态: ${Green_font_prefix}已安装${Font_color_suffix} 但 ${Red_font_prefix}未启动${Font_color_suffix}"
	fi
else
	echo -e " 当前状态: ${Red_font_prefix}未安装${Font_color_suffix}"
fi
echo
read -e -p " 请输入数字 [0-8]:" num
case "$num" in
	0)
	Update_Shell
	;;
	1)
	check_sys
	Install_Nginx
	;;
	2)
	Uninstall_Nginx
	;;
	3)
	Start_Nginx
	;;
	4)
	Stop_Nginx
	;;
	5)
	Restart_Nginx
	;;
	6)
	Reload_Nginx
	;;
	7)
	Set_Nginx_Config
	;;
	8)
	View_Access_Log
	;;
	9)
	View_Error_Log
	;;
	*)
	echo "请输入正确数字 [0-8]"
	;;
esac
