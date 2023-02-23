#!/bin/sh

if [ $# -lt 2 ]; then
    echo "usage: $0 <repository> <MIT copyright holder>"
    exit 2
fi

git init
go mod init github.com/$1
sed /usr/local/share/licenses/common/MIT/LICENSE -e "s/<copyright holders>/$2/" > LICENSE
