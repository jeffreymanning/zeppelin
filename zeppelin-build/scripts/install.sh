#!/bin/sh

set -e

SCRIPT_DIR=$(dirname $0)
mv /usr/bin/wget /usr/bin/wget.save
mv $SCRIPT_DIR/wget.sh /usr/bin/
chmod +x /usr/bin/wget.sh

