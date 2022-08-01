# Linux 一键脚本

### Nginx一键安装

- 支持系统：CentOS 7+, Debian 9+, Ubuntu 16+
- 安装路径：/usr/local/nginx

**2022年2月10日更新** v1.0.4
1. 支持自定义版本的离线安装，将nginx源码包上传到指定目录即可。
2. 支持升级至1.21.6版本

**2022年1月20日更新** v1.0.3
 1. 支持自定义版本和模块安装
 2. 支持升级至1.21.5版本

目前支持CentOS 7+, Debian 9+, Ubuntu 16+系统，请确保服务器80和443端口不被占用。
```
wget https://raw.githubusercontent.com/maolic/linux_tools/main/install_nginx.sh
bash install_nginx.sh
```

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
