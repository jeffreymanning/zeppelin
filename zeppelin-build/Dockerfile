FROM jeffreymanning/sparkr-base

MAINTAINER Jeff Manning
USER root

# we inherit USER root from centois-base
# create a zeppelin user (non-root) to execute our build (and run zeppelin?)
RUN groupadd -r zeppelin && useradd --no-log-init -r -g zeppelin zeppelin
RUN usermod -aG wheel zeppelin
RUN useradd --no-log-init -g zeppelin zeppelin-build
RUN usermod -aG wheel zeppelin-build
RUN usermod -aG staff zeppelin
RUN usermod -aG staff zeppelin-build

# libfontconfig is a workaround for
# https://github.com/karma-runner/karma/issues/1270, which caused a
# build break similar to
# https://www.mail-archive.com/users@zeppelin.incubator.apache.org/msg01586.html
RUN yum clean all
RUN yum -y update && yum clean all
RUN yum -y install gcc-c++ make && \
    yum -y groupinstall 'Development Tools' && \
    yum clean all

# pre-reqs Node andnpm
# latest: http://nodejs.org/dist/latest/node-v8.4.0-linux-x64.tar.gz
# zep's: https://nodejs.org/dist/v6.9.1/node-v6.9.1-linux-x64.tar.gz
RUN cd /opt && \
    curl  https://nodejs.org/dist/v6.9.1/node-v6.9.1-linux-x64.tar.gz  \
    | gunzip \
    | tar -x && \
    ln -s node-v6.9.1-linux-x64 nodejs

# setup the environment variables
ENV PATH=$PATH:/opt/nodejs/bin
RUN npm config set strict-ssl false && \
    npm config rm proxy && \
    npm config rm https-proxy && \
    npm config set registry "http://registry.npmjs.org/" && \
    npm install npm@latest -g
RUN npm version
#RUN npm install -g bower@latest
#RUN bower -v
#RUN npm install -g yarn-install

# setup yarn
RUN cd /opt && \
    mkdir yarn-v0.18.1 && \
    wget https://github.com/yarnpkg/yarn/releases/download/v0.18.1/yarn-v0.18.1.tar.gz && \
    gunzip yarn-v0.18.1.tar.gz && \
    tar -xf yarn-v0.18.1.tar -C ./yarn-v0.18.1 --strip-components 1 && \
    ln -s yarn-v0.18.1 yarn && \
    rm yarn-v0.18.1.tar
ENV PATH=$PATH:/opt/yarn/bin
#RUN yarn version

RUN cd /opt && \
    mkdir phantomjs-2.1.1-linux-x86_64 && \
    wget https://github.com/Medium/phantomjs/releases/download/v2.1.1/phantomjs-2.1.1-linux-x86_64.tar.bz2 && \
    tar -xjvf phantomjs-2.1.1-linux-x86_64.tar.bz2 -C ./phantomjs-2.1.1-linux-x86_64 --strip-components 1 && \
    ln -s phantomjs-2.1.1-linux-x86_64 phantomjs && \
    rm phantomjs-2.1.1-linux-x86_64.tar.bz2
ENV PATH=$PATH:/opt/phantomjs/bin

# node and npm version 2...
#RUN curl -sL https://rpm.nodesource.com/setup_8.x | sudo -E bash -
#RUN yum install nodejs
#RUN node --version

# update some needed python packages
#RUN curl https://bootstrap.pypa.io/get-pip.py > /tmp/get-pip.py && python /tmp/get-pip.py && pip install -U pip
#RUN pip install numpy pandasql scipy
#
##RUN yum -y install epel-release gcc gcc-c++ make && yum clean all
##RUN yum install -y nodejs npm --enablerepo=epel --skip-broken && yum clean all
#
##RUN yum -y install gcc gcc-c++ make && yum clean all
###RUN wget http://nodejs.org/dist/latest-v0.10.x/node-v0.10.48-linux-x64.tar.gz -O /tmp/node-v0.10.48-linux-x64.tar.gz && \
###    tar --strip-components 1 -xzvf /tmp/node-v* -C /usr/local
#
#
## hack to get aroud some cookie issues with maven downloads
## Configuration BLOCK
## Configure Spark
COPY scripts /tmp/scripts
RUN [ "bash", "-x", "/tmp/scripts/install.sh" ]

#cleanp scripts
RUN rm -rf /tmp/scripts

#RUN git config --global --unset http.proxy
#RUN git config --global --unset https.proxy
# this is not docker image is not meant to be run...  it is a base layer
# co-ordinate with spark-base

USER zeppelin-build

# build it
ARG SPARK_MAJOR=2.1
ARG HADOOP_MAJOR=2.7
ARG SCALA_VER=2.11
USER zeppelin-build
ARG ZEPPELIN_REPO=https://github.com/apache/zeppelin.git
ARG ZEPPELIN_TAG=v0.7.2
ENV MAVEN_OPTS="-Xmx2g"

# not using hadoop...         -Phadoop-${HADOOP_MAJOR} \         -Ppyspark \
# -pl 'zeppelin-interpreter,zeppelin-zengine,zeppelin-display,spark-dependencies,spark,markdown,angular,shell,jdbc,python,zeppelin-web,zeppelin-server,zeppelin-distribution' \
RUN git clone ${ZEPPELIN_REPO} -b ${ZEPPELIN_TAG} /tmp/zeppelin
RUN cd /tmp/zeppelin && \
    ./dev/change_scala_version.sh 2.11 && \
    mvn clean package \
        -Pbuild-distr \
        -Pspark-${SPARK_MAJOR} \
        -Pscala-${SCALA_VER} \
        -Pr \
        -pl 'zeppelin-interpreter,zeppelin-zengine,zeppelin-display,zeppelin-web,zeppelin-server,zeppelin-distributiospark,r,markdown,angular,shell,jdbc,python' \
        -DskipTests && \
    echo "Successfully built Zeppelin"

#RUN cd /tmp/zeppelin/zeppelin-distribution/target/zeppelin-* && \
#  mv zeppelin-*.tar zeppelin && \
#  tar cvzf /zeppelin.tgz zeppelin
RUN cp /tmp/zeppelin/zeppelin-distribution/target/zeppelin-*.tar.gz /tmp/zeppelin
#### Define default command.
#CMD ["bash"]

