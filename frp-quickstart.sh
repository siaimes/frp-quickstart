#!/bin/bash
set -euo pipefail

function prompt() {
    while true; do
        read -p "$1 [y/N] " yn
        case $yn in
            [Yy] ) return 0;;
            [Nn]|"" ) return 1;;
        esac
    done
}

if [[ $(id -u) != 0 ]]; then
    echo Please run this script as root.
    exit 1
fi

if [[ $(uname -m 2> /dev/null) != x86_64 ]]; then
    echo Please run this script on x86_64 machine.
    exit 1
fi

NAME=fatedier
REPO=frp
if prompt "Install type, y for server, n for client"; then
    TYPE=s
else
    TYPE=c
fi
VERSION=$(curl -fsSL https://api.github.com/repos/$NAME/$REPO/releases/latest | grep tag_name | sed -E 's/.*"v(.*)".*/\1/')
TARBALL="${REPO}_${VERSION}_linux_amd64.tar.gz"
DOWNLOADURL="https://github.com/$NAME/$REPO/releases/download/v$VERSION/$TARBALL"
TMPDIR="$(mktemp -d)"
INSTALLPREFIX=/usr/local
SYSTEMDPREFIX=/etc/systemd/system

BINARYPATH="$INSTALLPREFIX/bin/$REPO$TYPE"
CONFIGPATH="$INSTALLPREFIX/etc/$REPO$TYPE/config.ini"
SYSTEMDPATH="$SYSTEMDPREFIX/$REPO$TYPE.service"

echo Entering temp directory $TMPDIR...
cd "$TMPDIR"

echo Downloading $REPO $VERSION...
curl -LO --progress-bar "$DOWNLOADURL" || wget -q --show-progress "$DOWNLOADURL"

echo Unpacking $REPO $VERSION...
tar xzvf "$TARBALL" -C $TMPDIR
cd "${REPO}_${VERSION}_linux_amd64"

echo Installing $REPO$TYPE $VERSION to $BINARYPATH...
install -Dm755 "$REPO$TYPE" "$BINARYPATH"

echo Installing $REPO$TYPE config to $CONFIGPATH...
if ! [[ -f "$CONFIGPATH" ]] || prompt "The server config already exists in $CONFIGPATH, overwrite?"; then
    install -Dm644 "$REPO$TYPE.ini" "$CONFIGPATH"
else
    echo Skipping installing $REPO$TYPE server config...
fi

if [[ -d "$SYSTEMDPREFIX" ]]; then
    echo Installing $REPO$TYPE systemd service to $SYSTEMDPATH...
    if ! [[ -f "$SYSTEMDPATH" ]] || prompt "The systemd service already exists in $SYSTEMDPATH, overwrite?"; then
        cat > "$SYSTEMDPATH" << EOF
[Unit]
Description=$REPO$TYPE Service
After=network.target
[Service]
Type=simple
User=nobody
Restart=on-failure
RestartSec=5s
ExecStart="$BINARYPATH" -c "$CONFIGPATH"
[Install]
WantedBy=multi-user.target
EOF

        echo Reloading systemd daemon...
        systemctl daemon-reload
    else
        echo Skipping installing $REPO$TYPE systemd service...
    fi
fi

echo Deleting temp directory $TMPDIR...
rm -rf "$TMPDIR"

echo Done!
