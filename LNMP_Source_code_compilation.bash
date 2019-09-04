#!/bin/sh
#author:shichao
#date:2018/08/02
#mail:shichao@scajy.cn

[ -f /etc/init.d/functions ] && . /etc/init.d/functions  ||exit

export Usr_tools='/usr/local/src/'

function NGINX(){
    rpm -ivh http://mirrors.ustc.edu.cn/epel/7/x86_64/Packages/e/epel-release-7-11.noarch.rpm >/dev/null 2>&1
    return=$?
    if [ "${return}"  -eq 0 ]
        then
            action "nginx源安装"  /bin/true
            
    else
         action "nginx源安装"  /bin/false
    fi
	

    is_nginx=$(rpm -qa  nginx | wc -l)
    if [ $is_nginx -ne 0 ] ;then 
        NGINX_version=$(rpm -qa nginx | awk -F "-" '{print $1,"-",$2}')
        echo "nginx已经安装,版本为："$NGINX_version  
    else
        echo "nginx安装中,请稍等......"
		    groupadd www
			useradd www -g www -M -s /sbin/nologin
			cd "${Usr_tools}"
			NGINX_TAR=`[ -e  "${Usr_tools}"nginx-1.14.0.tar.gz ] && echo yes || echo no`
			if [ "${NGINX_TAR}" == yes ]
				then
				echo "The package already exists direct decompression."
			else
				wget http://nginx.org/download/nginx-1.14.0.tar.gz > /dev/null 2>&1
			fi
			tar zxf nginx-1.14.0.tar.gz
			cd nginx-1.14.0
			./configure --prefix=/usr/local/nginx-1.14.0 --user=www --group=www --with-compat --with-file-aio --with-threads  --with-http_addition_module --with-http_auth_request_module --with-http_dav_module --with-http_flv_module  --with-http_gunzip_module --with-http_gzip_static_module --with-http_mp4_module --with-http_random_index_module --with-http_realip_module  --with-http_secure_link_module --with-http_slice_module --with-http_ssl_module --with-http_stub_status_module --with-http_sub_module --with-http_v2_module --with-mail --with-mail_ssl_module --with-stream --with-stream_realip_module --with-stream_ssl_module --with-stream_ssl_preread_module --with-file-aio --with-ipv6 --with-cc-opt='-O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4 -grecord-gcc-switches -m64 -mtune=generic -fPIC' --with-ld-opt='-Wl,-z,relro -Wl,-z,now -pie'   > /dev/null 2>&1
			return=$?
			if [  "${return}" -eq 0 ] ; then
				echo "Compile completed, compile no problem, continue to implement make and make install"
			else
				exit 1
			fi
			make   >/dev/null 2>&1
			return=$?
			if [  "${return}" -eq 0 ] ; then
				echo "Compile completed, compile no problem, continue to implement make install"
			else
				exit 1
			fi
			
			make install   >/dev/null 2>&1
			return=$?
			if [  "${return}" -eq 0 ] ; then
				action "nginx编译安装"  /bin/true
			else
				action "nginx编译安装"  /bin/false
			fi
    fi
    ln -s /usr/local/nginx-1.14.0 /usr/local/nginx
    echo "nginx正在启动，请稍等........"
	/usr/local/nginx-1.14.0/sbin/nginx
    return=$?
    if [ "${return}"  -eq 0 ]
        then
            action "nginx启动"  /bin/true
            
    else
         action "nginx启动"  /bin/false
    fi

}

