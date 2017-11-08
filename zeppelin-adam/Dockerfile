## Use provided spark installation ##
## defining SPARK_HOME makes Zeppelin run spark interpreter process using spark-submit
##
## spark-base defines this environment variable
## SPARK_HOME, When it is defined, load it instead of Zeppelin embedded Spark libraries
##
## this will eliminate zeppelin/spark version  mismatches (typically on connect)
# see https://github.com/1ambda/docker-zeppelin/blob/master/base/Dockerfile
# see https://nodejs.org/en/download/package-manager/#enterprise-linux-and-fedora

FROM jeffreymanning/zeppelin-src

LABEL maintainer="JWM" \
      vendor="MITRE Corp" \
      version="0.23" \
      release="0" \
      summary="MITRE's base Zeppelin, Spark-R, ADAM (bio packaage) image - 0.8.0/3.4.x, 2.1.1/0.23.0(master) API node" \
      description="Centos7, Zeppelin, Spark, R, ADAM typically used for BIO Stats API nodes" \
### Required labels above - recommended below
      io.k8s.description="Centos, Zeppelin, Spark-R, ADAM base API node image" \
      io.k8s.display-name="centos, Zeppelin, Spark-R, ADAM API node image" \
      io.openshift.expose-services="Zeppelin-adam" \
      io.openshift.tags="centos7,Zeppelin,Spark,R,java,maven,ADAM"

# well, this needs to be addressed...
# allow containers withs with USER root to getr root privs
# requires:
# oc admin policy add-scc-to-user anyuid -z default -n <namespace installed into>
USER root

#install the basic packages
#RUN yum clean all && \
#    yum -y update && \
#    yum clean all -y

# pre-reqs
RUN yum clean all -y && \
    echo "update packages" && \
    yum -y update && \
    yum -y clean all && \
    rm -rf /var/cache/yum

# remove jre and update to jdk
### Install Java 8
#### Per version variables (Need to find out from http://java.oracle.com site for every update)
ARG JAVA_MAJOR_VERSION=8
ARG JAVA_UPDATE_VERSION=151
ARG JAVA_BUILD_NUMBER=12
ARG JAVA_TOKEN=e758a0de34e24606bca991d704f6dcbf
ARG UPDATE_VERSION=${JAVA_MAJOR_VERSION}u${JAVA_UPDATE_VERSION}
ARG BUILD_VERSION=b${JAVA_BUILD_NUMBER}
ARG JAVA_JDK_HREF_ROOT="http://download.oracle.com/otn-pub/java/jdk/${UPDATE_VERSION}-${BUILD_VERSION}/${JAVA_TOKEN}"

#jdk, jre picker
ARG JAVA_JDK_DOWNLOAD=jdk-${UPDATE_VERSION}-linux-x64.tar.gz
ARG JAVA_JRE_DOWNLOAD=server-jre-${UPDATE_VERSION}-linux-x64.tar.gz
ARG JAVA_DOWNLOAD=${JAVA_JDK_DOWNLOAD}

ENV JAVA_HOME /usr/jdk1.${JAVA_MAJOR_VERSION}.0_${JAVA_UPDATE_VERSION}
ENV PATH $PATH:$JAVA_HOME/bin
ENV INSTALL_DIR /usr
RUN rm -rf /usr/jdk1.${JAVA_MAJOR_VERSION}.0_${JAVA_UPDATE_VERSION} && \
    rm -rf /usr/java && \
    JAVA_DOWNLOAD=${JAVA_JDK_DOWNLOAD} && \
# currently re-set for jdk install
    echo "getting jdk: ${JAVA_JDK_HREF_ROOT}/${JAVA_DOWNLOAD}" && \
    curl -sL --retry 3 --insecure \
    --header "Cookie: oraclelicense=accept-securebackup-cookie;" \
    "${JAVA_JDK_HREF_ROOT}/${JAVA_DOWNLOAD}" \
    | gunzip \
    | tar x -C $INSTALL_DIR/ \
    && ln -s $JAVA_HOME $INSTALL_DIR/java \
    && rm -rf $JAVA_HOME/man

## need a few dependencies first (must have jdk install in centos7-base
RUN pip install pytest lightning-python plotly ipython && \
    /usr/bin/Rscript --slave --no-save --no-restore-history -e "install.packages(pkgs=c('testthat'), lib=Sys.getenv('R_LIBS_USER'), repos='https://cran.cnr.berkeley.edu/')" && \
    /usr/bin/Rscript --slave --no-save --no-restore-history -e "require(devtools); devtools::install('${SPARK_HOME}/R/lib/SparkR')"

# need to custom build adam to support spark 2.x and scala 2.11
# as such, there is no real version info...  we will build of master (risk)
# build it with out environment currently configured with:
# SPARK_MAJOR=2.1
# The default configuration is for Hadoop 2.7.3.
# HADOOP_MAJOR=2.7
# SCALA_VER=2.11
ARG HADOOP_VERSION=2.7.3
ARG SPARK_VERSION=2.1.1
ARG SCALAVER=2.11

### Host Arguments
ARG ADAM_INSTALL_DIR=/opt
ENV ADAM_HOME=${ADAM_INSTALL_DIR}/adam
ARG ADAM_REPO=https://github.com/bigdatagenomics/adam.git
ARG ADAM_TAG=master
ENV MAVEN_OPTS="-Xmx2g"
ENV CRAN_REPO=https://cran.cnr.berkeley.edu/

