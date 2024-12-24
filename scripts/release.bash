#/bin/bash

if [ -z $1 ]; then
    echo -e "\033[31;1;1mUsage: scripts/release.bash [OUT_DIR]\033[0m" > /dev/stderr
    exit 2
fi

if [ ! -d scripts ]; then
    echo -e "\033[31;1;1mOnly run script from project root\033[0m" > /dev/stderr
    exit 1
fi

bash scripts/build.bash $1 || exit $?

tar -c -v --zstd -f release.tgz $1
