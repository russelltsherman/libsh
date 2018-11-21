#!/usr/bin/env bash
# shellcheck disable=SC1117
# shellcheck disable=SC2034

# Colors
ESC_SEQ="\x1b["
C_RESET="${ESC_SEQ}39;49;00m"
C_RED="${ESC_SEQ}31;01m"
C_GREEN="${ESC_SEQ}32;01m"
C_YELLOW="${ESC_SEQ}33;01m"
C_BLUE="${ESC_SEQ}34;01m"
C_MAGENTA="${ESC_SEQ}35;01m"
C_CYAN="${ESC_SEQ}36;01m"

################################################################################
# TUI Functions
################################################################################

function banner() {
  clear
  echo -e "${C_GREEN}${BANNER}${C_RESET}"
}

function action() {
  local msg="${1:-}"
  echo -e "\n${C_YELLOW}[action]:${C_RESET}\n ⇒ ${msg} ..." 1>&2
}

function bot() {
  local msg="${1:-}"
  echo -e "\n${C_GREEN}\[._.]/${C_RESET} - ${msg}" 1>&2
}

function bot_confirm() {
  local msg="${1:-}"
  echo -e "\n${C_GREEN}\[._.]/${C_RESET} - ${msg}" 1>&2
  info "Press any key to continue."
  # shellcheck disable=SC2162
  read
}

function die() {
  (>&2 echo "$@")
  exit 1
}

function error() {
  local msg="${1:-}"
  echo -e "\a${C_RED}[error]${C_RESET} ${msg}" 1>&2
}

function info() {
  local msg="${1:-}"
  echo -e "${C_GREEN}[info]${C_RESET} ${msg}" 1>&2
}

function line() {
  echo -e "------------------------------------------------------------------------------------"
}

function ok() {
  local msg="${1:-}"
  echo -e "${C_GREEN}[ok]${C_RESET} ${msg}" 1>&2
}

function running() {
  local msg="${1:-}"
  echo -en "${C_YELLOW} ⇒ ${C_RESET} ${msg}: " 1>&2
}

function warn() {
  local msg="${1:-}"
  echo -e "${C_YELLOW}[warning]${C_RESET} ${msg}" 1>&2
}
