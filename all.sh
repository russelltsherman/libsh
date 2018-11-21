#!/usr/bin/env bash
# shellcheck disable=SC1090

LIBDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${LIBDIR}/banner.sh"
source "${LIBDIR}/echos.sh"
source "${LIBDIR}/functions.sh"
source "${LIBDIR}/iterm.sh"
source "${LIBDIR}/requirers.sh"
source "${LIBDIR}/validate.sh"
source "${LIBDIR}/validate_ip.sh"
