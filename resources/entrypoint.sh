#!/bin/bash

if [ "$(uname -m)" == "arm64" ]; then
    TLPATH=$(readlink -f /usr/local/texlive/*/bin/aarch64-linux)
else
    TLPATH=$(readlink -f /usr/local/texlive/*/bin/x86_64-linux)
fi

export PATH=${TLPATH}:$PATH

"${@}"
