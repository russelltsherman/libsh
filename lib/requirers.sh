#!/usr/bin/env bash
# shellcheck disable=SC1090

set -eou pipefail
set -E

function require_brew() {
  running "Check Requirement: $*"
  if ! brew ls --versions "$@" >> "$SETUPLOG" 2>&1
  then
    if ! brew install "$@" >> "$SETUPLOG" 2>&1
    then
      error "failed to install $*! aborting..."
    fi
  fi
  ok
}

function require_gem() {
  require_rvm
  running "Check Requirement: gem $*"
  if ! gem install "$@" >> "$SETUPLOG" 2>&1
  then
    error "failed to install gem $*"
  fi
  ok
}

function require_homebrew() {
  running "Check Requirement: HomeBrew/LinuxBrew"
  if ! command -v brew >> "$SETUPLOG" 2>&1
  then
    if test "$NS_PLATFORM" == "darwin"; then
      bot "Installing Homebrew"
      if /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
      then
        ok
      else
        error "unable to install Homebrew, script $0 abort!"
        exit 2
      fi
    fi

    if test "$NS_PLATFORM" == "linux"; then
      bot "Installing Linuxbrew"
      if sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
      then
        # shellcheck disable=SC2016
        dotbox_write 'export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"'
        # shellcheck disable=SC2016
        dotbox_write 'export MANPATH="/home/linuxbrew/.linuxbrew/share/man:$MANPATH"'
        # shellcheck disable=SC2016
        dotbox_write 'export INFOPATH="/home/linuxbrew/.linuxbrew/share/info:$INFOPATH"'

        set +o nounset
        source "$(dotbox_file)"
        set -o nounset
      else
        error "unable to install Linuxbrew, script $0 abort!"
        exit 2
      fi
    fi
  fi
  ok
}

function require_node(){
  running "Check Requirement: NodeJS"
  if ! node -v >> "$SETUPLOG" 2>&1
  then
    action "installing NodeJS"
    brew install node
  fi
  ok
}

function require_nodeversion() {
  require_nvm
  set +E
  set +e
  running "Check Requirement: Node verion $*"
  source "$NVM_DIR/nvm.sh"
  if ! nvm install "$@" >> "$SETUPLOG" 2>&1
  then
    error "failed to install Node version $*"
  fi
  set -E
  set -e
  ok
}

function require_npm() {
  running "Check Requirement: npm $*"
  if ! npm install -g "$@" >> "$SETUPLOG" 2>&1
  then
    error "failed to intall npm $*"
  fi
  ok
}

function require_nvm() {
  require_brew jq
  running "Check Requirement: NVM"
  # nvm is lazy loaded so can't check in usual way
  set +o nounset
  if test ! -s "$NVM_DIR/nvm.sh"
  then
    bot "Installing NVM"
    latest=$(curl https://api.github.com/repos/creationix/nvm/releases/latest -s | jq .name -r)
    if ! curl -o- "https://raw.githubusercontent.com/creationix/nvm/$latest/install.sh" | bash >> "$SETUPLOG" 2>&1
    then
      error "failed to install NVM! aborting..."
      exit 2
    else
      dotbox_write "export NVM_DIR=\"\${HOME}/.nvm\""
      dotbox_write "[ -s \"\${NVM_DIR}/nvm.sh\" ] && source \"\${NVM_DIR}/nvm.sh\" # This loads nvm"
      dotbox_write "[ -s \"\${NVM_DIR}/bash_completion\" ] && source \"\${NVM_DIR}/bash_completion\" # This loads nvm bash_completion"

      export NVM_DIR="${HOME}/.nvm"
      [ -s "${NVM_DIR}/nvm.sh" ] && source "${NVM_DIR}/nvm.sh" # This loads nvm
      [ -s "${NVM_DIR}/bash_completion" ] && source "${NVM_DIR}/bash_completion" # This loads nvm bash_completion
    fi
  fi
  set -o nounset
  ok
}

function require_pip() {
  running "Check Requirement: $*"
  if ! command -v pip >> "$SETUPLOG" 2>&1
  then
    if [ "$NS_PLATFORM" == "linux" ]; then
      # shellcheck disable=SC2024
      sudo apt-get -y install python-pip >> "$SETUPLOG" 2>&1
    fi
  fi
  if ! pip install "$@" >> "$SETUPLOG" 2>&1
  then
    error "failed to install $*! aborting..."
  fi
  ok
}

function require_rubyversion() {
  require_rvm
  running "Check Requirement: Ruby verion $*"
  if ! rvm install "$@" >> "$SETUPLOG" 2>&1
  then
    error "failed to install Node version $*"
  fi
  rvm use "$@" >> "$SETUPLOG" 2>&1
  ok
}

function require_rvm() {
  require_brew gnupg
  running "Check Requirement: RVM"
  if ! command -v rvm
  then
    bot "Installing RVM"
    command curl -sSL https://rvm.io/mpapis.asc | gpg2 --import -
    if ! curl -sSL https://get.rvm.io | bash -s stable --ruby=jruby --gems=rails,puma >> "$SETUPLOG" 2>&1
    then
      error "failed to install RVM! aborting..."
      exit 2
    fi
  fi
}
