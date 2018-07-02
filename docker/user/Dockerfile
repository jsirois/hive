ARG BASE_ID
FROM ${BASE_ID}

# Prepare developer shim that can operate on local files and not mess up perms in the process.
ARG USER
ARG UID
ARG GROUP
ARG GID

RUN test -n "${USER}" || ( \
  echo "The USER --build-arg is required." && \
  exit 1 \
)
RUN test -n "${UID}" || ( \
  echo "The UID --build-arg is required." && \
  exit 1 \
)
RUN test -n "${GROUP}" || ( \
  echo "The GROUP --build-arg is required." && \
  exit 1 \
)
RUN test -n "${GID}" || ( \
  echo "The GID --build-arg is required." && \
  exit 1 \
)

COPY create_docker_image_user.sh /root/
RUN /root/create_docker_image_user.sh ${USER} ${UID} ${GROUP} ${GID}

VOLUME /dev/hive
WORKDIR /dev/hive
RUN chown -R ${UID}:${GID} /dev/hive

USER ${USER}:${GROUP}

COPY nvm /tmp/nvm
RUN /tmp/nvm/install.sh

COPY rust /tmp/rust
RUN /tmp/rust/install.sh

RUN echo "\nexport PATH=\"/dev/hive/bin:\${PATH}\"" >> ${HOME}/.bashrc

ENTRYPOINT ["bash", "-ic"]
