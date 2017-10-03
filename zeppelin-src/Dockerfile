## Use provided spark installation ##
## defining SPARK_HOME makes Zeppelin run spark interpreter process using spark-submit
##
## spark-base defines this environment variable
## SPARK_HOME, When it is defined, load it instead of Zeppelin embedded Spark libraries
##
## this will eliminate zeppelin/spark version  mismatches (typically on connect)
FROM jeffreymanning/sparkr-base

LABEL maintainer="JWM" \
      vendor="MITRE Corp" \
      version="0.8" \
      release="0" \
      summary="MITRE's base Zeppelin, Spark-R image - 0.8.0/3.4.x/2.1.1 API node" \
      description="Centos7, Zeppelin, Spark, R typically used for API nodes" \
### Required labels above - recommended below
      io.k8s.description="Centos, Zeppelin, Spark-R base API node image" \
      io.k8s.display-name="centos, Zeppelin, Spark-R API node image" \
      io.openshift.expose-services="Zeppelin" \
      io.openshift.tags="centos7,Zeppelin,Spark,R,java,maven"

# well, this needs to be addressed...
# allow containers withs with USER root to getr root privs
# requires:
# oc admin policy add-scc-to-user anyuid -z default -n <namespace installed into>
USER root

#install the basic packages
RUN yum clean all && \
    yum -y update && \
    yum clean all -y

RUN INSTALL_PKGS="gcc-c++ make" && \
    yum -y install --setopt=tsflags=nodocs ${INSTALL_PKGS} && \
    yum -y --setopt=tsflags=nodocs groupinstall 'Development Tools' && \
    yum clean all -y && \
    rm -rf /var/cache/yum

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
# initial group is root, then add accordingly
#
# need to get umask set to 002; therefore id -un must equal id -gn (/etc/profile) and
# must also be in group root
ENV USER_NAME=zeppelin
ENV USER_UID=1003
RUN groupadd -r ${USER_NAME}  && \
#    useradd --no-log-init -r -g 0 zeppelin && \
#    useradd --no-log-init -s /bin/false -d ${ZEPPELIN_HOME} -u 1001 -g zeppelin zeppelin && \
    useradd -u ${USER_UID}  -g ${USER_NAME} ${USER_NAME} && \
    usermod -aG wheel ${USER_NAME}  && \
    usermod -aG staff ${USER_NAME}  && \
#    usermod -aG zeppelin zeppelin && \
    usermod -aG root ${USER_NAME}  && \
#    chown -R -L ${USER_NAME}:${USER_NAME}  ${ZEPPELIN_HOME} && \
    chown -R -L spark:root  ${ZEPPELIN_HOME} && \
    chmod g+wx ${ZEPPELIN_HOME}/data



#### Define defauchmod g+wxlt command.
VOLUME ${ZEPPELIN_HOME}/notebook
VOLUME ${ZEPPELIN_HOME}/conf
VOLUME ${ZEPPELIN_HOME}/data

# set the working directory
#USER zeppelin
USER spark

# Make the default PWD somewhere that the user can write. This is
# useful when connecting with 'oc run' and starting a 'spark-shell',
# which will likely try to create files and directories in PWD and
# error out if it cannot.
#WORKDIR /tmp
WORKDIR ${ZEPPELIN_HOME}

CMD ["/opt/zeppelin/bin/zeppelin.sh"]

