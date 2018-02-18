#!/bin/sh

while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -os)
    OS="$2"
    shift # past argument
    shift # past value
    ;;
    -os-version)
    OS_VER="$2"
    shift # past argument
    shift # past value
    ;;
    *)
    shift
    ;;
esac
done

OS=$(echo "$OS" | tr '[:upper:]' '[:lower:]')

if [ -f setup_env/${OS}.sh ];
then
    ./setup_env/${OS}.sh
else
    echo "Unsupported os"
fi


