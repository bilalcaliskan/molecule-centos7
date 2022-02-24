FROM centos:7

MAINTAINER bilalcaliskan
ENV container=docker
ENV YUM_PACKAGES "sudo which openssl-devel libffi-devel bzip2-devel wget"
ENV PIP_PACKAGES "pip ansible==2.9.16"

RUN yum -y update; yum clean all; \
    (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
    rm -f /lib/systemd/system/multi-user.target.wants/* \
        /etc/systemd/system/*.wants/* \
        /lib/systemd/system/local-fs.target.wants/* \
        /lib/systemd/system/sockets.target.wants/*udev* \
        /lib/systemd/system/sockets.target.wants/*initctl* \
        /lib/systemd/system/basic.target.wants/* \
        /lib/systemd/system/anaconda.target.wants/*
RUN yum makecache fast \
    && yum groupinstall -y "Development Tools" \
    && yum install -y deltarpm epel-release initscripts \
    && yum update -y \
    && yum install -y $YUM_PACKAGES \
    && yum clean all

WORKDIR /opt
RUN wget https://www.python.org/ftp/python/3.9.10/Python-3.9.10.tgz \
    && tar -xvf Python-3.9.10.tgz
WORKDIR /opt/Python-3.9.10
RUN ./configure --enable-optimizations
RUN make altinstall
RUN ln -s /usr/local/bin/python3.9 /usr/bin/python3
#RUN python3 -m pip install --upgrade $PIP_PACKAGES \
#    && python3 -m pip install --upgrade 
RUN python3 -m pip install --upgrade $PIP_PACKAGES

WORKDIR /root
RUN sed -i -e 's/^\(Defaults\s*requiretty\)/#--- \1/'  /etc/sudoers
RUN mkdir -p /etc/ansible
RUN echo -e '[local]\nlocalhost ansible_connection=local' > /etc/ansible/hosts
VOLUME ["/sys/fs/cgroup"]
CMD ["/usr/lib/systemd/systemd"]
