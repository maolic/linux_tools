# Linux 一键脚本

### Nginx一键安装

- 支持系统：CentOS 7+, Debian 9+, Ubuntu 16+
- 安装路径：/usr/local/nginx

目前支持CentOS 7+, Debian 9+, Ubuntu 16+系统，请确保服务器80和443端口不被占用，安装后可通过修改配置文件更改端口，
如显示安装成功但是无法通过 IP 访问，请尝试访问 127.0.0.1 以及检查服务器防火墙、安全组等配置。
```
wget https://raw.githubusercontent.com/maolic/linux_tools/main/install_nginx.sh
bash install_nginx.sh
```

**2024年10月11日更新** v1.2.2
1. 新增创建 systemd 服务和软连接选项
2. 更新 Nginx 默认版本为 1.27.2

**2023年5月25日更新** v1.2.1
1. 修复停止状态下无法卸载情况
2. 新增 Kylin 并增加 Debian 下未安装 sudo 兼容性
3. 更新 Nginx 默认版本为 1.25.0

**2023年2月16日更新** v1.2.0
1. 新增离线包升级功能。

**2023年2月14日更新** v1.1.2
1. 修复升级选项相反问题。
2. 更新 Nginx 的默认安装版本。

**2022年2月10日更新** v1.0.4
1. 支持自定义版本的离线安装，将nginx源码包上传到指定目录即可。
2. 支持升级至1.21.6版本

**2022年1月20日更新** v1.0.3
 1. 支持自定义版本和模块安装
 2. 支持升级至1.21.5版本

### JDK一键安装

- 支持系统：CentOS 7+, Debian 9+, Ubuntu 16+
- 已测试版本：JDK8、JDK17
- 安装路径：/usr/local/java

请先前往Oracle官网下载对应版本JDK压缩包后上传至服务器，再运行此脚本。
下载地址：https://www.oracle.com/java/technologies/downloads/
```
wget https://raw.githubusercontent.com/maolic/linux_tools/main/install_java.sh
source install_java.sh
```

### Wget一键升级

- 支持系统：CentOS 7+
- 测试系统：CentOS 7.9
- 安装路径：/usr/local/bin/wget

CentOS 7 自带的 Wget 版本太老，简单写了个一键升级。与其说是一键升级，不如说是把原来的卸载再装个新的。
脚本默认卸载旧版本并安装最新的版本。
Wget 下载地址：https://ftp.gnu.org/gnu/wget/
```
wget https://raw.githubusercontent.com/maolic/linux_tools/main/update_wget.sh
bash update_wget.sh
```
