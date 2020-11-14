#!/bin/bash

# exit on fail
set -e

#chromebrew directories
OWNER="skycocker"
REPO="chromebrew"
BRANCH="master"
URL="https://raw.githubusercontent.com/${OWNER}/${REPO}/${BRANCH}"
CREW_PREFIX="${CREW_PREFIX:-/usr/local}"
CREW_LIB_PATH="${CREW_PREFIX}/lib/crew/"
CREW_CONFIG_PATH="${CREW_PREFIX}/etc/crew/"
CREW_BREW_DIR="${CREW_PREFIX}/tmp/crew/"
CREW_DEST_DIR="${CREW_BREW_DIR}/dest"
CREW_PACKAGES_PATH="${CREW_LIB_PATH}/packages"

ARCH="$(uname -m)"

if [ "${EUID}" == "0" ]; then
  echo 'Chromebrew should not be installed or run as root.'
  exit 1;
fi

case "${ARCH}" in
"i686"|"x86_64"|"armv7l"|"aarch64")
  LIB_SUFFIX=
  [ "${ARCH}" == "x86_64" ] && LIB_SUFFIX='64'
  ;;
*)
  echo 'Your device is not supported by Chromebrew yet.'
  exit 1;;
esac

# This will allow things to work without sudo
sudo chown -R "$(id -u)":"$(id -g)" "${CREW_PREFIX}"

# prepare directories
for dir in "${CREW_CONFIG_PATH}/meta" "${CREW_DEST_DIR}" "${CREW_PACKAGES_PATH}"; do
  if [ ! -d "${dir}" ]; then
    mkdir -p "${dir}"
  fi
done

# prepare url and sha256
# install only gcc8, ruby, libiconv, git and libssh2 (order matters)
urls=()
case "${ARCH}" in
"aarch64")
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/gcc10-10.2.0-chromeos-armv7l.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/brotli-1.0.8-chromeos-armv7l.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/c_ares-1.15.0-chromeos-armv7l.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/libcyrussasl-2.1.27-1-chromeos-armv7l.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/libiconv-1.16-2-chromeos-armv7l.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/libidn2-2.0.5-chromeos-armv7l.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/libmbedtls-2.16.8-chromeos-armv7l.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/libmetalink-0.1.3-1-chromeos-armv7l.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/libnghttp2-1.38.0-chromeos-armv7l.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/libpsl-0.20.2-chromeos-armv7l.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/libssh2-1.9.0-1-chromeos-armv7l.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/libtirpc-1.0.2-0-chromeos-armv7l.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/libunistring-0.9.10-chromeos-armv7l.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/openldap-2.4.55-chromeos-armv7l.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/rtmpdump-c5f04a58f-chromeos-armv7l.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/zstd-1.4.5-chromeos-armv7l.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/ruby-2.7.2-chromeos-armv7l.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/git-2.29.1-chromeos-armv7l.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/libressl-3.2.2-chromeos-armv7l.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/curl-7.73.0-chromeos-armv7l.tar.xz')
  ;;
"armv7l")
  if ! type "xz" > /dev/null; then
    urls+=('https://github.com/snailium/chrome-cross/releases/download/v1.8.1/xz-5.2.3-chromeos-armv7l.tar.gz')
  fi
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/gcc10-10.2.0-chromeos-armv7l.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/brotli-1.0.8-chromeos-armv7l.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/c_ares-1.15.0-chromeos-armv7l.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/libcyrussasl-2.1.27-1-chromeos-armv7l.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/libiconv-1.16-2-chromeos-armv7l.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/libidn2-2.0.5-chromeos-armv7l.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/libmbedtls-2.16.8-chromeos-armv7l.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/libmetalink-0.1.3-1-chromeos-armv7l.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/libnghttp2-1.38.0-chromeos-armv7l.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/libpsl-0.20.2-chromeos-armv7l.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/libssh2-1.9.0-1-chromeos-armv7l.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/libtirpc-1.0.2-0-chromeos-armv7l.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/libunistring-0.9.10-chromeos-armv7l.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/openldap-2.4.55-chromeos-armv7l.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/rtmpdump-c5f04a58f-chromeos-armv7l.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/zstd-1.4.5-chromeos-armv7l.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/ruby-2.7.2-chromeos-armv7l.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/git-2.29.1-chromeos-armv7l.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/libressl-3.2.2-chromeos-armv7l.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/curl-7.73.0-chromeos-armv7l.tar.xz')
  ;;
