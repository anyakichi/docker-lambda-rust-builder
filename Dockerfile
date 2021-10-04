FROM public.ecr.aws/lambda/provided:al2
ARG use_rustup=false

RUN \
  yum update -y \
  && yum install -y \
    amazon-linux-extras \
    awscli \
    gcc \
    git \
    shadow-utils \
    sudo \
    tar \
    zip \
  && if [ $use_rustup != true ]; then \
      amazon-linux-extras install -y rust1 \
      && yum install -y clippy rustfmt \
  ; else \
      yum install -y openssl-devel \
  ; fi \
  && yum clean all \
  && rm -rf /var/cache/yum

RUN \
  gosu_version=1.13; \
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
  v=v0.2.15; \
  b=sccache-$v-x86_64-unknown-linux-musl; \
  curl -LsS https://github.com/mozilla/sccache/releases/download/$v/$b.tar.gz | \
    tar -xzf - -C /usr/local/bin \
        --strip-components=1 $b/sccache \
  && chown root:root /usr/local/bin/sccache \
  && chmod +x /usr/local/bin/sccache

RUN \
  /usr/sbin/useradd -K UMASK=022 -ms /bin/bash builder && \
  echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER builder
RUN \
  echo '. <(buildenv init)' >> ~/.bashrc \
  && git config --global user.email "builder@lambda-rust" \
  && git config --global user.name "Lambda Rust Builder" \
  && if [ $use_rustup = true ]; then \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
    && . ~/.cargo/env \
    && cargo install sccache \
    && rm -rf ~/.cargo/registry \
  ; fi

USER root
WORKDIR /home/builder

COPY buildenv/entrypoint.sh /buildenv-entrypoint.sh
COPY buildenv/buildenv.sh /usr/local/bin/buildenv

COPY buildenv/buildenv.conf /etc/
COPY buildenv.d/ /etc/buildenv.d/

RUN sed -i 's/^#DOTCMDS=.*/DOTCMDS=setup/' /etc/buildenv.conf

COPY entrypoint.sh /

ENV \
  FUNCTION_NAME= \
  GIT_BRANCH= \
  GIT_REPO=https://github.com/anyakichi/lambda-rust-sample.git \
  PATH=/home/builder/.cargo/bin:${PATH}:/usr/sbin:/sbin \
  RUSTUP_HOME=/home/builder/.rustup

EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"]
