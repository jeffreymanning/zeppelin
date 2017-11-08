## Use provided spark installation ##
## defining SPARK_HOME makes Zeppelin run spark interpreter process using spark-submit
##
## spark-base defines this environment variable
## SPARK_HOME, When it is defined, load it instead of Zeppelin embedded Spark libraries
##
## this will eliminate zeppelin/spark version  mismatches (typically on connect)
# update... building off spark base increses the size of the image to over 5G  This is huge
# Use default zeppelin spark dependencies
FROM jeffreymanning/sparkr-base

LABEL maintainer="JWM" \
      vendor="MITRE Corp" \
      version="0.7" \
      release="3" \
      summary="MITRE's base Zeppelin, R, Spark image - 0.7.3/3.4.x/2.1.1 API node" \
      description="Centos7, Zeppelin, Spark, R typically used for API nodes" \
### Required labels above - recommended below
      io.k8s.description="Centos, Zeppelin, R, Spark, Spark-R base API node image" \
      io.k8s.display-name="centos, Zeppelin, Spark-R API node image" \
      io.openshift.expose-services="Zeppelin" \
      io.openshift.tags="centos7,Zeppelin,Spark,R,java,maven"

# well, this needs to be addressed...
# allow containers withs with USER root to getr root privs
# requires:
# oc admin policy add-scc-to-user anyuid -z default -n <namespace installed into>
USER root

#install the basic packages
RUN yum clean all -y && \
    echo "update and install basic packages" && \
    yum -y update && \
    INSTALL_BASE_PKGS="grep sed bzip2 ca-certificates zlib zlib-devel" && \
    yum -y install --setopt=tsflags=nodocs ${INSTALL_BASE_PKGS}  && \
    yum -y --setopt=tsflags=nodocs groupinstall 'Development Tools' && \
# X11
    INSTALL_X11_PKGS="libX11 libX11-devel libXt libXt-devel libXmu libXmu-devel libXrender libXrender-devel libXext libXext-devel libSM libSM-devel glib glib-devel" && \
    yum install -y --setopt=tsflags=nodocs ${INSTALL_X11_PKGS} && \
# various libraries
    INSTALL_LIBS_PKGS="readline readline-devel pcre pcre-devel libjpeg-turbo libjpeg-devel libpng libpng-devel libtiff libtiff-devel lzma lzma-devel cairo cairo-devel" && \
    yum install -y --setopt=tsflags=nodocs ${INSTALL_LIBS_PKGS} && \
    INSTALL_FONTS_PKGS="freetype freetype-devel libXft libXft-devel libxml2 libxml2-devel libxslt libxslt-devel" && \
    yum install -y --setopt=tsflags=nodocs ${INSTALL_FONTS_PKGS} && \
# openssl -  moved to centos7-base
    INSTALL_SYSTEM_PKGS="openssl openssl-devel libcurl libcurl-devel" && \
    yum install -y --setopt=tsflags=nodocs ${INSTALL_SYSTEM_PKGS} && \
#    echo "install conda before numpy, matplotlib,..." && \
#    echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
#    wget --quiet https://repo.continuum.io/miniconda/Miniconda2-4.3.30-Linux-x86_64.sh -O ~/miniconda.sh && \
#    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
#    rm ~/miniconda.sh
# ENV PATH /opt/conda/bin:$PATH

    echo "update and install python packages" && \
    INSTALL_PY_PKGS="python-setuptools python-devel python-boto libfontconfig tkinter" && \
    yum -y install --setopt=tsflags=nodocs ${INSTALL_PY_PKGS}


RUN echo "nodejs install" && \
    curl --silent --location https://rpm.nodesource.com/setup_6.x | bash - && \
    yum -y install nodejs && \
    yum -y clean all && \
    rm -rf /var/cache/yum

RUN node -v && \
    npm -v && \
    npm cache clean && \
#    npm install n -g && \
#    npm update -g npm && \
    npm config set strict-ssl false && \
    npm config rm proxy && \
    npm config rm https-proxy && \
    npm config set registry "http://registry.npmjs.org/"
#    npm install -g yarn types typescript
#    npm install -g bower
#    yum erase -y nodejs npm && \

