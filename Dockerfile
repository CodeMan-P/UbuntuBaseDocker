FROM ubuntu:18.04

RUN cp /etc/apt/sources.list /etc/apt/sources.list.bak
COPY ./sources.list /etc/apt/
#RUN rm -rf /var/lib/apt/lists/partial/*
RUN apt-get update &&\
    apt-get -y upgrade
RUN apt-get install -y mysql-server mysql-client libmysqlclient-dev tree lsof nano
ADD ./apache-tomcat-9.0.13.tar.gz /root/software

#tar -czf - jdk1.8.0_191 | split -b 80m -d - jdk-8u191.tar.gz
COPY ./jdk-8u191.tar.gz00 /root/software
COPY ./jdk-8u191.tar.gz01 /root/software
COPY ./jdk-8u191.tar.gz02 /root/software
RUN cat /root/software/jdk-8u191.tar.gz* | tar -xzf - -C /root/software/
RUN rm -f /root/software/jdk-8u191.tar.gz*

ADD ./setup.sh /root/setup.sh
ADD ./tomcat /etc/init.d

COPY ./mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf
ARG pwd=123456

ARG sql1="grant all privileges on *.* to 'root'@'%' identified by '"${pwd}"' WITH GRANT OPTION ;"
ARG sql2="grant all privileges on *.* to 'root'@'localhost' identified by '"${pwd}"' WITH GRANT OPTION ;"
ARG sql3="update mysql.user set authentication_string=PASSWORD('${pwd}'), plugin='mysql_native_password' where user='root';FLUSH PRIVILEGES;"

RUN chown -R mysql:mysql /var/lib/mysql
RUN usermod -d /var/lib/mysql/ mysql

#VOLUME /var/lib/mysql
RUN chown -R mysql:mysql /var/lib/mysql && \
    service mysql start && \
    mysql -e "${sql3};"&&\
    mysql -uroot -p${pwd} -e "${sql1}"&&\
    mysql -uroot -p${pwd} -e "${sql2}"&&\
    mysql -uroot -p${pwd} -e "show databases;"&&\
    mysql -uroot -p${pwd} -e "select user,host,authentication_string,plugin from mysql.user"&&\
    service mysql stop

EXPOSE 3306
EXPOSE 8080

#set environment variable
#Java Env
ENV JAVA_HOME /root/software/jdk1.8.0_191
ENV JRE_HOME ${JAVA_HOME}/jre
ENV CLASSPATH .:${JAVA_HOME}/lib/dt.jar:${JAVA_HOME}/lib/tools.jar
ENV PATH $PATH:${JAVA_HOME}/bin
#tomcat
ENV TOMCAT_HOME /root/software/apache-tomcat-9.0.13


RUN chmod 700 /root/setup.sh
RUN apt-get install -y wget curl git
RUN apt-get install -y redis-server
RUN apt-get install -y build-essential cmake
RUN apt install -y software-properties-common
RUN add-apt-repository ppa:ubuntu-toolchain-r/test -y
RUN apt install -y gcc-9 g++-9
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 90 --slave /usr/bin/g++ g++ /usr/bin/g++-9
RUN update-alternatives --config gcc
#define entry point which will be run first when the container starts up
#ENTRYPOINT /root/setup.sh
