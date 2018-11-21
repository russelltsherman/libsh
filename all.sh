#!/usr/bin/env bash
# shellcheck disable=SC1090

LIBDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${LIBDIR}/lib/banner.sh"
source "${LIBDIR}/lib/echos.sh"
source "${LIBDIR}/lib/functions.sh"
source "${LIBDIR}/lib/iterm.sh"
source "${LIBDIR}/lib/requirers.sh"
source "${LIBDIR}/lib/validate.sh"
source "${LIBDIR}/lib/validate_ip.sh"
