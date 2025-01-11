# Build image
FROM quay.io/spivegin/gitonly:latest AS git

FROM spivegin/alpine:golang AS builder
RUN apk update  && apk add --no-cache openssh-client
RUN ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa && git config --global user.name "quadtone" && git config --global user.email "quadtone@txtsme.com"
COPY --from=git /root/.ssh /root/.ssh
RUN ssh-keyscan -H github.com > ~/.ssh/known_hosts &&\
    ssh-keyscan -H gitlab.com >> ~/.ssh/known_hosts &&\
    ssh-keyscan -H gitea.com >> ~/.ssh/know_hosts

#COPY --from=gover /opt/go /opt/go
ENV deploy=c1f18aefcb3d1074d5166520dbf4ac8d2e85bf41 \
    GO111MODULE=on \
    GOPROXY=direct \
    GOSUMDB=off \
    GOPRIVATE=sc.tpnfc.us
    # GIT_TRACE_PACKET=1 \
    # GIT_TRACE=1 \
    # GIT_CURL_VERBOSE=1

RUN git config --global url.git@github.com:.insteadOf https://github.com/ &&\
    git config --global url.git@gitlab.com:.insteadOf https://gitlab.com/ &&\
    git config --global url.git@gitea.com:.insteadOf https://gitea.com/ &&\
    git config --global url."https://${deploy}@sc.tpnfc.us/".insteadOf "https://sc.tpnfc.us/"


RUN apk update &&\
    apk upgrade &&\
    apk add alpine-sdk linux-headers git zlib-dev openssl-dev gperf php cmake &&\
    git clone https://github.com/tdlib/td.git &&\
    cd td &&\
    rm -rf build &&\
    mkdir build &&\
    cd build &&\
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr/local .. &&\
    cmake --build . --target install &&\
    cd .. &&\
    cd .. &&\
    ls -l /usr/local



# Install Go dependencies and build the project for Linux AMD64 architecture, then remove unnecessary files to keep image size small

