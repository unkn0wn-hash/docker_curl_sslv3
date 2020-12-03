FROM debian:latest

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -yqq git zsh make gcc autoconf libtool slapd ldap-utils

WORKDIR /root

RUN git clone -b 'OpenSSL_1_1_1g' --single-branch --depth 1 https://github.com/openssl/openssl

WORKDIR /root/openssl

RUN ./config no-shared enable-ssl2 enable-ssl3 enable-ssl3-method
RUN make -j $(nproc)
RUN mkdir lib
RUN cp *.a lib

WORKDIR /root
RUN git clone -b 'curl-7_71_1' --single-branch --depth 1 https://github.com/curl/curl.git

WORKDIR /root/curl

RUN ./buildconf
RUN LDFLAGS="-static" ./configure --with-ssl=/root/openssl --disable-shared  --enable-static
RUN make -j $(nproc)

RUN ln -sf /root/curl/src/curl /bin/curl

WORKDIR /root

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

RUN echo 'export ZSH="/root/.oh-my-zsh"\n \
ZSH_THEME="robbyrussell"\n \
plugins=(\n \
  git\n \
  bundler\n \
  dotenv\n \
  osx\n \
  rake\n \
  rbenv\n \
  ruby\n \
)\n \
source $ZSH/oh-my-zsh.sh' > /root/.zshrc

CMD ["/bin/zsh"]
