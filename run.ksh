#!/bin/ksh

for dir in /app /data; do
  # Check folder existence
  if [[ ! -d "${dir}" ]]; then
    print -u2 -f "Error: folder %s is not present.\n" "${dir}"
    exit 1
  fi
  
  if [[ ! -w "${dir}" ]]; then
    print -u2 -f "Error: folder %s is not able to be written to.\n" "${dir}"
    exit 1
  fi
done

# Check for shared folders which cause all kinds of weird errors on core updates
rm -f /data/check-for-shared-with-data
touch /app/check-for-shared-with-data
if [[ -f /data/check-for-shared-with-data ]]; then
    print -u2 -f "Error: application dir /app and data dir /data are shared. Please fix this.\n"
    exit 1
fi
rm -f /app/check-for-shared-with-data

# Optionally download the app
cd /app
if [[  ! -d RoonServer ]]; then
  if [[ -z "${ROON_SERVER_URL}" ]]; then
    print -u2 -f "Error: missing URL ROON_SERVER_URL.\n"
    exit 1
  fi
  if [[ -z "${ROON_SERVER_PKG}" ]] ; then
    print -u2 -f "Error: missing app name ROON_SERVER_PKG\n"
    exit 1
  fi

  curl ${ROON_SERVER_URL} -O && \
  tar xjf "${ROON_SERVER_PKG}" && \
  rm -f "${ROON_SERVER_PKG}"
  if (( ${?} != 0 )); then
    print -u2 -f "Error: unable to download and extract RoonServer package %s from url %s.\n" "${ROON_SERVER_PKG}" "${ROON_SERVER_URL}"
    exit 1
  fi
fi

# Run the app
if [[ -z "${ROON_DATAROOT}" ]]; then
    print -u2 -f "Error: ROON_DATAROOT not set.\n"
    exit 1
fi

if [[ -z "${ROON_ID_DIR}" ]]; then
    print -u2 -f "Error: ROON_ID_DIR not set.\n"
    exit 1
fi

/app/RoonServer/start.sh