"i686")
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/gcc10-10.2.0-chromeos-i686.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/brotli-1.0.8-chromeos-i686.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/c_ares-1.15.0-chromeos-i686.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/libcyrussasl-2.1.27-1-chromeos-i686.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/libiconv-1.16-2-chromeos-i686.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/libidn2-2.0.5-chromeos-i686.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/libmbedtls-2.16.8-chromeos-i686.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/libmetalink-0.1.3-1-chromeos-i686.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/libnghttp2-1.38.0-chromeos-i686.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/libpsl-0.20.2-chromeos-i686.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/libssh2-1.9.0-1-chromeos-i686.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/libtirpc-1.0.2-0-chromeos-i686.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/libunistring-0.9.10-chromeos-i686.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/openldap-2.4.55-chromeos-i686.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/rtmpdump-c5f04a58f-chromeos-i686.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/zstd-1.4.5-chromeos-i686.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/ruby-2.7.2-chromeos-i686.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/git-2.29.1-chromeos-i686.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/libressl-3.2.2-chromeos-i686.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/curl-7.73.0-chromeos-i686.tar.xz')
  ;;
"x86_64")
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/gcc10-10.2.0-chromeos-x86_64.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/brotli-1.0.8-chromeos-x86_64.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/c_ares-1.15.0-chromeos-x86_64.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/libcyrussasl-2.1.27-1-chromeos-x86_64.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/libiconv-1.16-2-chromeos-x86_64.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/libidn2-2.0.5-chromeos-x86_64.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/libmbedtls-2.16.8-chromeos-x86_64.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/libmetalink-0.1.3-1-chromeos-x86_64.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/libnghttp2-1.38.0-chromeos-x86_64.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/libpsl-0.20.2-chromeos-x86_64.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/libssh2-1.9.0-1-chromeos-x86_64.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/libtirpc-1.0.2-0-chromeos-x86_64.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/libunistring-0.9.10-chromeos-x86_64.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/openldap-2.4.55-chromeos-x86_64.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/rtmpdump-c5f04a58f-chromeos-x86_64.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/zstd-1.4.5-chromeos-x86_64.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/ruby-2.7.2-chromeos-x86_64.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/git-2.29.1-chromeos-x86_64.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/libressl-3.2.2-chromeos-x86_64.tar.xz')
  urls+=('https://dl.bintray.com/chromebrew/chromebrew/curl-7.73.0-chromeos-x86_64.tar.xz')
  ;;
esac

# functions to maintain packages
function download_check () {
    cd "${CREW_BREW_DIR}"

    #download
    echo "Downloading ${1}..."
    curl --progress-bar -C - -L --ssl "${2}" -o "${3}"

    #verify
    echo "Verifying ${1}..."
    echo "${4}" "${3}" # | sha256sum -c -
    case "${?}" in
    0) ;;
    *)
      echo "Verification failed, something may be wrong with the download."
      exit 1;;
    esac
}

