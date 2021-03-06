#!/usr/bin/env sh

for arg in "$*"; do
    eval "export $arg"
done

(
    echo "use ${MYSQL_DATABASE};"
    for func in str_and str_or str_xor str_not; do
        echo "create function $func returns string soname '$SONAME';"
    done
    echo "select * from mysql.func"
) | ${MYSQL:-mysql} -f -u root -p
