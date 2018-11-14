FROM ubuntu
VOLUME /tmp


RUN cp /etc/apt/sources.list /etc/apt/sources.list.bak
COPY ./sources.list /etc/apt/
#RUN rm -rf /var/lib/apt/lists/partial/*
RUN apt-get update
RUN apt-get install -y mysql-server mysql-client libmysqlclient-dev tree lsof nano
ADD ./apache-tomcat-9.0.13.tar.gz /root/software
#ADD ./jdk-8u191-linux-x64.tar.gz /root/software
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
ARG sql3="update mysql.user set authentication_string=PASSWORD('${pwd}') where user='root';"

RUN /bin/bash -c  'echo ${sql1}'
RUN /bin/bash -c  'echo ${sql2}'
RUN /bin/bash -c  'echo ${sql3}'
#RUN service mysql start &&\
RUN chown -R mysql:mysql /var/lib/mysql
#RUN /etc/init.d/mysql start &&\
#    mysql -e "${sql1}"&&\
#    mysql -e "${sql2}"&&\
#    mysql -e "update mysql.user set plugin='mysql_native_password' where host='localhost' and user='root';"&&\
#    mysql -e "FLUSH PRIVILEGES;"&&\
#    mysql -e "${sql3};FLUSH PRIVILEGES;"&&\
#    mysql -uroot -p${pwd} -e "show databases;"


#RUN service mysql start &&\

#    mysql -u root -p123456 -e "source /root/init.sql;"  
# 镜像暴露3306 8080 端口；
EXPOSE 3306
EXPOSE 8080

#ENV pwd 0
#set environment variable
#Java Env
ENV JAVA_HOME /root/software/jdk1.8.0_191
ENV JRE_HOME ${JAVA_HOME}/jre
ENV CLASSPATH .:${JAVA_HOME}/lib/dt.jar:${JAVA_HOME}/lib/tools.jar
ENV PATH $PATH:${JAVA_HOME}/bin
#tomcat
ENV TOMCAT_HOME /root/software/apache-tomcat-9.0.13


# 容器启动后执行以下命令，启动mysql；
#CMD ["/usr/bin/mysqld_safe"]
RUN chmod 700 /root/setup.sh

#CMD ["echo"]

#define entry point which will be run first when the container starts up

#ENTRYPOINT /root/setup.sh
