# Copyright (c) 2019 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#
# Contributors:
#   Red Hat, Inc. - initial API and implementation

FROM eclipse/che-theia-endpoint-runtime:next

ENV HOME=/home/theia

RUN for f in "${HOME}" "/etc/passwd" "/projects"; do \
      echo "Changing permissions on ${f}" && chgrp -R 0 ${f} && \
      chmod -R g+rwX ${f}; \
    done

RUN set -e \
    && \
    cd /home/theia && mkdir protoc-download && cd protoc-download && \
    wget https://github.com/protocolbuffers/protobuf/releases/download/v3.11.2/protoc-3.11.2-linux-x86_64.zip && \
    unzip protoc-3.11.2-linux-x86_64.zip && rm -f protoc-3.11.2-linux-x86_64.zip && \
    cp bin/protoc /usr/local/bin && cd ../ && rm -rf protoc-download

ADD etc/entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
CMD ${PLUGIN_REMOTE_ENDPOINT_EXECUTABLE}
