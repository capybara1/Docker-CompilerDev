FROM ubuntu:rolling
ENV ANTLR_VERSION 4.7.2
ENV ANTLR_JAR antlr-${ANTLR_VERSION}-complete.jar
ENV ANTLR_URL https://www.antlr.org/download/$ANTLR_JAR
ENV JAVA_VERSION 8
ENV LLVM_VERSION 8
ENV LLVM_REPO https://github.com/llvm/llvm-project
ENV LLVM_BRANCH_ZIP "${LLVM_REPO}/archive/release/${LLVM_VERSION}.x.zip"
ENV SRC_DIR /opt/llvm-project-release-${LLVM_VERSION}.x/llvm
ENV OBJ_DIR /opt/llvm-project-release-${LLVM_VERSION}.x/llvm/build
RUN set -x; \
    apt-get update \
 && apt-get install -y \
                    build-essential \
                    gcc \
                    g++ \
                    cmake \
                    wget \
                    unzip \
                    python \
                    openjdk-${JAVA_VERSION}-jdk \
                    nano \
                    git \
                    pkg-config \
                    uuid-dev \
 && git config --global user.email "john.doe@example.com" \
 && git config --global user.name "John Doe" \
 && apt-get clean
WORKDIR /opt
RUN set -x; \
    wget -O /tmp/llvm-src.zip -nv "$LLVM_BRANCH_ZIP" \
 && unzip -q /tmp/llvm-src.zip \
 && rm /tmp/llvm-src.zip \
 && mkdir -p $OBJ_DIR \
 && cd $OBJ_DIR \
 && cmake -DCMAKE_BUILD_TYPE=Release $SRC_DIR \
 && NUM_CORES=$(cat /proc/cpuinfo | grep processor -c) \
 && NUM_PARALLEL_JOBS=$(($NUM_CORES * 3 / 2)) \
 && cmake --build . --parallel $NUM_PARALLEL_JOBS \
 && cmake --build . --target install \
 && cd / \
 && rm -rf $OBJ_DIR \
 && rm -rf $SRC_DIR \
 && rm /root/.wget-hsts
WORKDIR /usr/local/lib
RUN set -x; \
    cd /usr/local/lib \
 && wget -nv $ANTLR_URL \
 && export CLASSPATH=".:/usr/local/lib/${ANTLR_JAR}:$CLASSPATH" \
 && alias antlr4='java -jar /usr/local/lib/${ANTLR_JAR}' \
 && alias grun='java org.antlr.v4.gui.TestRig'