function MYSQL(){
    is_nginx=$(rpm -qa  mariadb | wc -l)
    if [ $is_nginx -ne 0 ] ;then 
        yum -y remove mariadb* boost-*
        echo "The MariaDB service has been deleted."
	else
		echo "MariaDB does not exist. You can install mysql."
	fi
	yum install -y cmake make gcc gcc-c++ bison ncurses ncurses-devel > /dev/null 2>&1
	groupadd mysql
	useradd -g mysql -M mysql -s /sbin/nologin
	[ -d /data/mysql ] ||  mkdir -p /data/mysql
	chown -R mysql.mysql /data/mysql
	mkdir -p /usr/local/boost
	cd "${Usr_tools}"
	BOOST=`[ -f "${Usr_tools}"boost_1_59_0.tar.gz ] && echo yes || echo no`
	if [  "${BOOST}" == yes ]
		then
			tar -zxf boost_1_59_0.tar.gz  -C /usr/local/boost  
	else
		wget  https://nchc.dl.sourceforge.net/project/boost/boost/1.59.0/boost_1_59_0.tar.gz  > /dev/null 2>&1
		tar -zxf boost_1_59_0.tar.gz   -C /usr/local/boost
	fi
	cd "${Usr_tools}"
	MYSQL_tools=`[ -f "${Usr_tools}"mysql-5.7.22.tar.gz ] && echo yes || echo no`
	if [  "${MYSQL_tools}" == yes ]
		then
			tar -zxf mysql-5.7.22.tar.gz
	else
		wget  http://mysql.ntu.edu.tw/MySQL/Downloads/MySQL-5.7/mysql-5.7.22.tar.gz > /dev/null 2>&1
		tar -zxf mysql-5.7.22.tar.gz
	fi
	cd mysql-5.7.22
	cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DMYSQL_DATADIR=/data/mysql -DDOWNLOAD_BOOST=1 -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_MEMORY_STORAGE_ENGINE=1 -DWITH_ARCHIVE_STORAGE_ENGINE=1 -DWITH_FEDERATED_STORAGE_ENGINE=1 -DWITH_BLACKHOLE_STORAGE_ENGINE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DWITH_READLINE=1 -DMYSQL_UNIX_ADDR=/data/mysql/mysql.sock -DMYSQL_TCP_PORT=3306 -DENABLED_LOCAL_INFILE=1 -DENABLE_DTRACE=0 -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DMYSQL_USER=mysql -DWITH_BOOST=/usr/local/boost  >/dev/null 2>&1
			return=$?
			if [  "${return}" -eq 0 ] ; then
				echo "Compile completed, compile no problem, continue to implement make and make install"
			else
				exit 1
			fi
			make   >/dev/null 2>&1
			return=$?
			if [  "${return}" -eq 0 ] ; then
				echo "Compile completed, compile no problem, continue to implement make install"
			else
				exit 1
			fi
			
			make install   >/dev/null 2>&1
			return=$?
			if [  "${return}" -eq 0 ] ; then
				action "mysql编译安装"  /bin/true
			else
				action "mysql编译安装"  /bin/false
			fi
			chown -R mysql.mysql /usr/local/mysql
			cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld && echo 'export PATH=$PATH:/usr/local/mysql/bin' >> /etc/profile && source /etc/profile
cat > /etc/my.cnf << EOF
[client]
port = 3306
socket=/data/mysql/mysql.sock
default-character-set=utf8
[mysqld]
basedir = /usr/local/mysql
datadir = /data/mysql
socket=/data/mysql/mysql.sock
character_set_server=utf8
EOF





	/usr/local/mysql/bin/mysqld --initialize-insecure --user=mysql --basedir=/usr/local/mysql --datadir=/data/mysql  > /dev/null 2>&1
	return=$?
	if [ "${return}" ]
		then
			action "mysql数据库初始化"  /bin/true
	else
		  action "mysql 数据库初始化"   /bin/false
	fi
	
    echo "mysql正在启动，请稍等........"
    /etc/init.d/mysqld start
   
    return=$?
    if [ "${return}"  -eq 0 ]
        then
            action "mysql启动"  /bin/true
            
    else
         action "mysql启动"  /bin/false
    fi
	 echo 'PATH=/usr/local/mysql/bin:$PATH' >> /etc/profile
	 source /etc/profile

}

