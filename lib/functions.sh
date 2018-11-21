#!/usr/bin/env bash
# shellcheck disable=SC1117

function dotbox_file {
  echo "$HOME/.dotbox"
}

function dotbox_write {
  local content="$1"
  local file="${2:-"$(dotbox_file)"}"

  # try to ensure we don't create duplicate entries in the file
  touch "$file"
  if ! grep -q "$content" "$file" ; then
    echo "$content" >> "$file"
  fi
}

function file_writeln {
  # try to ensure we don't create duplicate entries in the .coderonin file
  touch "$1"
  if ! grep -q "$2" "$1"; then
    echo writing
    echo "$2" >> "$1"
  fi
}

function get_osx_version() {
  if [ "$NS_PLATFORM" == "darwin" ]; then
    IFS='.' read -r -a vers <<< "$(sw_vers -productVersion)"
    case ${vers[1]} in
      1)
        export OSX_VERSION="Cheeta/Puma"
        ;;
      2)
        export OSX_VERSION="Jaguar"
        ;;
      3)
        export OSX_VERSION="Panther"
        ;;
      4)
        export OSX_VERSION="Tiger"
        ;;
      5)
        export OSX_VERSION="Snow Leopard"
        ;;
      6)
        export OSX_VERSION="Lion"
        ;;
      7)
        export OSX_VERSION="Mountain Lion"
        ;;
      8)
        export OSX_VERSION="Mavericks"
        ;;
      9)
        export OSX_VERSION="Yosemite"
        ;;
      10)
        export OSX_VERSION="Mavericks"
        ;;
      11)
        export OSX_VERSION="El Capitan"
        ;;
      12)
        export OSX_VERSION="Sierra"
        ;;
      13)
        export OSX_VERSION="High Sierra"
        ;;
      14)
        export OSX_VERSION="Mojave"
        ;;
      *)
        die "unrecognized osx version"
        ;;
    esac
    running "OSX $OSX_VERSION detected"
  fi
}

function get_platform() {
  if [ "$(uname -s)" == "Darwin" ]; then
    # Do something for OSX
    export NS_PLATFORM="darwin"
  elif [ "$(uname -s)" == "Linux" ]; then
  	# Do something for Linux platform
  	# assume ubuntu - but surely this can be extended to include other distros
  	export NS_PLATFORM="linux"
    #test if aptitude exists and default to using that if possible
    if command -v aptitude >/dev/null 2>&1 ; then
      export PM="aptitude"
    else
      export PM="apt-get"
    fi
  elif [ "$(uname -s)" == "MINGW32_NT" ]; then
    # Do something for Windows NT platform
  	export NS_PLATFORM="windows"
    die "Windows not supported"
  else
    die "unsupported platform"
  fi
}

#
# join_by , a "b c" d #a,b c,d
# join_by / var local tmp #var/local/tmp
# join_by , "${FOO[@]}" #a,b,c
#
function join_by { local IFS="$1"; shift; echo "$*"; }

function profile_file {
  get_platform
  if [ "$NS_PLATFORM" == "darwin" ]; then
    echo "$HOME/.bash_profile"
  else
    echo "$HOME/.bashrc"
  fi
}

function sudo_write {
  # try to ensure we don't create duplicate entries in the file
  sudo "$BASH" -c "touch $2"
  if ! grep -q "$1" "$2" ; then
    sudo "$BASH" -c "echo \"$1\" >> \"$2\""
  fi
}

function sudo_passwordless {
  local toggle="$1"
  local user
  user="$(whoami)"

  if [ "no" = "$toggle" ]; then
    if [ -f /etc/sudoers.d/"$user" ]; then
      sudo rm /etc/sudoers.d/"$user"
    fi
  else
    if [ ! -f /etc/sudoers.d/"$user" ]; then
      # shellcheck disable=SC2024
      echo "$user ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/"$user" >> "$SETUPLOG"
    fi
  fi
}

function symlinkifne {
  running "$1"

  if [[ -e "$1" ]]; then
    # file exists
    if [[ -L "$1" ]]; then
      # it's already a simlink (could have come from this project)
      echo -en '\tsimlink exists, skipped\t';ok
      return
    fi
    # backup file does not exist yet
    if [[ ! -e "$HOME/.dotfiles_backup/$1" ]];then
      mv "$1" ~/.dotfiles_backup/
      echo -en 'backed up saved...';
    fi
  fi
  # create the link
  ln -s "$HOME/.dotfiles/$1" "$1"
  echo -en '\tlinked';ok
}
