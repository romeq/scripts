#!/bin/sh

if [ $# != 1 ]; then
    printf "usage: ./encrypt.sh <folder to encrypt>\n" > /dev/stderr
    exit 2
elif [ ! -e $1 ]; then
    printf "input folder not found!" > /dev/stderr
    exit 2
fi


outarchive=$(mktemp)
if [ $? != 0 ]; then
    printf "Couldn't create temporary directory for files.\n" > /dev/stderr
    exit 1
fi

printf "\033[32m+\033[0m adding files to tarball..\n" 
tar -czvf $outarchive $1
if [ $? != 0 ]; then
    printf "\033[31m-\033[0m Couldn't archive files. exit\n" > /dev/stderr
    exit 1
elif [ ! -e $outarchive ]; then
    printf "\033[31m-\033[0m Tarball was not created. exit\n" > /dev/stderr
    exit 1
fi

outfile="out.enc"

printf "\n\033[32m+\033[0m Starting encryption...\n"

if ! openssl enc -aes-256-cbc -e -pbkdf2 -in $outarchive -out $outfile; then
    printf "\033[31m-\033[0m OpenSSL operation failed. exit\n" > /dev/stderr
    rm $outarchive

    exit 1
fi

printf "\033[32m+\033[0m Cleaning up..\n"
shred -u $outarchive

printf "\n\033[0;32m+\033[0m Encryption done.\n"
printf "\033[32m+\033[0m You can find your encrypted files in '$outfile'.\n"
printf "\033[32m+\033[0m To remove old plaintext files, please do it with shred to make sure nothing is left recoveable.\n"
