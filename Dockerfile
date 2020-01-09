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

RUN apt-get update && \
    apt-get install wget gnupg unzip -y && \
    echo 'deb http://apt.llvm.org/buster/ llvm-toolchain-buster-8 main' >> /etc/apt/sources.list && \
    wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - && \
    wget -O - https://deb.nodesource.com/setup_10.x | bash - && \
    apt-get update && \
    apt-get install nodejs clangd-8 clang-8 clang-format-8 gdb -y && \
    apt-get clean && apt-get -y autoremove && rm -rf /var/lib/apt/lists/* && \
    update-alternatives --install /usr/bin/clang clang /usr/bin/clang-8 100 && \
    update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-8 100 && \
    update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-8 100 && \
    update-alternatives --install /usr/bin/clang-format clang-format /usr/bin/clang-format-8 100

RUN cd /tmp && mkdir protoc-download && cd protoc-download && \
    wget https://github.com/protocolbuffers/protobuf/releases/download/v3.11.2/protoc-3.11.2-linux-x86_64.zip && \
    unzip protoc-3.11.2-linux-x86_64.zip && rm -f protoc-3.11.2-linux-x86_64.zip && \
    cp bin/protoc /usr/local/bin && cd ../ && rm -rf protoc-download
    
RUN cd /tmp && mkdir googleapis-download && cd googleapis-download && \
    wget https://github.com/googleapis/googleapis/archive/master.zip && unzip master.zip && \
    mkdir -p /go/src/github.com/googleapis && mv googleapis-master /go/src/github.com/googleapis/googleapis && \
    cd / && rm -rf /tmp/googleapis-download
    
RUN mkdir /projects ${HOME} && \
    # Change permissions to let any arbitrary user
    for f in "${HOME}" "/etc/passwd" "/projects" "/go"; do \
      echo "Changing permissions on ${f}" && chgrp -R 0 ${f} && \
      chmod -R g+rwX ${f}; \
    done

ADD etc/entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
CMD ${PLUGIN_REMOTE_ENDPOINT_EXECUTABLE}