# build it
RUN cd ${ADAM_INSTALL_DIR} && \
    git clone ${ADAM_REPO} -b ${ADAM_TAG}
RUN cd ${ADAM_HOME} && \
# fix up poms to match out environment
    ./scripts/move_to_scala_2.11.sh && \
    ./scripts/move_to_spark_2.sh && \
# build
    mvn clean package -DskipTests  \
    -U \
    -P distribution \
#    -P python,r \
#    -P r \
    -Dhadoop.version=${HADOOP_VERSION} \
    -Dspark.version=${SPARK_VERSION} && \
# make sure it was built
    tar tzvf adam-distribution/target/adam-distribution*-bin.tar.gz | \
    grep adam-assembly | \
    grep jar | \
    grep -v -e sources -e javadoc && \
# copy python targets back, iff python os built (-P python)
#    cp -r adam-python/target ${ADAM_HOME}/adam-python/ && \
# free up some space by cleaning out build jars
    rm -rf ~/.m2/repository && \
    chown -R -L spark:root  ${ADAM_HOME} && \
    chmod -R g=u ${ADAM_HOME} && \
    echo "Successfully built ADAM"

# add pyspark to the python path
# cannot do this...  must use script to setup environment variable
# see https://github.com/moby/moby/issues/29110
#ENV PY4J_ZIP="${ls -1 "${SPARK_HOME}/python/lib" | grep py4j}"
# hard code for the time being
ENV PY4J_ZIP=py4j-0.10.4-src.zip
ENV PYTHONPATH="${SPARK_HOME}/python:${SPARK_HOME}/python/lib/${PY4J_ZIP}:${PYTHONPATH}"

# put adam jar on the pyspark, sparkr, and spark paths...
ENV ASSEMBLY_DIR="${ADAM_HOME}/adam-assembly/target"
# cannot do this...  must use a script approach to setup environemnt variable
#ENV ASSEMBLY_JAR="$(ls -1 "$ASSEMBLY_DIR" | grep "^adam[0-9A-Za-z\_\.-]*\.jar$" | grep -v javadoc | grep -v sources || true)"
# hard code for the time being
ENV ASSEMBLY_JAR=adam-assembly-spark2_2.11-0.23.0-SNAPSHOT.jar

ENV PYSPARK_SUBMIT_ARGS="--jars ${ASSEMBLY_DIR}/${ASSEMBLY_JAR} --driver-class-path ${ASSEMBLY_DIR}/${ASSEMBLY_JAR} pyspark-shell"
ENV SPARKR_SUBMIT_ARGS="--jars ${ASSEMBLY_DIR}/${ASSEMBLY_JAR} --driver-class-path ${ASSEMBLY_DIR}/${ASSEMBLY_JAR} sparkr-shell"
#ENV SPARK_SUBMIT_OPTIONS="--jars ${ASSEMBLY_DIR}/${ASSEMBLY_JAR} --driver-class-path ${ASSEMBLY_DIR}/${ASSEMBLY_JAR} "
ENV SPARK_SUBMIT_OPTIONS="--jars ${ASSEMBLY_DIR}/${ASSEMBLY_JAR} \
                          --driver-class-path ${ASSEMBLY_DIR}/${ASSEMBLY_JAR} \
                          --conf spark.serializer=org.apache.spark.serializer.KryoSerializer \
                          --conf spark.kryo.registrator=org.bdgenomics.adam.serialization.ADAMKryoRegistrator"

### need this established early - see zeppelin.sh
#ENV JAVA_INTP_OPTS="-Dspark.serializer=org.apache.spark.serializer.KryoSerializer \
#                    -Dspark.kryo.registrator=org.bdgenomics.adam.serialization.ADAMKryoRegistrator"

#ENV spark.executor.extraJavaOptions="-Dspark.serializer=org.apache.spark.serializer.KryoSerializer \
#                                     -Dspark.kryo.registrator=org.bdgenomics.adam.serialization.ADAMKryoRegistrator"
#
## if spark submits the driver in client mode. driver-java-options
#ENV spark.driver.extraJavaOptions="-Dspark.serializer=org.apache.spark.serializer.KryoSerializer \
#                                   -Dspark.kryo.registrator=org.bdgenomics.adam.serialization.ADAMKryoRegistrator"
#SPARK_JAVA_OPTS is deprecated... cannot use
#ENV SPARK_JAVA_OPTS=" \
#     -Dspark.serializer=org.apache.spark.serializer.KryoSerializer \
#     -Dspark.kryo.registrator=org.bdgenomics.adam.serialization.ADAMKryoRegistrator"
ENV PATH="${ADAM_HOME}/bin:${PATH}"
#ENV ZEPPELIN_INTP_CLASSPATH_OVERRIDES=/opt/adam/adam-

# Make the default PWD somewhere that the user can write. This is
# useful when connecting with 'oc run' and starting a 'spark-shell',
# which will likely try to create files and directories in PWD and
# error out if it cannot.
#WORKDIR /tmp
#RUN umask 002
WORKDIR ${ZEPPELIN_HOME}

### change the ownership
# change ownership to the spark process (non-root)
# initial group is root, then add accordingly
#
# need to get umask set to 002; therefore id -un must equal id -gn (/etc/profile) and


# set the working directory
#USER zeppelin
USER spark
CMD ["bin/zeppelin.sh"]

