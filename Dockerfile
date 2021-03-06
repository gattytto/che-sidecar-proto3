# Copyright (c) 2019 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#
# Contributors:
#   Red Hat, Inc. - initial API and implementation

FROM debian:10-slim

ENV HOME=/home/theia
ENV PROTOC_VERSION=3.14.0
ENV PLINT=0.28.0
ENV BUF=0.36.0

RUN echo "deb http://deb.debian.org/debian buster-backports main" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install wget gnupg unzip -y && \
    apt-get update && \
    apt-get install -t buster-backports clangd-8 clang-8 clang-format-8 gdb -y && \
    apt-get clean && apt-get -y autoremove && rm -rf /var/lib/apt/lists/* && \
    update-alternatives --install /usr/bin/clang clang /usr/bin/clang-8 100 && \
    update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-8 100 && \
    update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-8 100 && \
    update-alternatives --install /usr/bin/clang-format clang-format /usr/bin/clang-format-8 100

RUN cd /tmp && mkdir protoc-download && cd protoc-download && \
    wget https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOC_VERSION}/protoc-${PROTOC_VERSION}-linux-x86_64.zip && \
    unzip protoc-${PROTOC_VERSION}-linux-x86_64.zip && rm -f protoc-${PROTOC_VERSION}-linux-x86_64.zip && \
    cp bin/protoc /usr/local/bin && mkdir /usr/include/protobuf &&  \
    cp -R include/* /usr/include/protobuf/ && cd ../ && rm -rf protoc-download && \
    mkdir plint && cd plint && \
    wget https://github.com/yoheimuta/protolint/releases/download/v${PLINT}/protolint_${PLINT}_Linux_x86_64.tar.gz && \
    tar -zxvf protolint_${PLINT}_Linux_x86_64.tar.gz && install protolint /usr/bin/protolint && cd .. && \
    rm -rf plint && rm -f protolint*.gz && \
    wget https://github.com/bufbuild/buf/releases/download/v${BUF}/buf-Linux-x86_64 -O /usr/bin/buf && chmod +x /usr/bin/buf && \
    wget https://github.com/bufbuild/buf/releases/download/v${BUF}/protoc-gen-buf-breaking-Linux-x86_64 -O /usr/bin/protoc-gen-buf-breaking && chmod +x /usr/bin/protoc-gen-buf-breaking && \
    wget https://github.com/bufbuild/buf/releases/download/v${BUF}/protoc-gen-buf-check-breaking-Linux-x86_64 -O /usr/bin/protoc-gen-buf-check-breaking && chmod +x /usr/bin/protoc-gen-buf-check-breaking && \
    wget https://github.com/bufbuild/buf/releases/download/v${BUF}/protoc-gen-buf-check-lint-Linux-x86_64 -O /usr/bin/protoc-gen-buf-check-lint && chmod +x /usr/bin/protoc-gen-buf-check-lint && \
    wget https://github.com/bufbuild/buf/releases/download/v${BUF}/protoc-gen-buf-lint-Linux-x86_64 -O /usr/bin/protoc-gen-buf-lint && chmod +x /usr/bin/protoc-gen-buf-lint
        
RUN mkdir /projects ${HOME} && \
    # Change permissions to let any arbitrary user
    for f in "${HOME}" "/etc/passwd" "/projects"; do \
      echo "Changing permissions on ${f}" && chgrp -R 0 ${f} && \
      chmod -R g+rwX ${f}; \
    done

ADD etc/entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
CMD ${PLUGIN_REMOTE_ENDPOINT_EXECUTABLE}
