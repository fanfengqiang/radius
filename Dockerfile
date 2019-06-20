FROM centos:7

RUN yum install wget -y \
    && yum -y install kde-l10n-Chinese && yum -y reinstall glibc-common \
    && localedef -c -f UTF-8 -i zh_CN zh_CN.utf8 \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && rm -rf /etc/yum.repos.d/* \
    && wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo \
    && yum install -y freeradius freeradius-sqlite freeradius-utils bash-completion vim  \
    && yum clean all && rm -rf /var/cache/yum

ENV LC_ALL=en_US.UTF-8 LC_CTYPE=en_US.UTF-8

ENV SECRET=testing123 \
    DATABASE="users.db"

RUN sed -i "s@secret = testing123@secret = ${SECRET}@" /etc/raddb/clients.conf \
    && ln -s /etc/raddb/mods-available/sql /etc/raddb/mods-enabled/ \
    && chgrp -h radiusd /etc/raddb/mods-enabled/sql \
    && sed -i 's@driver = "rlm_sql_null"@driver = "rlm_sql_sqlite"@' /etc/raddb/mods-available/sql \
    && sed -i '40,52s@^#@@' /etc/raddb/mods-available/sql \
    && mkdir -p /etc/raddb/database \
    && sed -i "s@filename = \"/tmp/freeradius.db\"@filename = \"/etc/raddb/database/sqlite/${DATABASE}\"@" /etc/raddb/mods-available/sql 

CMD ["/usr/sbin/radiusd","-X"]
