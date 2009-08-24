#!/usr/bin/env sh

direction=

for arg in "$@"; do
    case "$arg" in
        *[=]*)   eval "export \"$arg\"";;
        up|down) direction="$arg";;
        *) echo "invalid argument '$arg'" >&2; exit 1;;
    esac
done

direction=${direction:-up}

if [ -n "$MYSQL_DATABASE" ]; then
    echo "use ${MYSQL_DATABASE};"
fi

ops="str_and str_or str_xor str_not"

for func in $ops; do
    if [ "$direction" = "up" ]; then
        if [ -z "$SONAME" ]; then
            echo "run 'make sql-up' instead." >&2
            exit 2
        fi
        echo "create function $func returns string soname '$SONAME';"
    else
        echo "drop function $func;";
    fi
done

echo "select * from mysql.func;"
