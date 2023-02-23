#!/bin/sh


if [ $# != 1 ]; then
    printf "usage: ./encrypt.sh <folder to encrypt>\n" > /dev/stderr
    exit 2
elif [ ! -e $1 ]; then
    printf "input folder not found!\n" > /dev/stderr
    exit 2
fi


tmp_out=$(mktemp)
if [ $? != 0 ]; then
    printf "\033[31m-\033[0m Couldn't create temporary file to store uncompressed data to.\n"
    exit 1
fi

tmpd=$(mktemp -d)
if [ ! -e $tmpd ]; then
    printf "\033[31m-\033[0m Unable to create temporary folder for decrypted files. exit\n" > /dev/stderr
    exit 1
fi

printf "\033[0;32m+\033[0m Starting decryption...\n"


if ! openssl enc -aes-256-cbc -pbkdf2 -d -in "$1" -out $tmp_out; then
    printf "\033[31m-\033[0m OpenSSL process failed. exit\n" > /dev/stderr
    shred -u $tmp_out
    exit 1
fi


printf "\n\033[32m+\033[0m Extracting tarball...\n"
tar -xzvf $tmp_out -C $tmpd 
if [ $? != 0 ]; then
    printf "\033[31mcouldn't archive files. exit\n" > /dev/stderr
    exit 1
elif [ ! -e $tmp_out ]; then
    printf "\033[31m+\033[0m Folder where decryption data was going to be saved to was not found,"\
        "or was deleted during process. exit\n" > /dev/stderr
    exit 1
fi

printf "\033[32m+\033[0m Cleaning up..\n"
shred -u $tmp_out

printf "\n\033[32m+\033[0m Decryption done.\n"
printf "\n\033[32m+\033[0m Your decrypted files are located in '$tmpd'.\n"

