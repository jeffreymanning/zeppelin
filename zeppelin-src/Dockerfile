## Use provided spark installation ##
## defining SPARK_HOME makes Zeppelin run spark interpreter process using spark-submit
##
## spark-base defines this environment variable
## SPARK_HOME, When it is defined, load it instead of Zeppelin embedded Spark libraries
##
## this will eliminate zeppelin/spark version  mismatches (typically on connect)
FROM jeffreymanning/sparkr-base

MAINTAINER Jeff Manning

# well, this needs to be addressed...
# allow containers withs with USER root to getr root privs
# requires:
# oc admin policy add-scc-to-user anyuid -z default -n <namespace installed into>
USER root

#install the basic packages
RUN yum clean all && rm -rf /var/cache/yum
RUN yum -y update && yum clean all
RUN yum -y install gcc-c++ make && \
    yum -y groupinstall 'Development Tools' && \
    yum clean all && rm -rf /var/cache/yum

# from centos: tar curl net-tools build-essential git wget zip unzip vim
# pre-reqs
#RUN yum -y install wget gcc openssl openssl-devel python-setuptools python-devel python-boto npm numpy libfontconfig  && yum clean all
#RUN curl https://bootstrap.pypa.io/get-pip.py > /tmp/get-pip.py && python /tmp/get-pip.py && pip install -U pip
# requirements
###python
RUN curl https://bootstrap.pypa.io/get-pip.py > /tmp/get-pip.py && python /tmp/get-pip.py && pip install -U pip
RUN pip install numpy pandasql scipy

#COPY requirements.txt /tmp
#RUN pip install -r /tmp/requirements.txt

ARG ZEPPELIN_MAJOR_VERSION=0
ARG ZEPPELIN_UPDATE_VERSION=8
ARG ZEPPELIN_BUILD_NUMBER=0-SNAPSHOT
ARG ZEPPELIN_VERSION=${ZEPPELIN_MAJOR_VERSION}.${ZEPPELIN_UPDATE_VERSION}.${ZEPPELIN_BUILD_NUMBER}
ARG ZEPPELIN_PKG_NAME=zeppelin-${ZEPPELIN_VERSION}

# first off package up (ifexists) the build zeppelin  distribution
COPY ./zeppelin-dist/${ZEPPELIN_PKG_NAME}.tar.gz /tmp

### Host Arguments
# zeppelin
ARG ZEPPELIN_TAR=/tmp
ARG ZEPPELIN_INSTALL_DIR=/opt

### Host environment
ENV ZEPPELIN_HOME=${ZEPPELIN_INSTALL_DIR}/zeppelin
ENV ZEPPELIN_CONF_DIR=${ZEPPELIN_HOME}/conf
ENV ZEPPELIN_DATA_DIR=${ZEPPELIN_HOME}/data
ENV ZEPPELIN_NOTEBOOK_DIR=${ZEPPELIN_HOME}/notebook
ENV ZEPPELIN_PID_DIR=${ZEPPELIN_HOME}/run
ENV ZEPPELIN_LOG_DIR=${ZEPPELIN_HOME}/logs
ENV ZEPPELIN_SPARK_USEHIVECONTEXT=false

###  Start of Installation

#### ---- Zeppelin Installation -----
WORKDIR ${ZEPPELIN_INSTALL_DIR}

#### ---- (Deployment mode use) Zeppelin Installation (Download from Internet -- Deployment) ----
RUN tar xvf ${ZEPPELIN_TAR}/${ZEPPELIN_PKG_NAME}.tar.gz \
    && ln -s ${ZEPPELIN_PKG_NAME} zeppelin \
    && rm ${ZEPPELIN_TAR}/${ZEPPELIN_PKG_NAME}.tar.gz

RUN mkdir -p ${ZEPPELIN_HOME}/logs  \
    && mkdir -p ${ZEPPELIN_HOME}/run  \
    && mkdir -p ${ZEPPELIN_HOME}/data

### change the ownership
# change ownership to the spark process (non-root)
RUN groupadd -r zeppelin && useradd --no-log-init -r -g zeppelin zeppelin
RUN usermod -aG wheel zeppelin
RUN usermod -aG staff zeppelin
RUN chown -R -L zeppelin:zeppelin ${ZEPPELIN_HOME}



#### Define default command.
VOLUME ${ZEPPELIN_HOME}/notebook
VOLUME ${ZEPPELIN_HOME}/conf
VOLUME ${ZEPPELIN_HOME}/data

# set the working directory
USER zeppelin

# Make the default PWD somewhere that the user can write. This is
# useful when connecting with 'oc run' and starting a 'spark-shell',
# which will likely try to create files and directories in PWD and
# error out if it cannot.
#WORKDIR /tmp
WORKDIR ${ZEPPELIN_HOME}

CMD ["/opt/zeppelin/bin/zeppelin.sh"]