function PHP(){
	yum -y install php-mcrypt libmcrypt libmcrypt-devel  autoconf  freetype gd libmcrypt libpng libpng-devel libjpeg libxml2 libxml2-devel zlib curl curl-devel re2c net-snmp-devel libjpeg-devel php-ldap openldap-devel openldap-servers openldap-clients freetype-devel gmp-devel   > /dev/null 2>&1
	cd "${Usr_tools}"
	PHP_tools=`[ -f "${Usr_tools}"php-7.2.6.tar.gz ] && echo yes || echo no`
	if [  "${PHP_tools}" == yes ]
		then
			tar zxf php-7.2.6.tar.gz 
	else
		wget http://cn2.php.net/distributions/php-7.2.6.tar.gz > /dev/null 2>&1
		tar zxf php-7.2.6.tar.gz 
	fi
	
	cd php-7.2.6
	./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc/ --with-mysqli --with-pdo-mysql --with-mysql-sock=/usr/local/mysql/mysql.sock --with-iconv-dir --with-freetype-dir --with-jpeg-dir --with-png-dir --with-curl --with-gd --with-gmp --with-zlib --with-xmlrpc --with-openssl --without-pear --with-snmp --with-gettext --with-mhash --with-libxml-dir=/usr --with-fpm-user=www --with-fpm-group=www --enable-xml --enable-fpm  --enable-ftp --enable-bcmath --enable-soap --enable-shmop --enable-sysvsem --enable-sockets --enable-inline-optimization --enable-maintainer-zts --enable-mbregex --enable-mbstring --enable-pcntl --enable-zip --disable-fileinfo --disable-rpath --enable-libxml --enable-opcache --enable-mysqlnd > /dev/null 2>&1
			return=$?
			if [  "${return}" -eq 0 ] ; then
				echo "Compile completed, compile no problem, continue to implement make and make install"
			else
				exit 1
			fi
			make   >/dev/null 2>&1
			return=$?
			if [  "${return}" -eq 0 ] ; then
				echo "Compile completed, compile no problem, continue to implement make install"
			else
				exit 1
			fi
			
			make install   >/dev/null 2>&1
			return=$?
			if [  "${return}" -eq 0 ] ; then
				action "PHP编译安装"  /bin/true
			else
				action "PHP编译安装"  /bin/false
			fi
	cp /usr/local/php/etc/php-fpm.d/www.conf.default /usr/local/php/etc/php-fpm.conf  &&  cp /usr/local/src/php-7.2.6/php.ini-production /usr/local/php/etc/php.ini && cp /usr/local/src/php-7.2.6/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm  && chmod +x /etc/init.d/php-fpm && chkconfig --add php-fpm  &&  chkconfig php-fpm on &&	/etc/init.d/php-fpm start
}

function LNMP(){

mkdir -p /usr/local/nginx/conf/conf.d  && mkdir -p /var/log/nginx
cat > /usr/local/nginx/conf/nginx.conf <<EOF
user  www www;

worker_processes  auto;

error_log  /var/log/nginx/error.log  info;

events {
    use  epoll;
    worker_connections  1024;
}
http {
    include       mime.types;
    default_type  application/octet-stream;
    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;

    sendfile        on;
    keepalive_timeout  65;
    server_tokens off;
    send_timeout 15;
    client_max_body_size 10m;

    gzip on;
    gzip_min_length 1k;
    gzip_buffers 4 32k;
    gzip_http_version 1.1;
    gzip_comp_level 4;
    gzip_types   application/x-javascript text/css application/xml;
    gzip_vary on;

    fastcgi_buffer_size  64k;
    fastcgi_buffers  4 64k;
    fastcgi_busy_buffers_size  128k;
    fastcgi_connect_timeout   300s;
    fastcgi_read_timeout      300s;
    fastcgi_send_timeout      300s;
    fastcgi_temp_file_write_size 128k;  
    include conf.d/*;

}

EOF

touch /usr/local/nginx/conf/conf.d/www_80.conf

cat > /usr/local/nginx/conf/conf.d/www_80.conf <<EOF
 server {
        listen       80;
        server_name  localhost;

        location / {
            root   html;
            index  index.php index.html index.htm;
        }

        location ~ \.php\$ {
            root           html;
            fastcgi_pass   127.0.0.1:9000;
            fastcgi_index  index.php;
            fastcgi_param  SCRIPT_FILENAME  \$document_root\$fastcgi_script_name;
            include        fastcgi_params;
        }

}

EOF

/usr/local/nginx/sbin/nginx -t > /dev/null 2>&1
return=$?
	if [  "${return}" -eq 0 ] ; then
		action "nginx配置文件修改完成"  /bin/true
	else
		action "nginx配置文件修改完成"  /bin/false
	fi
echo "mysql正在启动，请稍等........"
/usr/local/nginx/sbin/nginx -s reload > /dev/null 2>&1
return=$?
    if [ "${return}"  -eq 0 ]
        then
            action "nginx 重新加载配置文件"  /bin/true
            
    else
         action "nginx 重新加载配置文件"  /bin/false
    fi
	 
}



while : 
do
    
    cat <<EOF
        +----------------------------------+
        |                                  |
        |         This  is  a LNMP         |
        |                                  |
        |         1.安装Nginx              |
        |         2.安装MySQL              |
        |         3.安装PHP                |
        |         4.配置LNMP环境           |
        |         5.退出本次安装           |
        +----------------------------------+
EOF
    read -p "请你输入一个数字:" num
    case "$num" in
        1)
            NGINX
            ;;
        2)
            MYSQL
        ;;
        3)
            PHP
        ;;
        4)
            LNMP
        ;;
        5)
        exit
        ;;
        *)
        echo '输入错误，已重新加载....'
        ;;
    esac
	
done