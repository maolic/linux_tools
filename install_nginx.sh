#!/usr/bin/env bash
#=================================================
#	System Required: CentOS 7+, Debian 9+, Ubuntu 16+
#	Description: Nginx 一键安装脚本
#	Version: 1.2.2
#	Author: MLC
# Update Date: 2024年10月11日
#=================================================
xc_ver="1.2.2"
nginx_ver="1.27.2"
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
	elif cat /proc/version | grep -q -E -i "centos|red hat|redhat|Kylin"; then
		release="centos"
    fi
	#bit=`uname -m`
}
clear
echo
echo "#############################################################"
echo "# System Required: CentOS 7+, Debian 9+, Ubuntu 16+         #"
echo "# Description: Nginx 一键安装脚本                           #"
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
		echo -e " 当前版本已是最新[ ${sh_new_ver} ]，无需更新" && exit 0
	else
		wget -N --no-check-certificate "https://raw.githubusercontent.com/maolic/linux_tools/main/install_nginx.sh" && chmod +x install_nginx.sh
		echo -e " 脚本已更新为最新版本[ ${sh_new_ver} ] !(注意：因为更新方式为直接覆盖当前运行的脚本，所以可能下面会提示一些报错，无视即可)" && exit 0
	fi
}
Download_Nginx(){
  version="${nginx_ver}"

  echo
  echo -e "${Info} 是否选择从线上获取最新版本安装？\n 否将安装脚本默认版本：${nginx_ver}"
  read -e -p "(默认: n):" unyn
  [[ -z ${unyn} ]] && unyn="n"
  if [[ ${unyn} == [Yy] ]]; then
    echo -e "${Info} 联网获取最新Nginx版本 ..."
    sleep 1s
    nginx_new_ver=$(curl http://nginx.org/en/CHANGES | grep 'Changes with nginx'|awk -F " " '{print $4}' | head -1)
    echo -e "${Info} 当前最新发布版本 ${nginx_new_ver}"
    sleep 1s
    version=${nginx_new_ver}
  fi

	nginx_url="http://nginx.org/download/nginx-"${version}".tar.gz"
#	echo -e "当前nginx下载链接："${nginx_url}
	wget ${nginx_url}
	[[ ! -s "nginx-${version}.tar.gz" ]] && echo -e "${Error} Nginx 源码文件下载失败 !" && rm -rf "nginx-${version}.tar.gz" && exit 1
	tar -xzvf nginx-${version}.tar.gz && cd nginx-${version}
	./configure --with-http_stub_status_module --with-http_ssl_module
	make
	make install
	cd .. && cd ..
}
Installation_Dependency(){
	if [[ ${release} == "centos" ]]; then
		yum update -y
		yum install -y gcc pcre-devel zlib-devel openssl openssl-devel make vim
	elif [[ ${release} == "debian" ]]; then
		apt-get update -y
		apt-get install -y gcc zlib* pcre* libpcre3 libpcre3-dev openssl libssl-dev libperl-dev make vim
	elif [[ ${release} == "ubuntu" ]]; then
		sudo apt-get update -y
		sudo apt-get install -y gcc zlib* pcre* libpcre3 libpcre3-dev openssl libssl-dev libperl-dev make vim
	else
		echo -e "${Error} 本脚本不支持本系统，请在 CentOS 7+ / Debian 9+ / Ubuntu 16+ 上执行 !" && exit 1
	fi
}
Install_Nginx(){
	check_root
	[[ -e ${file} ]] && echo -e "${Error} Nginx 已安装，请检查 !" && exit 1
	echo -e "${Info} 开始安装/配置 依赖..."
	Installation_Dependency
	echo -e "${Info} 开始下载/安装 Nginx(init)..."
	Download_Nginx
	
	echo -e "${Info} 正在启动 ..."
	Start_Nginx
}
Install_Nginx_Custom(){
	check_root
	[[ -e ${file} ]] && echo -e "${Error} Nginx 已安装，请检查 !" && exit 1
	echo -e "${Info} 是否选择从离线包安装，离线安装需提前下载后上传"

	read -e -p "(默认: n):" unyn
	[[ -z ${unyn} ]] && unyn="n"
	if [[ ${unyn} == [Yy] ]]; then
    echo
    read -e -p " 请输入完整离线安装包路径和名称:" offline_path
    [[ ! -s "$offline_path" ]] && echo -e "${Error} Nginx 源码文件不存在，安装失败 !" && exit 1
    echo " 即将安装的包路径：$offline_path"
    echo
    echo -e "${Tip} 请输入正确的扩展模块，每个模块间用空格分隔，留空则默认不安装其他模块，如："
    echo -e " --with-http_stub_status_module --with-http_ssl_module"
    echo
    echo -e " 可参阅 https://blog.csdn.net/qq_41036832/article/details/80695981"
    echo
    read -e -p " 请输入需要安装的扩展模块:" modules
    echo " 即将安装的扩展模块：$modules"

    echo -e "${Info} 开始安装/配置 依赖..."
    Installation_Dependency
    echo -e "${Info} 开始安装自定义 Nginx 版本..."
    mkdir nginx_offline_install
    tar -zxvf ${offline_path} -C nginx_offline_install/  --strip-components 1 && cd nginx_offline_install
    ./configure ${modules}
    make
    make install
    cd .. && cd ..

	else
    version="${nginx_ver}"
    echo
	  echo -e "是否选择从线上获取最新版本安装？"
    read -e -p "(默认: n):" unyn
    [[ -z ${unyn} ]] && unyn="n"
    if [[ ${unyn} == [Yy] ]]; then
      echo -e "${Info} 联网获取最新Nginx版本 ..."
      sleep 1s
      nginx_new_ver=$(curl http://nginx.org/en/CHANGES | grep 'Changes with nginx'|awk -F " " '{print $4}' | head -1)
      echo -e "${Info} 当前最新发布版本 ${nginx_new_ver}"
      sleep 1s
      version=${nginx_new_ver}
	  else
      echo
      echo -e "${Tip} 请输入需要安装的版本号，如${nginx_ver}\n 可参阅 http://nginx.org/en/download.html"
      echo
      read -e -p " 请输入需要安装的版本(默认: ${nginx_ver}):" version
      echo " 输入安装版本：$version"
    fi

    if [[ ${version} == null || ${version} == "" || ${version} == " " ]]; then
      version="${nginx_ver}"
    fi

    echo
    echo -e "${Tip} 请输入正确的扩展模块，每个模块间用空格分隔，留空则默认不安装其他模块，如："
    echo -e " --with-http_stub_status_module --with-http_ssl_module"
    echo
    echo -e " 可参阅 https://blog.csdn.net/qq_41036832/article/details/80695981"
    echo
    read -e -p " 请输入需要安装的扩展模块:" modules
    echo " 即将安装的扩展模块：$modules"

    echo -e "${Info} 开始下载自定义 Nginx 版本..."
    nginx_url="http://nginx.org/download/nginx-"${version}".tar.gz"
    wget ${nginx_url}
    [[ ! -s "nginx-${version}.tar.gz" ]] && echo -e "${Error} Nginx 源码文件下载失败 !" && echo " 请检查版本输入是否正确或网络设置是否正确 ！" && rm -rf "nginx-${version}.tar.gz" && exit 1

    echo -e "${Info} 开始安装/配置 依赖..."
    Installation_Dependency

    echo -e "${Info} 开始安装自定义 Nginx 版本..."
    tar -xzvf nginx-${version}.tar.gz && cd nginx-${version}
    ./configure ${modules}
    make
    make install
    cd .. && cd ..

	fi

	echo -e "${Info} 正在启动 ..."
	Start_Nginx
}
Update_Nginx(){
	check_root
	check_installed_status "un"

  echo
  echo -e "${Tip} 请注意，大版本的升级可能会发生配置文件配置失效情况（如https的配置规则变化），请在大版本升级后确认是否部署成功！"
  echo
	echo "是否继续升级 ? (Y/n)"
  read -e -p "(默认: n):" unyn
  [[ -z ${unyn} ]] && unyn="n"
  if [[ ${unyn} == [Nn] ]]; then
		exit 1
	fi

  version="${nginx_ver}"
  echo
  echo -e "${Info} 是否选择从线上获取最新版本安装？\n 否将安装脚本默认版本：${nginx_ver}"
  read -e -p "(默认: n):" unyn
  [[ -z ${unyn} ]] && unyn="n"
  if [[ ${unyn} == [Yy] ]]; then
    echo -e "${Info} 联网获取最新Nginx版本 ..."
    sleep 1s
    nginx_new_ver=$(curl http://nginx.org/en/CHANGES | grep 'Changes with nginx'|awk -F " " '{print $4}' | head -1)
    echo -e "${Info} 当前最新发布版本 ${nginx_new_ver}"
    sleep 1s
    version=${nginx_new_ver}
  fi

	sleep 1s
	echo
	echo -e "${Info} 开始备份原 Nginx（不备份logs目录）..."
	sleep 1s
	bak_name=$(date +%Y%m%d%H%M)
	tar -zcvf /usr/local/nginx.${bak_name}.bak.tar.gz /usr/local/nginx --exclude=nginx/logs/*
	modules_info=$(echo $(/usr/local/nginx/sbin/nginx -V 2>&1)|awk -F ':' '{print $3}')
	sleep 1s
	echo
	echo -e "${Info} 原Nginx模块信息：\n ${modules_info}"
	sleep 1s
	
	echo -e "${Info} 开始下载 Nginx-${version}..."
	nginx_url="http://nginx.org/download/nginx-"${version}".tar.gz"
	wget ${nginx_url}
	[[ ! -s "nginx-${version}.tar.gz" ]] && echo -e "${Error} Nginx 源码文件下载失败 !" && rm -rf "nginx-${version}.tar.gz" && exit 1
	tar -xzvf nginx-${version}.tar.gz && cd nginx-${version}
	./configure ${modules_info}
	make
	echo -e "${Info} 正在停止 Nginx..."
	Stop_Nginx
	sleep 1s
	cp $(pwd)/objs/nginx /usr/local/nginx/sbin/
	
	sleep 1s
	echo -e "${Info} 正在重启 Nginx..."
	Start_Nginx
	echo
	echo -e "${Info} 更新成功，原Nginx打包备份文件：/usr/local/nginx.${bak_name}.bak.tar.gz"
	echo
	echo -e " 当前版本信息："
	View_Nginx_Info
}
Update_Nginx_Custom(){
	check_root
	check_installed_status "un"

  echo
  echo -e "${Tip} 请注意，跨版本的升级可能会发生配置文件配置失效情况（如https的配置规则变化），请在升级后确认是否部署成功！"
  echo
	echo "是否继续升级 ? (Y/n)"
  read -e -p "(默认: n):" unyn
  [[ -z ${unyn} ]] && unyn="n"
  if [[ ${unyn} == [Nn] ]]; then
		exit 1
	fi

  echo
  read -e -p " 请输入完整离线安装包路径和名称:" offline_path
  [[ ! -s "$offline_path" ]] && echo -e "${Error} Nginx 源码文件不存在，安装失败 !" && exit 1
  echo " 即将安装的包路径：$offline_path"
  echo

	sleep 1s
	echo
	echo -e "${Info} 开始备份原 Nginx（不备份logs目录）..."
	sleep 1s
	bak_name=$(date +%Y%m%d%H%M)
	tar -zcvf /usr/local/nginx.${bak_name}.bak.tar.gz /usr/local/nginx --exclude=nginx/logs/*
	modules_info=$(echo $(/usr/local/nginx/sbin/nginx -V 2>&1)|awk -F ':' '{print $3}')
	sleep 1s
	echo
	echo -e "${Info} 原Nginx模块信息：\n ${modules_info}"
	sleep 1s

  echo -e "${Info} 开始离线更新 Nginx..."
  mkdir nginx_offline_update
	tar -zxvf ${offline_path} -C nginx_offline_update/  --strip-components 1 && cd nginx_offline_update
	./configure ${modules_info}
	make
	echo -e "${Info} 正在停止 Nginx..."
	Stop_Nginx
	sleep 1s
	cp $(pwd)/objs/nginx /usr/local/nginx/sbin/

	sleep 1s
	echo -e "${Info} 正在重启 Nginx..."
	Start_Nginx
	echo
	echo -e "${Info} 更新成功，原Nginx打包备份文件：/usr/local/nginx.${bak_name}.bak.tar.gz"
	echo
	echo -e " 当前版本信息："
	View_Nginx_Info
}
Uninstall_Nginx(){
	check_installed_status "un"
	echo " 确定要卸载 Nginx ? (y/N)"
	echo
	read -e -p "(默认: n):" unyn
	[[ -z ${unyn} ]] && unyn="n"
	if [[ ${unyn} == [Yy] ]]; then
		Stop_Nginx_No_Exit
		rm -rf /usr/local/nginx
		
		echo && echo " Nginx 卸载完成 !" && echo
	else
		echo && echo " 卸载已取消..." && echo
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
Stop_Nginx_No_Exit(){
	check_installed_status
	check_pid
	[[ -n ${PID} ]] && /usr/local/nginx/sbin/nginx -s stop

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
View_Nginx_Info(){
	check_installed_status
	${file}/sbin/nginx -V
}
Create_Systemctl(){
  SERVICE_FILE="/etc/systemd/system/nginx.service"

  cat << EOF > $SERVICE_FILE
[Unit]
Description=A high performance web server and a reverse proxy server
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
PIDFile=/usr/local/nginx/logs/nginx.pid
ExecStartPre=/usr/local/nginx/sbin/nginx -t
ExecStart=/usr/local/nginx/sbin/nginx
ExecReload=/usr/local/nginx/sbin/nginx -s reload
ExecStop=/usr/local/nginx/sbin/nginx -s stop
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

  # 检查服务文件是否创建成功
  if [ ! -f $SERVICE_FILE ]; then
    echo "创建失败请检测系统日志"
    exit 1
  else
    systemctl daemon-reload
    echo "Nginx systemd service 创建成功，可以使用 systemctl 控制了！"
  fi

  # 创建软连接
  ln -s /usr/local/nginx/sbin/nginx /usr/sbin/nginx
}

echo -e " Nginx_${nginx_ver} 一键安装脚本 ${Red_font_prefix}[v${xc_ver}]${Font_color_suffix}
  
 ${Green_font_prefix} 0.${Font_color_suffix} 脚本 检查更新
————————————
 ${Green_font_prefix} 1.${Font_color_suffix} 安装 Nginx
 ${Green_font_prefix} 2.${Font_color_suffix} 卸载 Nginx
————————————
 ${Green_font_prefix} 3.${Font_color_suffix} 启动 Nginx
 ${Green_font_prefix} 4.${Font_color_suffix} 停止 Nginx
 ${Green_font_prefix} 5.${Font_color_suffix} 重启 Nginx
 ${Green_font_prefix} 6.${Font_color_suffix} 重载 Nginx
————————————
 ${Green_font_prefix} 7.${Font_color_suffix} 修改 配置文件
 ${Green_font_prefix} 8.${Font_color_suffix} 查看 访问日志
 ${Green_font_prefix} 9.${Font_color_suffix} 查看 错误日志
 ${Green_font_prefix}10.${Font_color_suffix} 查看 Nginx版本与编译信息
————————————
 ${Green_font_prefix}11.${Font_color_suffix} 安装 自定义Nginx版本
 ${Green_font_prefix}12.${Font_color_suffix} 升级 Nginx版本
 ${Green_font_prefix}13.${Font_color_suffix} 升级 离线更新 Nginx
 ${Green_font_prefix}14.${Font_color_suffix} 创建 systemd 服务和软连接
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
read -e -p " 请输入数字 [0-14]:" num
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
	10)
	View_Nginx_Info
	;;
	11)
	check_sys
	Install_Nginx_Custom
	;;
	12)
	Update_Nginx
	;;
	13)
	Update_Nginx_Custom
	;;
	14)
	Create_Systemctl
	;;
	*)
	echo "请输入正确数字 [0-14]"
	;;
esac
