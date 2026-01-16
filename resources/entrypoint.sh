#!/bin/bash

TLPATH=$(readlink -f /usr/local/texlive/*/bin/*)

export PATH=${TLPATH}:$PATH

"${@}"
