FROM ubuntu:xenial

USER root

# install only the packages that are needed
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    software-properties-common python-software-properties \
    ca-certificates \
    git \
    make \
    libnetcdff-dev \
    liblapack-dev \
    vim \
	zip \
	unzip

# install gfortran-6
RUN add-apt-repository ppa:ubuntu-toolchain-r/test -y \
    && apt-get update \
    && apt-get install -y --no-install-recommends gfortran-6 \
    && apt-get clean

COPY summa/* ./

# set environment variables for docker build
ENV F_MASTER /code/summa
ENV FC gfortran
ENV FC_EXE gfortran
ENV FC_ENV gfortran-6-docker

# add code directory
WORKDIR /code
ADD . /code

# fetch tags and build summa
RUN git fetch --tags && make -C /code/summa/build/ -f Makefile

# install the notebook package
RUN apt-get install -y python3.7 python-pip
#RUN apt-get update \
#    apt-get install python3-pip
#RUN pip install --no-cache --upgrade pip && \
#    pip install --no-cache notebook

RUN pip install --upgrade pip setuptools wheel 
RUN git clone https://github.com/uva-hydroinformatics/pysumma.git 
RUN cd pysumma && pip3 install .

USER $NB_USER

WORKDIR /home/$NB_USER

WORKDIR /home/$NB_USER/work

# there is some problem or bug with permissions
USER root
RUN chown -R $NB_USER:users .
USER $NB_USER

# run summa when running the docker image
#WORKDIR bin
#ENTRYPOINT ["./summa.exe"]