# requirements
###python
#COPY requirements.txt /tmp
#RUN pip install -r /tmp/requirements.txt
RUN curl https://bootstrap.pypa.io/get-pip.py > /tmp/get-pip.py && python /tmp/get-pip.py && pip install -U pip && \
    pip install numpy pandasql scipy matplotlib jupyter grpcio

### Host Arguments
# zeppelin
ARG ZEPPELIN_MAJOR_VERSION=0
ARG ZEPPELIN_UPDATE_VERSION=7
ARG ZEPPELIN_BUILD_NUMBER=3
ARG ZEPPELIN_VERSION=${ZEPPELIN_MAJOR_VERSION}.${ZEPPELIN_UPDATE_VERSION}.${ZEPPELIN_BUILD_NUMBER}
ARG ZEPPELIN_DOWNLOAD_URL=https://www.apache.org/dist/zeppelin
ARG ZEPPELIN_INSTALL_DIR=/opt

## which distribution to down load
ARG ZEPPELIN_ALL_PKG_NAME=zeppelin-${ZEPPELIN_VERSION}-bin-all
ARG ZEPPELIN_MIN_PKG_NAME=zeppelin-${ZEPPELIN_VERSION}-bin-netinst
ARG ZEPPELIN_PKG_NAME=${ZEPPELIN_MIN_PKG_NAME}

### Host environment
ENV ZEPPELIN_HOME=${ZEPPELIN_INSTALL_DIR}/zeppelin
ENV ZEPPELIN_CONF_DIR=${ZEPPELIN_HOME}/conf
ENV ZEPPELIN_DATA_DIR=${ZEPPELIN_HOME}/data
ENV ZEPPELIN_NOTEBOOK_DIR=${ZEPPELIN_HOME}/notebook
ENV ZEPPELIN_PID_DIR=${ZEPPELIN_HOME}/run
ENV ZEPPELIN_LOG_DIR=${ZEPPELIN_HOME}/logs
ENV ZEPPELIN_SPARK_USEHIVECONTEXT=false
ENV ZEPPELIN_R_KNITR=false

###  Start of Installation

#### ---- Zeppelin Installation -----
WORKDIR ${ZEPPELIN_INSTALL_DIR}

#### ---- (Deployment mode use) Zeppelin Installation (Download from Internet -- Deployment) ----
RUN wget -c ${ZEPPELIN_DOWNLOAD_URL}/zeppelin-${ZEPPELIN_VERSION}/${ZEPPELIN_PKG_NAME}.tgz && \
    tar xvf ${ZEPPELIN_PKG_NAME}.tgz && \
    ln -s ${ZEPPELIN_PKG_NAME} zeppelin && \
    rm -f ${ZEPPELIN_PKG_NAME}.tgz && \
    mkdir -p ${ZEPPELIN_HOME}/logs && \
    chmod a+rw ${ZEPPELIN_HOME}/logs && \
    mkdir -p ${ZEPPELIN_HOME}/run && \
    chmod a+rw ${ZEPPELIN_HOME}/run && \
    mkdir -p ${ZEPPELIN_HOME}/data && \
    chmod a+rw ${ZEPPELIN_HOME}/data

### change the ownership
# change ownership to the spark process (non-root)
#RUN groupadd -r zeppelin && useradd --no-log-init -r -g zeppelin zeppelin
#RUN usermod -aG wheel zeppelin
#RUN usermod -aG staff zeppelin
#RUN chown -R -L zeppelin:zeppelin ${ZEPPELIN_HOME}
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
#    chown -R -L ${USER_NAME}:root  ${ZEPPELIN_HOME} && \
    chown -R -L spark:root  ${ZEPPELIN_HOME}

#### Define default command.
VOLUME ${ZEPPELIN_HOME}/notebook
VOLUME ${ZEPPELIN_HOME}/conf
VOLUME ${ZEPPELIN_HOME}/data

# set the working directory
#USER zeppelin
#USER spark

# Make the default PWD somewhere that the user can write. This is
# useful when connecting with 'oc run' and starting a 'spark-shell',
# which will likely try to create files and directories in PWD and
# error out if it cannot.
#WORKDIR /tmp
WORKDIR ${ZEPPELIN_HOME}
CMD ["bin/zeppelin.sh"]

