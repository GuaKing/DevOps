FROM ubuntu:bionic AS DIB-env

COPY sources.list /etc/apt/
RUN apt-get update 
RUN apt-get install -y python-pip
RUN apt-get install -y git
RUN apt-get install -y qemu-utils
RUN apt-get install -y kpartx


# Install python packages
RUN pip install --upgrade pip
RUN pip install networkx -i http://pypi.douban.com/simple --trusted-host pypi.douban.com
RUN pip install diskimage-builder -i http://pypi.douban.com/simple --trusted-host pypi.douban.com

ENV TEST_PATH=/vob_test
RUN mkdir -p ${TEST_PATH}
COPY jialing.tar.gz ${TEST_PATH}
WORKDIR ${TEST_PATH}
RUN tar zxvf jialing.tar.gz

RUN apt-get install -y sudo
RUN apt-get install -y curl
RUN rm -f jialing.tar.gz

RUN mkdir -p /temp/image_cache2
RUN cp ${TEST_PATH}/ubuntu-image/ubuntu-20.04-server-cloudimg-amd64.squashfs  /temp/image_cache2/

RUN apt-get install -y squashfs-tools


