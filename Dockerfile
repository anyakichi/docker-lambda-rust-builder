FROM lambci/lambda:build-provided

RUN \
  gosu_version=1.12; \
  machine=$(uname -m); \
  arch=${machine/x86_64/amd64}; \
  export GNUPGHOME="$(mktemp -d)"; \
  curl -LsSfo /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$gosu_version/gosu-$arch" \
  && curl -LsSfo /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$gosu_version/gosu-$arch" \
  && gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
  && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
  && command -v gpgconf && gpgconf --kill all || : \
  && rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc \
  && chmod +x /usr/local/bin/gosu

RUN \
  usermod -l builder -d /home/builder ec2-user \
  && groupadd -g 1000 builder \
  && mkhomedir_helper builder

USER builder
RUN \
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
  && echo '. <(buildenv init)' >> ~/.bashrc \
  && git config --global user.email "builder@lambda-rust" \
  && git config --global user.name "Lambda Rust Builder"

USER root
WORKDIR /home/builder

COPY buildenv/entrypoint.sh /usr/local/sbin/entrypoint
COPY buildenv/buildenv.sh /usr/local/bin/buildenv

COPY buildenv/buildenv.conf /etc/
COPY buildenv.d/ /etc/buildenv.d/

RUN sed -i 's/^#DOTCMDS=.*/DOTCMDS=setup/' /etc/buildenv.conf

ENV \
  GIT_BRANCH= \
  GIT_REPO=https://github.com/anyakichi/lambda-rust-sample.git \
  PATH=/home/builder/.cargo/bin:${PATH}

ENTRYPOINT ["/usr/local/sbin/entrypoint"]
CMD ["/bin/bash"]
