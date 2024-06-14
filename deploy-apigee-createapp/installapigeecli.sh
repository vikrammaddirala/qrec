#!/bin/sh
set -e

# Determines the operating system.
OS="$(uname)"
if [ "${OS}" = "Darwin" ] ; then
  OSEXT="Darwin"
else
  OSEXT="Linux"
fi

# Determine the latest apigeecli version by version number ignoring alpha, beta, and rc versions.
if [ "${APIGEECLI_VERSION}" = "" ] ; then
  APIGEECLI_VERSION="$(curl -sL https://api.github.com/repos/apigee/apigeecli/releases/latest | grep tag_name | sed -E 's/.*"([^"]+)".*/\1/')"
fi

LOCAL_ARCH=$(uname -m)
if [ "${TARGET_ARCH}" ]; then
    LOCAL_ARCH=${TARGET_ARCH}
fi

case "${LOCAL_ARCH}" in
  x86_64|amd64)
    APIGEECLI_ARCH=x86_64
    ;;
  arm64|armv8*|aarch64*)
    APIGEECLI_ARCH=arm64
    ;;
  *)
    echo "This system's architecture, ${LOCAL_ARCH}, isn't supported"
    exit 1
    ;;
esac

if [ "${APIGEECLI_VERSION}" = "" ] ; then
  echo "Unable to get latest apigeecli version. Set APIGEECLI_VERSION env var and re-run. For example: export APIGEECLI_VERSION=v1.104"
  exit 1
fi

# older versions of apigeecli used a file called .apigeecli. This changed to a folder in v1.108
APIGEECLI_FILE=~/.apigeecli
if [ -f "$APIGEECLI_FILE" ]; then
    rm ${APIGEECLI_FILE}
fi

# Downloads the apigeecli binary archive.
tmp=$(mktemp -d /tmp/apigeecli.XXXXXX)
NAME="apigeecli_$APIGEECLI_VERSION"
URL="https://github.com/apigee/apigeecli/releases/download/${APIGEECLI_VERSION}/apigeecli_${APIGEECLI_VERSION}_${OSEXT}_${APIGEECLI_ARCH}.zip"
COSIGN_PUBLIC_KEY="https://raw.githubusercontent.com/apigee/apigeecli/main/cosign.pub"

echo "\nDownloading ${NAME} from ${URL} ..."
if ! curl -o /dev/null -sIf "$URL"; then
  echo "\n${URL} is not found, please specify a valid APIGEECLI_VERSION and TARGET_ARCH"
  exit 1
fi

curl -fsLO "$URL"
filename="apigeecli_${APIGEECLI_VERSION}_${OSEXT}_${APIGEECLI_ARCH}.zip"

# Check if cosign is installed
if cosign version > /dev/null 2>&1; then
  echo "Verifying the signature of the binary ${filename}"
  curl -fsLO -H 'Cache-Control: no-cache, no-store' "$COSIGN_PUBLIC_KEY"
  sig_filename="${filename}.sig"
  curl -fsLO -H 'Cache-Control: no-cache, no-store' "https://github.com/apigee/apigeecli/releases/download/${APIGEECLI_VERSION}/${sig_filename}"
  cosign verify-blob --key "$tmp/cosign.pub" --signature "$tmp/${sig_filename}" "$tmp/$filename"
  rm "$tmp/$sig_filename"
  rm $tmp/cosign.pub
else
  echo "cosign is not installed, skipping signature verification"
fi

echo "Unzipping ${filename}"
apt-get update && apt-get install -y unzip
unzip "${filename}"
rm "${filename}"

echo "\napigeecli ${APIGEECLI_VERSION} Download Complete!\n"

# setup apigeecli
cd "$HOME" || exit
mkdir -p "$HOME/.apigeecli/bin"
mv "${tmp}/apigeecli_${APIGEECLI_VERSION}_${OSEXT}_${APIGEECLI_ARCH}/apigeecli" "$HOME/.apigeecli/bin"
mv "${tmp}/apigeecli_${APIGEECLI_VERSION}_${OSEXT}_${APIGEECLI_ARCH}/LICENSE.txt" "$HOME/.apigeecli/LICENSE.txt"

echo "Copied apigeecli into the $HOME/.apigeecli/bin folder."
chmod +x "$HOME/.apigeecli/bin/apigeecli"
rm -r "${tmp}"

echo "Added the apigeecli to your path with:"
echo "  export PATH=\$PATH:\$HOME/.apigeecli/bin"
echo ""

export PATH=$PATH:$HOME/.apigeecli/bin
