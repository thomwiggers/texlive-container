FROM debian:trixie-slim AS builder
MAINTAINER Thom Wiggers

ENV DEBIAN_NONINTERACTIVE=1

ARG TLYEAR=2025
ARG TLSCHEME=small

RUN apt update -qq \
 && apt install -qq -y \
        build-essential \
        curl \
        perl \
        libwww-perl

RUN curl -L -o install-tl-unx.tar.gz https://ftp.math.utah.edu/pub/tex/historic/systems/texlive/${TLYEAR}/install-tl-unx.tar.gz
RUN tar xzf install-tl-unx.tar.gz

RUN cd install-tl-2* \
 && ./install-tl --paper=a4 \
    --no-doc-install \
    --no-src-install \
    --no-interaction \
    --scheme=${TLSCHEME}

FROM debian:trixie-slim
ARG TLYEAR=2025

ENV DEBIAN_NONINTERACTIVE=1
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN apt update -qq \
 && apt install -qq -y \
      perl \
      libwww-perl \
      gnupg \
 && rm -rf /var/lib/apt /var/cache/apt

RUN mkdir /work
WORKDIR /work

COPY --from=builder /usr/local/texlive /usr/local/texlive
RUN bash -c "/usr/local/texlive/*/bin/*/tlmgr install --persistent-downloads biber"

COPY resources/entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"]
