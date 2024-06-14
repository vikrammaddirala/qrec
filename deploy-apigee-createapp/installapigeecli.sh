#!/bin/sh
set -e

echo "Determining operating system..."
# Determines the operating system.
OS="$(uname)"
if [ "${OS}" = "Darwin" ] ; then
  OSEXT="Darwin"
else
  OSEXT="Linux"
fi
echo "Operating system: ${OSEXT}"

echo "Determining Apigee CLI version..."
# Determine the latest apigeecli version by version number ignoring alpha, beta, and rc versions.
if [ "${APIGEECLI_VERSION}" = "" ] ; then
  APIGEECLI_VERSION="$(curl -sL https://api.github.com/repos/apigee/apigeecli/releases/latest | grep tag_name | sed -E 's/.*"([^"]+)".*/\1/')"
fi
echo "Apigee CLI version: ${APIGEECLI_VERSION}"

echo "Determining local architecture..."
LOCAL_ARCH=$(uname -m)
if [ "${TARGET_ARCH}" ]; then
    LOCAL_ARCH=${TARGET_ARCH}
fi

case "${LOCAL_ARCH}" in
  x86_64|amd64)
    APIGEECLI_ARCH="x86_64"
    ;;
  *)
    echo "Unsupported architecture: ${LOCAL_ARCH}"
    exit 1
    ;;
esac
echo "Local architecture: ${LOCAL_ARCH}"

echo "Downloading Apigee CLI..."
curl -LO "https://github.com/apigee/apigeecli/releases/download/${APIGEECLI_VERSION}/apigeecli_${APIGEECLI_VERSION}_${OSEXT}_${APIGEECLI_ARCH}.tar.gz"

echo "Extracting Apigee CLI..."
tar -xzf "apigeecli_${APIGEECLI_VERSION}_${OSEXT}_${APIGEECLI_ARCH}.tar.gz" -C /usr/local/bin apigeecli

echo "Apigee CLI installed successfully."
