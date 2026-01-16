FROM debian:trixie-slim AS builder

ENV DEBIAN_FRONTEND=noninteractive

ARG TLYEAR=2025
ARG TLSCHEME=small

RUN apt-get update -qq \
 && apt-get install -qq -y \
        build-essential \
        curl \
        perl \
        gnupg \
        libwww-perl

COPY resources/texlive.profile /texlive.profile

RUN if [ "${TLYEAR}" -eq "2025" ] ; then \
    curl -L -o install-tl-unx.tar.gz https://ftp.math.utah.edu/pub/tex/historic/systems/texlive/${TLYEAR}/install-tl-unx.tar.gz; \
    export REPOSITORY=""; \
  elif [ ${TLYEAR} -le 2021 ]; then \
    curl -L -o install-tl-unx.tar.gz https://ftp.math.utah.edu/pub/tex/historic/systems/texlive/${TLYEAR}/tlnet-final/install-tl-unx.tar.gz; \
    export REPOSITORY="--repository=https://ftp.math.utah.edu/pub/tex/historic/systems/texlive/${TLYEAR}/tlnet-final/tlpkg"; \
  else \
    curl -L -o install-tl-unx.tar.gz https://ftp.math.utah.edu/pub/tex/historic/systems/texlive/${TLYEAR}/tlnet-final/install-tl-unx.tar.gz; \
    export REPOSITORY="--repository=https://ftp.math.utah.edu/pub/tex/historic/systems/texlive/${TLYEAR}/tlnet-final/tlpkg"; \
  fi \
 && tar xzf install-tl-unx.tar.gz \
 && cd install-tl-2* \
 && echo "selected_scheme scheme-${TLSCHEME}" >> /texlive.profile \
 && ./install-tl \
    $REPOSITORY \
    --profile=/texlive.profile

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

COPY resources/entrypoint.sh /entrypoint.sh
RUN /entrypoint.sh tlmgr install --persistent-downloads biber

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"]
