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
  groupadd -g 1000 ec2-user \
  && mkhomedir_helper ec2-user

USER ec2-user
RUN \
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
  && echo '. ~/.cargo/env' >> ~/.bashrc \
  && echo '. <(buildenv init)' >> ~/.bashrc \
  && git config --global user.email "ec2-user@lambda-rust" \
  && git config --global user.name "Lambda Rust Builder"

USER root
WORKDIR /home/ec2-user

COPY buildenv/entrypoint.sh /usr/local/sbin/entrypoint
COPY buildenv/buildenv.sh /usr/local/bin/buildenv

COPY buildenv/buildenv.conf /etc/

ENV \
  BUILD_USER=ec2-user \
  BUILD_GROUP=ec2-user

ENTRYPOINT ["/usr/local/sbin/entrypoint"]
CMD ["/bin/bash"]
