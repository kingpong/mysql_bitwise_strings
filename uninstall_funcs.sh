#!/usr/bin/env sh

for arg in "$*"; do
    eval "export $arg"
done

(
    echo "use ${MYSQL_DATABASE};"
    for func in str_and str_or str_xor str_not; do
        echo "drop function $func;"
    done 
) | ${MYSQL:=mysql} -f -u root -p 2>&1 | grep -v 'No database selected'

exit 0
