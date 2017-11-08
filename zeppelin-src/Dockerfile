## Use provided spark installation ##
## defining SPARK_HOME makes Zeppelin run spark interpreter process using spark-submit
##
## spark-base defines this environment variable
## SPARK_HOME, When it is defined, load it instead of Zeppelin embedded Spark libraries
##
## this will eliminate zeppelin/spark version  mismatches (typically on connect)
# see https://github.com/1ambda/docker-zeppelin/blob/master/base/Dockerfile
# see https://nodejs.org/en/download/package-manager/#enterprise-linux-and-fedora

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
# oc adm policy add-scc-to-user privileged -z default -n test

USER root

#install the basic packages
#RUN yum clean all && \
#    yum -y update && \
#    yum clean all -y

# pre-reqs
RUN yum clean all -y && \
    echo "update and install basic packages" && \
    yum -y update && \
# to plot, i.e. matplot etc, requires X windows (withn no gui)
#    yum -y --setopt=tsflags=nodocs groupinstall 'X Window System' && \
    INSTALL_BASE_PKGS="grep sed bzip2" && \
    yum -y install --setopt=tsflags=nodocs ${INSTALL_BASE_PKGS} && \
#    yum -y --setopt=tsflags=nodocs groupinstall 'Development Tools' && \
    yum -y clean all && \
    rm -rf /var/cache/yum

# these are big...
#RUN echo "install conda before numpy, matplotlib,..." && \
#    echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
##    wget --quiet https://repo.continuum.io/archive/Anaconda2-5.0.1-Linux-x86_64.sh -O ~/anaconda.sh && \
#    wget --quiet https://repo.continuum.io/miniconda/Miniconda2-4.3.30-Linux-x86_64.sh -O ~/miniconda.sh && \
#    /bin/bash ~/anaconda.sh -b -p /opt/conda && \
#    rm ~/anaconda.sh
#ENV PATH /opt/conda/bin:$PATH
# see https://nodejs.org/en/download/package-manager/#enterprise-linux-and-fedora
RUN echo "nodejs install" && \
    curl https://rpm.nodesource.com/setup_6.x | bash - && \
    yum -y install nodejs && \
    yum -y clean all && \
    rm -rf /var/cache/yum

# configure npm
#   see https://hub.docker.com/r/ietty/centos7-npm/~/dockerfile/
#RUN node -v && \
#    npm -v && \
#    npm cache verify && \
##    npm cache clean && \
##    npm install n -g && \
##    npm update -g npm && \
#    npm config set strict-ssl false && \
#    npm config rm proxy && \
#    npm config rm https-proxy
##    npm config set registry "http://registry.npmjs.org/"
##    npm install -g yarn types typescript
##    npm install -g bower
##    yum erase -y nodejs npm && \

###python - we use pip to install our packages
RUN echo "update and install python packages" && \
    INSTALL_PY_PKGS="python-setuptools python-devel python-boto libfontconfig" && \
    yum -y install --setopt=tsflags=nodocs ${INSTALL_PY_PKGS}

RUN curl https://bootstrap.pypa.io/get-pip.py > /tmp/get-pip.py && python /tmp/get-pip.py && pip install -U pip && \
    pip install numpy pandasql scipy matplotlib jupyter grpcio py4j plotly
## additional packages
RUN /usr/bin/Rscript --slave --no-save --no-restore-history -e "install.packages('googleVis', repos='http://cran.us.r-project.org')" && \
    /usr/bin/Rscript --slave --no-save --no-restore-history -e "install.packages(pkgs=c('Rcpp'), repos='http://cran.us.r-project.org')" && \
    /usr/bin/Rscript --slave --no-save --no-restore-history -e "library('devtools'); library('Rcpp'); install_github('ramnathv/rCharts')" && \
    /usr/bin/Rscript --slave --no-save --no-restore-history -e "require(devtools); devtools::install('${SPARK_HOME}/R/lib/SparkR')"

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

ENV PYTHONPATH="${ZEPPELIN_HOME}/interpreter/lib/python:${PYTHONPATH}"

### change the ownership
# change ownership to the spark process (non-root)
# initial group is root, then add accordingly
#
# need to get umask set to 002; therefore id -un must equal id -gn (/etc/profile) and
# must also be in group root
ENV USER_NAME=zeppelin
ENV USER_UID=1003
RUN groupadd -g ${USER_UID} ${USER_NAME}  && \
#    useradd --no-log-init -r -g 0 zeppelin && \
#    useradd --no-log-init -s /bin/false -d ${ZEPPELIN_HOME} -u 1001 -g zeppelin zeppelin && \
    useradd -u ${USER_UID}  -g ${USER_NAME} ${USER_NAME} && \
    usermod -aG wheel ${USER_NAME}  && \
#    usermod -aG staff ${USER_NAME}  && \
#    usermod -aG zeppelin zeppelin && \
    usermod -aG root ${USER_NAME}  && \
    usermod -aG default ${USER_NAME}  && \
#    chown -R -L ${USER_NAME}:${USER_NAME}  ${ZEPPELIN_HOME} && \
    chown -R -L spark:root  ${ZEPPELIN_HOME} && \
    chmod g+wx ${ZEPPELIN_HOME}/data



#### Define defauchmod g+wxlt command.
VOLUME ${ZEPPELIN_HOME}/notebook
VOLUME ${ZEPPELIN_HOME}/conf
VOLUME ${ZEPPELIN_HOME}/data

# Make the default PWD somewhere that the user can write. This is
# useful when connecting with 'oc run' and starting a 'spark-shell',
# which will likely try to create files and directories in PWD and
# error out if it cannot.
#WORKDIR /tmp
WORKDIR ${ZEPPELIN_HOME}
# set the working directory
#USER zeppelin
USER spark
CMD ["bin/zeppelin.sh"]

