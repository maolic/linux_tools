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
```
wget https://raw.githubusercontent.com/maolic/linux_tools/main/install_java.sh
source install_java.sh
```
