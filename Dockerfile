FROM centos:7

LABEL maintainer="bilalcaliskan"
ENV container=docker
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN yum -y update; yum clean all; \
(cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;
RUN yum makecache fast \
    && yum -y install deltarpm epel-release initscripts \
    && yum -y update \
    && yum -y install \
        sudo \
        which \
        python3 \
        python3-pip \
    && yum clean all
RUN pip3 install --upgrade pip && pip3 install --upgrade ansible==2.9.16
RUN sed -i -e 's/^\(Defaults\s*requiretty\)/#--- \1/'  /etc/sudoers
RUN mkdir -p /etc/ansible
RUN echo -e '[local]\nlocalhost ansible_connection=local' > /etc/ansible/hosts
RUN echo "[defaults]\ninterpreter_python=/usr/bin/python3" > /etc/ansible/ansible.cfg

WORKDIR /root
VOLUME ["/sys/fs/cgroup"]
CMD ["/usr/lib/systemd/systemd"]