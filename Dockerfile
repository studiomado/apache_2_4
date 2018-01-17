FROM matrim/centos6.3

MAINTAINER alessandro.minoccheri@studiomado.it

RUN yum remove httpd

ADD repo/10gen.repo /etc/yum.repos.d/10gen.repo
ADD repo/epel-release-6-8.noarch.rpm /etc/yum.repos.d/epel-release-6-8.noarch.rpm
ADD repo/remi-release-6.rpm /etc/yum.repos.d/remi-release-6.rpm
ADD repo/remi.repo /etc/yum.repos.d/remi.repo

RUN yum -y update && yum install -y mysql mysql-server mysql-devel gcc-c++ openssl-devel mongodb-org ImageMagick ImageMagick-devel ImageMagick-perl curl man vim nano wget mod_ssl mlocate  git wget mod_ssl mlocate libtool pcre-devel
RUN mkdir /usr/local/apache2 && cd /usr/local/apache2 && curl -O -L https://github.com/apache/httpd/archive/2.4.7.tar.gz && curl -O -L https://github.com/apache/apr/archive/1.5.2.tar.gz && curl -O -L https://github.com/apache/apr-util/archive/1.5.4.tar.gz && tar -zxvf 2.4.7.tar.gz && tar -zxvf 1.5.2.tar.gz && tar -zxvf 1.5.4.tar.gz && cp -r apr-util-1.5.4 httpd-2.4.7/srclib/apr-util && cp -r apr-1.5.2 httpd-2.4.7/srclib/apr
RUN cd /usr/local/apache2/httpd-2.4.7 && ./buildconf && ./configure --enable-ssl --enable-so --with-mpm=event --prefix=/usr/local/apache2 && make && make install && touch /etc/profile.d/httpd.sh && echo "pathmunge /usr/local/apache2/bin" > /etc/profile.d/httpd.sh
RUN yum update -y openssl

RUN rpm -Uvh /etc/yum.repos.d/epel-release-6-8.noarch.rpm
RUN rpm -Uvh /etc/yum.repos.d/remi-release-6.rpm
RUN sed -i "s/https/http/" /etc/yum.repos.d/epel.repo
RUN sed -i "s/https/http/" /etc/yum.repos.d/epel-testing.repo

RUN yum install -y php php-devel php-pear php-pdo php-mysql php-dom php-gd php-mongo php-soap php-gd php-mcrypt
RUN mkdir -p /usr/lib/php
RUN pecl install imagick

RUN mkdir -p /usr/local/apache2/conf/ssl && cd /usr/local/apache2/conf/ssl && openssl req -new -x509 -days 365 -sha1 -newkey rsa:1024 -nodes -keyout server.key -out server.crt  -subj '/O=Company/OU=Department/CN=vhost'

ADD usr/local/apache2/conf/extra/httpd-vhosts.conf /usr/local/apache2/conf/extra/httpd-vhosts.conf
ADD usr/local/apache2/conf/httpd.conf /usr/local/apache2/conf/httpd.conf
ADD usr/local/apache2/modules/libphp5.so /usr/local/apache2/modules/libphp5.so

RUN mkdir -p /var/www/html/data/logs
RUN mkdir -p /var/www/html/data/cache
RUN touch /var/www/html/data/logs/access_log
RUN touch /var/www/html/data/logs/error_log
RUN chmod 777 -R /var/www/html/data/logs

RUN /usr/local/apache2/bin/apachectl stop
RUN /etc/init.d/httpd stop
RUN chkconfig httpd off

EXPOSE 80 443

ENTRYPOINT /usr/local/apache2/bin/apachectl start && bash