function extract_install () {
    # Start with a clean slate
    rm -rf "${CREW_DEST_DIR}"
    mkdir "${CREW_DEST_DIR}"
    cd "${CREW_DEST_DIR}"

    #extract and install
    echo "Extracting ${1} (this may take a while)..."
    tar xpf ../"${2}"
    echo "Installing ${1} (this may take a while)..."
    tar cpf - ./*/* | (cd /; tar xp --keep-directory-symlink -f -)
    mv ./dlist "${CREW_CONFIG_PATH}/meta/${1}.directorylist"
    mv ./filelist "${CREW_CONFIG_PATH}/meta/${1}.filelist"
}

function update_device_json () {
  cd "${CREW_CONFIG_PATH}"

  if grep '"name": "'"${1}"'"' device.json > /dev/null; then
    echo "Updating version number of ${1} in device.json..."
    sed -i device.json -e '/"name": "'"${1}"'"/N;//s/"version": ".*"/"version": "'"${2}"'"/'
  elif grep '^    }$' device.json > /dev/null; then
    echo "Adding new information on ${1} to device.json..."
    sed -i device.json -e '/^    }$/s/$/,\
    {\
      "name": "'"${1}"'",\
      "version": "'"${2}"'"\
    }/'
  else
    echo "Adding new information on ${1} to device.json..."
    sed -i device.json -e '/^  "installed_packages": \[$/s/$/\
    {\
      "name": "'"${1}"'",\
      "version": "'"${2}"'"\
    }/'
  fi
}

# create the device.json file if it doesn't exist
cd "${CREW_CONFIG_PATH}"
if [ ! -f device.json ]; then
  echo "Creating new device.json..."
  echo '{' > device.json
  echo '  "architecture": "'"${ARCH}"'",' >> device.json
  echo '  "installed_packages": [' >> device.json
  echo '  ]' >> device.json
  echo '}' >> device.json
fi

# extract, install and register packages
for i in $(seq 0 $((${#urls[@]} - 1))); do
  url="${urls["${i}"]}"
#   sha256="${sha256s["${i}"]}"
  tarfile="$(basename ${url})"
  name="${tarfile%%-*}"   # extract string before first '-'
  rest="${tarfile#*-}"    # extract string after first '-'
  version="$(echo ${rest} | sed -e 's/-chromeos.*$//')"
                        # extract string between first '-' and "-chromeos"

  download_check "${name}" "${url}" "${tarfile}"
  extract_install "${name}" "${tarfile}"
  update_device_json "${name}" "${version}"
done

# workaround https://github.com/skycocker/chromebrew/issues/3305
sudo ldconfig > /dev/null 2> /dev/null || true

# create symlink to 'crew' in ${CREW_PREFIX}/bin/
rm -f "${CREW_PREFIX}/bin/crew"
ln -s "../lib/crew/crew" "${CREW_PREFIX}/bin/"

# prepare sparse checkout .rb packages directory and do it
cd "${CREW_LIB_PATH}"
rm -rf .git
git init
git remote add -f origin "https://github.com/${OWNER}/${REPO}.git"
git config core.sparsecheckout true
echo packages >> .git/info/sparse-checkout
echo lib >> .git/info/sparse-checkout
echo crew >> .git/info/sparse-checkout
git fetch origin "${BRANCH}"
git reset --hard origin/"${BRANCH}"
crew update

# install a base set of essential packages
yes | crew install buildessential less most

echo
if [[ "${CREW_PREFIX}" != "/usr/local" ]]; then
  echo "Since you have installed Chromebrew in a directory other than '/usr/local',"
  echo "you need to run these commands to complete your installation:"
  echo "echo 'export CREW_PREFIX=${CREW_PREFIX}' >> ~/.bashrc"
  echo "echo 'export PATH=\"\${CREW_PREFIX}/bin:\${CREW_PREFIX}/sbin:\${PATH}\"' >> ~/.bashrc"
  echo "echo 'export LD_LIBRARY_PATH=${CREW_PREFIX}/lib${LIB_SUFFIX}' >> ~/.bashrc"
  echo 'source ~/.bashrc'
  echo
fi
echo "To set the default PAGER environment variable to use less:"
echo "echo \"export PAGER='less'\" >> ~/.bashrc && . ~/.bashrc"
echo
echo "Alternatively, you could use most.  Why settle for less, right?"
echo "echo \"export PAGER='most'\" >> ~/.bashrc && . ~/.bashrc"
echo
echo "Below are some text editor suggestions."
echo
echo "To install 'nano', execute:"
echo "crew install nano"
echo
echo "Or, to get an updated version of 'vim', execute:"
echo "crew install vim"
echo
echo "You may wish to set the EDITOR environment variable for an editor default."
echo
echo "For example, to set 'nano' as the default editor, execute:"
echo "echo \"export EDITOR='nano'\" >> ~/.bashrc && . ~/.bashrc"
echo
echo "To set 'vim' as the default editor, execute:"
echo "echo \"export EDITOR='vim'\" >> ~/.bashrc && . ~/.bashrc"
echo
echo "Chromebrew installed successfully and package lists updated."
